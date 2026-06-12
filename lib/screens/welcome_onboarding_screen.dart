import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:drift/drift.dart' hide Column;
import 'package:uuid/uuid.dart';

import '../data/local_db.dart';
import '../data/sync_engine.dart';
import '../services/activation_service.dart';
import '../services/auth_service.dart';
import '../services/cloud_owner_bind_service.dart';
import '../services/desktop_registration_service.dart';
import '../services/license_service.dart';
import '../utils/farm_utils.dart';
import '../utils/id_utils.dart';
import '../utils/secure_auth_storage.dart';
import '../utils/user_role.dart';
import 'offline_terminal_login_screen.dart';
import 'role_dashboard_router.dart';

class WelcomeOnboardingScreen extends StatefulWidget {
  final WelcomeOnboardingEntry entry;

  const WelcomeOnboardingScreen({
    super.key,
    this.entry = WelcomeOnboardingEntry.choice,
  });

  @override
  State<WelcomeOnboardingScreen> createState() =>
      _WelcomeOnboardingScreenState();
}

enum _OnboardingStep {
  desktopRegistration,
  choice,
  webKeyIngestion,
  localDesktopSetup,
  offlineLocalSetup,
}

enum WelcomeOnboardingEntry { choice, webKeyIngestion, offlineLocalSetup }

class _WelcomeOnboardingScreenState extends State<WelcomeOnboardingScreen>
    with SingleTickerProviderStateMixin {
  late _OnboardingStep _step;

  final _farmIdCtrl = TextEditingController();
  final _activationKeyCtrl = TextEditingController();
  final _desktopUserCtrl = TextEditingController();
  final _desktopPasswordCtrl = TextEditingController();
  final _regFarmNameCtrl = TextEditingController();
  final _regOwnerPhoneCtrl = TextEditingController();
  final _regAdminEmailCtrl = TextEditingController();
  final _regMasterPasswordCtrl = TextEditingController();

  bool _obscureDesktopPassword = true;
  bool _obscureMasterPassword = true;
  bool _isLoading = false;
  bool _googleAuthPending = false;
  bool _handlingGoogleRegistration = false;
  String? _error;
  String? _message;
  late final DesktopRegistrationService _desktopRegistrationService;
  StreamSubscription<AuthState>? _authSubscription;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _step = _mapEntryToStep(widget.entry);
    _desktopRegistrationService = DesktopRegistrationService();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        if (!_googleAuthPending) return;
        if (data.event == AuthChangeEvent.signedIn && data.session != null) {
          unawaited(_completeGoogleRegistration());
        }
      },
      onError: (error, stackTrace) {
        if (!mounted) return;
        setState(
          () => _error = 'Google sign-in interrupted. Please try again.',
        );
      },
    );
    if (_isGoogleAuthUser(Supabase.instance.client.auth.currentUser)) {
      _googleAuthPending = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _completeGoogleRegistration(),
      );
    }
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  _OnboardingStep _mapEntryToStep(WelcomeOnboardingEntry entry) {
    switch (entry) {
      case WelcomeOnboardingEntry.webKeyIngestion:
        return _OnboardingStep.webKeyIngestion;
      case WelcomeOnboardingEntry.offlineLocalSetup:
        return _OnboardingStep.offlineLocalSetup;
      case WelcomeOnboardingEntry.choice:
        return _OnboardingStep.desktopRegistration;
    }
  }

  bool _isGoogleAuthUser(dynamic user) {
    if (user == null) return false;
    final metadata = user.appMetadata;
    if (metadata is! Map) return false;
    return metadata['provider']?.toString().toLowerCase() == 'google';
  }

  @override
  void dispose() {
    _farmIdCtrl.dispose();
    _activationKeyCtrl.dispose();
    _desktopUserCtrl.dispose();
    _desktopPasswordCtrl.dispose();
    _regFarmNameCtrl.dispose();
    _regOwnerPhoneCtrl.dispose();
    _regAdminEmailCtrl.dispose();
    _regMasterPasswordCtrl.dispose();
    _authSubscription?.cancel();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _navigate(_OnboardingStep next, {String? message}) {
    setState(() {
      _step = next;
      _error = null;
      _message = message;
    });
    _fadeCtrl
      ..reset()
      ..forward();
  }

  Future<void> _verifyAndStartSync() async {
    final farmId = _farmIdCtrl.text.trim();
    final activationKey = _activationKeyCtrl.text.trim();
    if (farmId.isEmpty || activationKey.isEmpty) {
      setState(() => _error = 'Please enter both Farm ID and Activation Key.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _message = null;
    });

    try {
      final syncEngine = context.read<SyncEngine>();
      if (!syncEngine.isOnline) {
        throw Exception('Internet connection is required to verify and sync.');
      }

      final hardwareId = await getDeviceHardwareId();
      final activationService = ActivationService();

      final verifyError = await activationService.verifyActivationKey(
        farmId: farmId,
        activationKey: activationKey,
        hardwareId: hardwareId,
      );
      if (verifyError != null) {
        throw Exception(verifyError);
      }

      final canBind = await Supabase.instance.client.rpc(
        'verify_farm_binding',
        params: {'p_farm_id': farmId},
      );
      if (canBind != true) {
        throw Exception('This Farm ID cannot be bound on this desktop.');
      }

      await syncEngine.initialFullSync(farmId);
      await FarmUtils.setBoundFarmId(farmId);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_bound', true);

      final db = context.read<AppDatabase>();
      await LicenseService(
        db,
      ).initCloudLicenseFromActivation(farmId: farmId, hardwareId: hardwareId);

      // Map offline/local owner UUIDs to the cloud farm owner (fixes batch push FK).
      await CloudOwnerBindService(db).rebindLocalOwnerToCloud(farmId: farmId);

      if (!mounted) return;

      final boundToCloudOwner = await _tryBindSyncedCloudOwnerAndEnterDashboard(
        farmId,
      );
      if (boundToCloudOwner) return;

      _navigate(
        _OnboardingStep.localDesktopSetup,
        message: 'Verification successful. Cloud sync completed.',
      );
    } on PostgrestException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _startGoogleRegistration() async {
    setState(() {
      _isLoading = true;
      _googleAuthPending = true;
      _error = null;
      _message = null;
    });

    try {
      await _desktopRegistrationService.startGoogleRegistration();
      if (!mounted) return;
      setState(
        () => _message =
            'Complete Google sign-in in your browser, then return to HatchLog.',
      );
    } catch (e) {
      setState(() {
        _googleAuthPending = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _completeGoogleRegistration() async {
    if (_handlingGoogleRegistration || !mounted) return;
    _handlingGoogleRegistration = true;
    setState(() {
      _isLoading = true;
      _error = null;
      _message = 'Finalizing Google registration...';
    });

    try {
      final result = await _desktopRegistrationService
          .completeGoogleRegistration(db: context.read<AppDatabase>());
      context.read<SyncEngine>().startPeriodicSync();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => RoleDashboardRouter(role: result.role),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      _googleAuthPending = false;
      _handlingGoogleRegistration = false;
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitTraditionalRegistration() async {
    final farmName = _regFarmNameCtrl.text.trim();
    final phone = _regOwnerPhoneCtrl.text.trim();
    final email = _regAdminEmailCtrl.text.trim();
    final password = _regMasterPasswordCtrl.text;

    if (farmName.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      setState(() => _error = 'All registration fields are required.');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _error = 'Enter a valid admin email address.');
      return;
    }
    if (password.length < 8) {
      setState(
        () => _error = 'Create a master password with at least 8 characters.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _message = null;
    });

    try {
      final result = await _desktopRegistrationService.registerTraditional(
        db: context.read<AppDatabase>(),
        farmName: farmName,
        ownerPhoneNumber: phone,
        adminEmail: email,
        masterPassword: password,
      );
      context.read<SyncEngine>().startPeriodicSync();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => RoleDashboardRouter(role: result.role),
        ),
      );
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// After cloud sync, bind the desktop session to the farm owner already on
  /// HatchLog Web — skip manual local username/password when that user exists.
  Future<bool> _tryBindSyncedCloudOwnerAndEnterDashboard(String farmId) async {
    final db = context.read<AppDatabase>();
    final owner = await CloudOwnerBindService(db).cloudOwnerUser(farmId);
    if (owner == null) return false;

    final role = UserRoleUtils.normalize(owner.role);
    final displayName = owner.name?.trim().isNotEmpty == true
        ? owner.name!.trim()
        : (owner.email?.trim().isNotEmpty == true
              ? owner.email!.trim()
              : 'Farm Owner');

    UserSession().startSession(id: owner.id, name: displayName, role: role);
    await UserSession().persistToPrefs();

    if (!mounted) return true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => RoleDashboardRouter(role: role)),
    );
    return true;
  }

  Future<void> _completeSetupAndEnterDashboard() async {
    final username = _desktopUserCtrl.text.trim();
    final password = _desktopPasswordCtrl.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = 'Choose both desktop username and password.');
      return;
    }
    if (password.length < 6) {
      setState(
        () => _error = 'Desktop password must be at least 6 characters.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final db = context.read<AppDatabase>();

      final existing =
          await (db.select(db.users)..where(
                (u) => u.email.equals(username) | u.name.equals(username),
              ))
              .getSingleOrNull();
      if (existing != null) {
        throw Exception('This desktop username is already in use.');
      }

      final ownerId = newLocalId();
      final farmId = await FarmUtils.getBoundFarmId();
      await SecureAuthStorage.saveOfflineCredential(
        userId: ownerId,
        secret: password,
        displayName: username,
        farmId: farmId,
        provider: 'desktop_activation',
      );

      await db
          .into(db.users)
          .insert(
            UsersCompanion.insert(
              id: ownerId,
              email: Value(username),
              password: const Value(null),
              name: Value(username),
              role: const Value('OWNER'),
              mustChangePassword: const Value(false),
            ),
          );

      if (farmId != null && farmId.isNotEmpty) {
        final existingMember =
            await (db.select(db.farmMembers)..where(
                  (m) => m.farmId.equals(farmId) & m.userId.equals(ownerId),
                ))
                .getSingleOrNull();
        if (existingMember == null) {
          await db
              .into(db.farmMembers)
              .insert(
                FarmMembersCompanion.insert(
                  id: newLocalId(),
                  farmId: farmId,
                  userId: ownerId,
                  role: const Value('OWNER'),
                ),
              );
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('owner_id', ownerId);
      await prefs.setString('user_id', ownerId);
      await prefs.setString('user_email', username);
      await prefs.setString('user_name', username);
      await prefs.setString('user_role', 'OWNER');
      await prefs.setBool('is_bound', true);

      UserSession().startSession(id: ownerId, name: username, role: 'OWNER');

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => RoleDashboardRouter(role: 'OWNER')),
      );
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createOfflineLocalProfile() async {
    final username = _desktopUserCtrl.text.trim();
    final password = _desktopPasswordCtrl.text;
    if (username.isEmpty || password.isEmpty) {
      setState(
        () => _error = 'Choose Username and Choose Password are required.',
      );
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _message = null;
    });

    try {
      final db = context.read<AppDatabase>();

      final existing =
          await (db.select(db.users)..where(
                (u) => u.name.equals(username) | u.email.equals(username),
              ))
              .getSingleOrNull();
      if (existing != null) {
        throw Exception('This username already exists on this device.');
      }

      final ownerId = const Uuid().v4();
      await SecureAuthStorage.saveOfflineCredential(
        userId: ownerId,
        secret: password,
        displayName: username,
        farmId: FarmUtils.localGenesisFarmId,
        farmName: FarmUtils.localGenesisFarmName,
        provider: 'offline_local',
      );

      await db
          .into(db.users)
          .insert(
            UsersCompanion.insert(
              id: ownerId,
              name: Value(username),
              password: const Value(null),
              email: const Value(null),
              phoneNumber: const Value(null),
              role: const Value('OWNER'),
              mustChangePassword: const Value(false),
            ),
          );

      await FarmUtils.ensureLocalGenesisFarm(db, ownerId: ownerId);
      await LicenseService(db).initOfflineLicense();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(localProfileEstablishedKey, true);
      await prefs.setString(localProfileOwnerIdKey, ownerId);
      await prefs.setBool('is_bound', true);
      await prefs.setString('owner_id', ownerId);
      await prefs.setString('user_id', ownerId);
      await prefs.setString('user_name', username);
      await prefs.setString('user_email', '');
      await prefs.setString('user_role', 'OWNER');

      UserSession().startSession(id: ownerId, name: username, role: 'OWNER');

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OfflineTerminalLoginScreen()),
      );
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0A1628), Color(0xFF0D2137)],
                ),
              ),
            ),
          ),
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF16A34A).withOpacity(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: FadeTransition(opacity: _fade, child: _buildStep()),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      _OnboardingStep.desktopRegistration => _buildDesktopRegistrationPanel(),
      _OnboardingStep.choice => _buildChoicePanel(),
      _OnboardingStep.webKeyIngestion => _buildWebKeyIngestionPanel(),
      _OnboardingStep.localDesktopSetup => _buildLocalDesktopSetupPanel(),
      _OnboardingStep.offlineLocalSetup => _buildOfflineLocalSetupPanel(),
    };
  }

  Widget _buildDesktopRegistrationPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: _GlassCard(
        width: 1040,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.agriculture, size: 42, color: Color(0xFF22C55E)),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Register HatchLog Desktop',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Choose Google sign-up or create native farm credentials.',
                        style: TextStyle(color: Color(0xFFB6C2D1)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            if (_message != null) ...[
              _InfoBanner(message: _message!),
              const SizedBox(height: 14),
            ],
            if (_error != null) ...[
              _ErrorBanner(message: _error!),
              const SizedBox(height: 14),
            ],
            LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 860;
                final googlePanel = _RegistrationRoutePanel(
                  icon: LucideIcons.chrome,
                  title: 'Continue with Google',
                  subtitle:
                      'Use Google OAuth for cloud identity, then set a local fallback credential if this is a new HatchLog account.',
                  accent: const Color(0xFF38BDF8),
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _startGoogleRegistration,
                        icon: _isLoading && _googleAuthPending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(LucideIcons.chrome, size: 18),
                        label: const Text(
                          'Continue with Google',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF38BDF8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _RegistrationLink(
                      icon: LucideIcons.badgeCheck,
                      label: 'Use Farm ID and Activation Key',
                      onTap: () => _navigate(_OnboardingStep.webKeyIngestion),
                    ),
                    const SizedBox(height: 10),
                    _RegistrationLink(
                      icon: LucideIcons.hardDrive,
                      label: 'Create offline-only local profile',
                      onTap: () => _navigate(_OnboardingStep.offlineLocalSetup),
                    ),
                  ],
                );

                final traditionalPanel = _RegistrationRoutePanel(
                  icon: LucideIcons.keyRound,
                  title: 'Traditional Registration',
                  subtitle:
                      'Create a Supabase account and use this exact password as the workstation master key for offline access.',
                  accent: const Color(0xFF22C55E),
                  children: [
                    _GlassTextField(
                      controller: _regFarmNameCtrl,
                      label: 'Farm Name',
                      hint: 'e.g. Sunrise Layers Farm',
                      icon: LucideIcons.warehouse,
                    ),
                    const SizedBox(height: 12),
                    _GlassTextField(
                      controller: _regOwnerPhoneCtrl,
                      label: 'Owner Phone Number',
                      hint: '+233 ...',
                      icon: LucideIcons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _GlassTextField(
                      controller: _regAdminEmailCtrl,
                      label: 'Admin Email',
                      hint: 'owner@example.com',
                      icon: LucideIcons.mail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    _GlassTextField(
                      controller: _regMasterPasswordCtrl,
                      label: 'Create Master Password',
                      hint: 'At least 8 characters',
                      icon: LucideIcons.lock,
                      obscureText: _obscureMasterPassword,
                      onSubmitted: (_) => _submitTraditionalRegistration(),
                      suffix: IconButton(
                        tooltip: _obscureMasterPassword ? 'Show' : 'Hide',
                        icon: Icon(
                          _obscureMasterPassword
                              ? LucideIcons.eyeOff
                              : LucideIcons.eye,
                          size: 18,
                          color: const Color(0xFF94A3B8),
                        ),
                        onPressed: () => setState(
                          () =>
                              _obscureMasterPassword = !_obscureMasterPassword,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _PrimaryButton(
                      label: 'Register Account',
                      icon: LucideIcons.userPlus,
                      color: const Color(0xFF22C55E),
                      isLoading: _isLoading && !_googleAuthPending,
                      onPressed: _submitTraditionalRegistration,
                    ),
                  ],
                );

                if (narrow) {
                  return Column(
                    children: [
                      googlePanel,
                      const SizedBox(height: 16),
                      traditionalPanel,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: googlePanel),
                    const SizedBox(width: 18),
                    Expanded(child: traditionalPanel),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoicePanel() {
    return SizedBox(
      width: 860,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.agriculture, size: 56, color: Color(0xFF22C55E)),
          const SizedBox(height: 16),
          const Text(
            'Welcome to HatchLog Desktop',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the path that matches your setup.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 42),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _OptionCard(
                  icon: LucideIcons.badgeCheck,
                  iconColor: const Color(0xFF38BDF8),
                  title: 'Existing Web Account',
                  subtitle:
                      'Use your Farm ID and Activation Key from your HatchLog web dashboard to verify this desktop and start sync.',
                  badge: 'ACCOUNT READY',
                  badgeColor: const Color(0xFF38BDF8),
                  buttonLabel: 'Yes, I have a HatchLog Website Account',
                  buttonColor: const Color(0xFF38BDF8),
                  onPressed: () => _navigate(_OnboardingStep.webKeyIngestion),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _OptionCard(
                  icon: LucideIcons.userPlus,
                  iconColor: const Color(0xFF22C55E),
                  title: 'Offline Local Setup',
                  subtitle:
                      'Create a local terminal-only profile for this desktop without email, phone, or Google sign-in.',
                  badge: 'OFFLINE PROFILE',
                  badgeColor: const Color(0xFF22C55E),
                  buttonLabel: "Don't have an account? Create one offline",
                  buttonColor: const Color(0xFF22C55E),
                  onPressed: () => _navigate(_OnboardingStep.offlineLocalSetup),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWebKeyIngestionPanel() {
    return _GlassCard(
      width: 540,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BackButton(onTap: () => _navigate(_OnboardingStep.choice)),
          const SizedBox(height: 14),
          const Text(
            'Activate Desktop & Verify Web Keys',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Log into your HatchLog Web Dashboard, navigate to Settings -> Desktop Licenses, and copy your generated Farm ID and Activation Key.',
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Colors.white.withOpacity(0.72),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_message != null) ...[
            _InfoBanner(message: _message!),
            const SizedBox(height: 14),
          ],
          if (_error != null) ...[
            _ErrorBanner(message: _error!),
            const SizedBox(height: 14),
          ],
          _GlassTextField(
            controller: _farmIdCtrl,
            label: 'Farm ID',
            hint: 'Enter farm id from web dashboard',
            icon: LucideIcons.layoutGrid,
          ),
          const SizedBox(height: 14),
          _GlassTextField(
            controller: _activationKeyCtrl,
            label: 'Activation Key',
            hint: 'Enter desktop activation key',
            icon: LucideIcons.key,
            onSubmitted: (_) => _verifyAndStartSync(),
          ),
          const SizedBox(height: 24),
          _PrimaryButton(
            label: 'Verify & Start Sync',
            icon: LucideIcons.cloudLightning,
            color: const Color(0xFF38BDF8),
            isLoading: _isLoading,
            onPressed: _verifyAndStartSync,
          ),
        ],
      ),
    );
  }

  Widget _buildLocalDesktopSetupPanel() {
    return _GlassCard(
      width: 540,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BackButton(onTap: () => _navigate(_OnboardingStep.webKeyIngestion)),
          const SizedBox(height: 14),
          const Text(
            'Set Up Your Local Desktop Access',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Since you use Google Sign-In on the web, create a secure local username and password to log into this desktop machine while offline.',
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Colors.white.withOpacity(0.72),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_message != null) ...[
            _InfoBanner(message: _message!),
            const SizedBox(height: 14),
          ],
          if (_error != null) ...[
            _ErrorBanner(message: _error!),
            const SizedBox(height: 14),
          ],
          _GlassTextField(
            controller: _desktopUserCtrl,
            label: 'Choose Desktop Username',
            hint: 'e.g. farm-owner-desktop',
            icon: LucideIcons.user,
          ),
          const SizedBox(height: 14),
          _GlassTextField(
            controller: _desktopPasswordCtrl,
            label: 'Choose Desktop Password',
            hint: 'At least 6 characters',
            icon: LucideIcons.lock,
            obscureText: _obscureDesktopPassword,
            onSubmitted: (_) => _completeSetupAndEnterDashboard(),
            suffix: IconButton(
              icon: Icon(
                _obscureDesktopPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                size: 18,
                color: const Color(0xFF94A3B8),
              ),
              onPressed: () => setState(
                () => _obscureDesktopPassword = !_obscureDesktopPassword,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _PrimaryButton(
            label: 'Complete Setup & Enter Dashboard',
            icon: LucideIcons.checkCircle2,
            color: const Color(0xFF22C55E),
            isLoading: _isLoading,
            onPressed: _completeSetupAndEnterDashboard,
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineLocalSetupPanel() {
    return _GlassCard(
      width: 540,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BackButton(onTap: () => _navigate(_OnboardingStep.choice)),
          const SizedBox(height: 14),
          const Text(
            'Create Your Local Desktop Profile',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Set up a one-time local terminal profile for offline desktop access.',
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Colors.white.withOpacity(0.74),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_message != null) ...[
            _InfoBanner(message: _message!),
            const SizedBox(height: 14),
          ],
          if (_error != null) ...[
            _ErrorBanner(message: _error!),
            const SizedBox(height: 14),
          ],
          _GlassTextField(
            controller: _desktopUserCtrl,
            label: 'Choose Username',
            hint: 'local_owner',
            icon: LucideIcons.user,
          ),
          const SizedBox(height: 14),
          _GlassTextField(
            controller: _desktopPasswordCtrl,
            label: 'Choose Password',
            hint: 'At least 6 characters',
            icon: LucideIcons.lock,
            obscureText: _obscureDesktopPassword,
            onSubmitted: (_) => _createOfflineLocalProfile(),
            suffix: IconButton(
              icon: Icon(
                _obscureDesktopPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                size: 18,
                color: const Color(0xFF94A3B8),
              ),
              onPressed: () => setState(
                () => _obscureDesktopPassword = !_obscureDesktopPassword,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _PrimaryButton(
            label: 'Create Local Profile',
            icon: LucideIcons.checkCircle2,
            color: const Color(0xFF16A34A),
            isLoading: _isLoading,
            onPressed: _createOfflineLocalProfile,
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final String buttonLabel;
  final Color buttonColor;
  final VoidCallback onPressed;

  const _OptionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.buttonLabel,
    required this.buttonColor,
    required this.onPressed,
  });

  @override
  State<_OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<_OptionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _hovered
              ? Colors.white.withOpacity(0.09)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _hovered
                ? widget.iconColor.withOpacity(0.4)
                : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: widget.iconColor.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(widget.icon, size: 32, color: widget.iconColor),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.badgeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.badgeColor.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    widget.badge,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: widget.badgeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.55),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.buttonColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  widget.buttonLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegistrationRoutePanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final List<Widget> children;

  const _RegistrationRoutePanel({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.055),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withOpacity(0.26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.66),
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _RegistrationLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _RegistrationLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.11)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFB6C2D1), size: 17),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF94A3B8),
              size: 13,
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final double width;

  const _GlassCard({required this.child, this.width = 480});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;

  const _GlassTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffix,
    this.onSubmitted,
  });

  static final _fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: Colors.white.withOpacity(0.22)),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.7),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onSubmitted: onSubmitted,
          cursorColor: const Color(0xFF22C55E),
          style: const TextStyle(
            color: Color(0xFFFFFFFD),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1E293B),
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Icon(icon, size: 16, color: const Color(0xFFA8B7C8)),
            suffixIcon: suffix,
            border: _fieldBorder,
            enabledBorder: _fieldBorder,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF22C55E),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(icon, size: 18),
        label: Text(
          isLoading ? 'Please wait...' : label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            LucideIcons.alertCircle,
            size: 16,
            color: Colors.redAccent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String message;
  const _InfoBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF38BDF8).withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.38)),
      ),
      child: Row(
        children: [
          const Icon(
            LucideIcons.badgeCheck,
            size: 16,
            color: Color(0xFF38BDF8),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          Icons.arrow_back_ios_new,
          size: 18,
          color: Colors.white.withOpacity(0.75),
        ),
        splashRadius: 18,
      ),
    );
  }
}
