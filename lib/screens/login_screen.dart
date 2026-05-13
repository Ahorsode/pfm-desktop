import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:provider/provider.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:drift/drift.dart' as drift;
import 'main_scaffold.dart';
import 'change_password_screen.dart';
import 'device_setup_screen.dart';
import '../data/local_db.dart';
import '../data/sync_engine.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum _LoginMode { email, phone }

class _LoginScreenState extends State<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  _LoginMode _mode = _LoginMode.email;
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    
    // Listen for Google Auth completion
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.session != null && mounted) {
        _handleExternalAuth(data.session!.user.email);
      }
    });
  }

  Future<void> _handleExternalAuth(String? email) async {
    if (email == null) return;
    
    setState(() => _isLoading = true);
    try {
      final db = Provider.of<AppDatabase>(context, listen: false);
      final syncEngine = Provider.of<SyncEngine>(context, listen: false);

      // 1. Check if user exists locally
      User? localUser = await (db.select(db.users)..where((t) => t.email.equals(email))).getSingleOrNull();

      if (localUser == null) {
        // 2. Not found? Try to sync users from Supabase
        debugPrint('User $email not found locally, performing emergency sync...');
        await syncEngine.performSync();
        localUser = await (db.select(db.users)..where((t) => t.email.equals(email))).getSingleOrNull();
      }

      if (localUser == null) {
        throw Exception('Account not found on this device or server. Please contact your farm administrator.');
      }

      // 3. Persist session info locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', localUser.id);
      await prefs.setString('user_email', localUser.email ?? '');
      await prefs.setString('user_role', localUser.role);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScaffold()),
      );
    } catch (e) {
      debugPrint('External Auth Error: $e');
      if (mounted) setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final db = Provider.of<AppDatabase>(context, listen: false);
      
      User? localUser;
      if (_mode == _LoginMode.email) {
        localUser = await (db.select(db.users)..where((t) => t.email.equals(identifier))).getSingleOrNull();
      } else {
        localUser = await (db.select(db.users)..where((t) => t.phoneNumber.equals(identifier))).getSingleOrNull();
      }

      if (localUser == null) {
        throw Exception('Account not found on this device. Please ensure you are synchronized.');
      }

      bool isValid = false;
      bool forceChange = localUser.mustChangePassword;

      if (localUser.password == null || localUser.password!.isEmpty) {
        // No password set (e.g. Google auth user on first login)
        if (password == '123456') {
          isValid = true;
          forceChange = true; // Enforce change
        } else {
          throw Exception('Invalid password. First-time users should use 123456.');
        }
      } else {
        // Verify bcrypt hash
        try {
          isValid = BCrypt.checkpw(password, localUser.password!);
        } catch (e) {
          throw Exception('Invalid credentials.');
        }
      }

      if (!isValid) {
        throw Exception('Invalid password.');
      }

      // Persist session info locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', localUser.id);
      await prefs.setString('user_email', localUser.email ?? '');
      await prefs.setString('user_role', localUser.role);

      if (!mounted) return;

      if (forceChange) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ChangePasswordScreen(userId: localUser!.id),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScaffold()),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
      
      // Auth state listener in main.dart or similar will handle the result
    } catch (e) {
      setState(() {
        _errorMessage = "Could not launch Google Login: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo & title
                const Icon(Icons.agriculture, size: 48, color: Color(0xFF16A34A)),
                const SizedBox(height: 16),
                const Text(
                  'Agri-ERP Desktop',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Sign in to access your farm dashboard',
                  style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // Email / Phone toggle
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _ModeTab(
                        label: 'Email',
                        icon: LucideIcons.mail,
                        selected: _mode == _LoginMode.email,
                        onTap: () => setState(() {
                          _mode = _LoginMode.email;
                          _identifierController.clear();
                        }),
                      ),
                      _ModeTab(
                        label: 'Phone',
                        icon: LucideIcons.smartphone,
                        selected: _mode == _LoginMode.phone,
                        onTap: () => setState(() {
                          _mode = _LoginMode.phone;
                          _identifierController.clear();
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Error banner
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.alertCircle, size: 16, color: Colors.red[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red[700], fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Identifier field
                TextField(
                  controller: _identifierController,
                  keyboardType: _mode == _LoginMode.phone
                      ? TextInputType.phone
                      : TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: _mode == _LoginMode.email ? 'Email address' : 'Phone number',
                    hintText: _mode == _LoginMode.email
                        ? 'you@example.com'
                        : '+1 555 000 0000',
                    prefixIcon: Icon(
                      _mode == _LoginMode.email ? LucideIcons.mail : LucideIcons.phone,
                      size: 18,
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                  ),
                ),
                const SizedBox(height: 14),

                // Password field
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onSubmitted: (_) => _isLoading ? null : _login(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: '••••••••',
                    prefixIcon: const Icon(LucideIcons.lock, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                        size: 18,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                  ),
                ),

                // Hint for Google auth users
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Google-account holders: use 123456 as your first-time password.',
                    style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: 28),

                // Sign in button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Sign In',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                // Google Sign In Button
                SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://www.gstatic.com/images/branding/product/1x/gsa_512dp.png',
                          height: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Continue with Google',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Switch Farm / Unbind
                TextButton(
                  onPressed: _isLoading ? null : _showUnbindConfirmation,
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  child: const Text('Switch Farm / Unbind Device'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUnbindConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Switch Farm?'),
        content: const Text(
            'This will unbind the device and DELETE all local farm data. You will need to re-scan the setup QR code to use this laptop again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _unbindDevice();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Confirm Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _unbindDevice() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get database and sync engine before they are potentially disposed by the cleanup
      final syncEngine = context.read<SyncEngine>();
      final database = context.read<AppDatabase>();

      // Stop any background activities
      syncEngine.dispose(); // Cancels timers
      await database.close(); // Releases OS file handles

      // Small delay to ensure OS releases the lock
      await Future.delayed(const Duration(milliseconds: 300));

      await prefs.clear();

      // Delete the SQLite database file
      final docsDir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(docsDir.path, 'poultry_pms.sqlite');
      final dbFile = File(dbPath);
      
      if (await dbFile.exists()) {
        try {
          await dbFile.delete();
        } catch (e) {
          debugPrint('Initial delete attempt failed: $e. Retrying after delay...');
          await Future.delayed(const Duration(milliseconds: 500));
          if (await dbFile.exists()) {
            await dbFile.delete();
          }
        }
      }

      if (!mounted) return;
      
      // Return to binding screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DeviceSetupScreen()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Failed to unbind: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

/// Tab widget for the Email / Phone toggle strip
class _ModeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Theme.of(context).cardColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: selected ? const Color(0xFF16A34A) : Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? const Color(0xFF16A34A) : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
