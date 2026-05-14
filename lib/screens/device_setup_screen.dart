import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;
import '../data/sync_engine.dart';
import 'login_screen.dart';

class DeviceSetupScreen extends StatefulWidget {
  const DeviceSetupScreen({super.key});

  @override
  State<DeviceSetupScreen> createState() => _DeviceSetupScreenState();
}

class _DeviceSetupScreenState extends State<DeviceSetupScreen> {
  final _farmIdController = TextEditingController();
  final _manualLinkController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;
  bool _showManualEntry = false;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
    
    // Listen for auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      debugPrint('Auth State Change: ${data.event}');
      if (data.session != null && mounted) {
        setState(() {
          _isAuthenticated = true;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    });
  }

  void _checkAuthState() {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      _isAuthenticated = true;
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'poultry-pms://callback',
      );
      
      // Give the user a hint if they stay on this screen
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && !_isAuthenticated) {
          setState(() => _showManualEntry = true);
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Could not launch Google Login: $e";
        _isLoading = false;
      });
    }
  }
  Future<void> _handleManualLink() async {
    final input = _manualLinkController.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Validation check for "Authorize" URL vs "Callback" URL
      if (input.contains("auth/v1/authorize")) {
        throw Exception("You pasted the 'Start' link. Please finish the login in your browser first, then copy the URL from the page that opens AFTER you choose your account.");
      }

      // 2. Extract code or parse as URI
      Uri uri;
      if (input.contains("code=")) {
        // If it's a full URL, we can parse it directly
        uri = Uri.parse(input);
      } else if (input.startsWith("poultry-pms://")) {
        uri = Uri.parse(input);
      } else if (input.length > 20 && !input.contains(" ")) {
        // If it looks like just the code, try to wrap it
        uri = Uri.parse("poultry-pms://callback/?code=$input");
      } else {
        throw Exception("Invalid link format. Please paste the full URL from your browser address bar.");
      }

      debugPrint('Manual link verification attempt: $uri');
      await Supabase.instance.client.auth.getSessionFromUrl(uri);
      
      if (Supabase.instance.client.auth.currentSession == null) {
        throw Exception("Link verified but no session was found. The link might be expired.");
      }

    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  Future<void> _setupDevice() async {
    final syncEngine = Provider.of<SyncEngine>(context, listen: false);
    final supabase = Supabase.instance.client;
    
    if (_farmIdController.text.isEmpty) {
      setState(() => _errorMessage = "Please enter your Farm ID.");
      return;
    }

    final farmId = int.tryParse(_farmIdController.text);
    if (farmId == null) {
      setState(() => _errorMessage = "Invalid Farm ID. Must be a number.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (!syncEngine.isOnline) {
        throw Exception("Internet connection required for initial device setup.");
      }

      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception("Session expired. Please log in again.");
      }

      final isValid = await supabase.rpc('verify_farm_binding', params: {
        'p_farm_id': farmId,
      });
      
      if (isValid != true) {
        throw Exception("Access Denied: You are not the owner of Farm #$farmId.");
      }

      // 2. Hardware Binding: Capture device ID and register via SECURITY DEFINER RPC
      final deviceInfo = DeviceInfoPlugin();
      String deviceId = "unknown_device";
      String deviceName = "Unknown Desktop";

      if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        deviceId = windowsInfo.deviceId;
        deviceName = windowsInfo.computerName;
      }
      
      await supabase.rpc('register_hardware_device', params: {
        'p_farm_id': farmId,
        'p_device_id': deviceId,
        'p_device_name': deviceName,
      });

      await syncEngine.initialFullSync(farmId);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_bound', true);
      await prefs.setInt('bound_farm_id', farmId);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signOut() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
          _errorMessage = null;
          _farmIdController.clear();
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error signing out: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 30,
                offset: const Offset(0, 15),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(LucideIcons.shieldCheck, size: 64, color: Colors.green),
              const SizedBox(height: 24),
              const Text(
                'Poultry PMS Setup',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _isAuthenticated 
                  ? 'Authenticated! Enter your Farm ID to finish.'
                  : 'Authorize this computer to access your farm data.',
                style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2), // Rose 50
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFECDD3)), // Rose 200
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.alertCircle, size: 18, color: Color(0xFFE11D48)), // Rose 600
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!, 
                              style: const TextStyle(
                                color: Color(0xFF9F1239), // Rose 800
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Debug ID: ${Supabase.instance.client.auth.currentUser?.id ?? 'Not Logged In'}",
                        style: TextStyle(
                          color: const Color(0xFF9F1239).withValues(alpha: 0.6),
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),

              if (!_isAuthenticated) ...[
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  icon: const Icon(LucideIcons.chrome, size: 20),
                  label: Text(_isLoading ? 'Authenticating...' : 'Continue with Google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).cardColor,
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    side: BorderSide(color: Theme.of(context).colorScheme.outline),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                if (_showManualEntry) ...[
                  Text(
                    'Trouble logging in? Paste the URL from your browser below:',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _manualLinkController,
                    decoration: InputDecoration(
                      hintText: 'Paste redirect URL here...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _handleManualLink, // Always allow manual verify to recover
                    child: const Text('Verify Manual Link'),
                  ),
                ] else
                  TextButton(
                    onPressed: () => setState(() => _showManualEntry = true),
                    child: const Text('Trouble logging in?', style: TextStyle(fontSize: 13)),
                  ),
              ] else ...[
                TextField(
                  controller: _farmIdController,
                  decoration: InputDecoration(
                    labelText: 'Farm ID',
                    hintText: 'e.g. 2',
                    prefixIcon: const Icon(LucideIcons.layoutGrid, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  ),
                  keyboardType: TextInputType.number,
                  autofocus: true,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _setupDevice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Complete Binding & Sync', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _isLoading ? null : _signOut,
                  icon: const Icon(LucideIcons.logOut, size: 16),
                  label: const Text('Sign out / Use different account', style: TextStyle(fontSize: 13)),
                  style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
              
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                '🔒 Your Hardware Identity will be bound to this Farm ID.',
                style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
