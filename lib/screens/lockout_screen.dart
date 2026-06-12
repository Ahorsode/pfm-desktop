import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../data/local_db.dart';
import '../services/license_service.dart';
import '../utils/id_utils.dart';
import 'offline_terminal_login_screen.dart';
import 'role_dashboard_router.dart';

/// The reason the lockout screen is shown – controls which variant is rendered.
enum LockoutReason {
  /// The 30-day offline trial (or any license period) has expired.
  trialExpired,

  /// System clock was rolled back past the last recorded write time.
  clockTampered,
}

/// Full-screen lockout wall shown when a license expires or the system clock
/// is tampered with.
///
/// **Trial-expired variant**: shows an embedded Supabase login form.
/// On success it calls [LicenseService.applyGracePeriod], runs the farm_id
/// cascade migration, and routes to [MainScaffold] with a 10-day grace period.
///
/// **Clock-tampered variant**: instructs the user to fix the system clock.
class LockoutScreen extends StatefulWidget {
  final LockoutReason reason;
  const LockoutScreen({super.key, required this.reason});

  @override
  State<LockoutScreen> createState() => _LockoutScreenState();
}

class _LockoutScreenState extends State<LockoutScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _error;
  bool _rescued = false; // shows success state briefly before routing

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Clock-tamper: retry check ─────────────────────────────────────────────
  Future<void> _retryClockCheck() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final db = context.read<AppDatabase>();
      final svc = LicenseService(db);
      final status = await svc.checkLicense();
      if (!mounted) return;
      if (status == LicenseStatus.valid || status == LicenseStatus.gracePeriod) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OfflineTerminalLoginScreen()),
        );
      } else {
        setState(() => _error =
            'Clock issue still detected. Please correct your system time and try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Trial-expired: grace period rescue ───────────────────────────────────
  Future<void> _applyGracePeriod() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter your email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final db = context.read<AppDatabase>();
      final svc = LicenseService(db);
      final hardwareId = await getDeviceHardwareId();

      final err = await svc.applyGracePeriod(
        email: email,
        password: password,
        hardwareId: hardwareId,
      );

      if (!mounted) return;

      if (err != null) {
        setState(() => _error = err);
        return;
      }

      // Brief success flash before routing
      setState(() => _rescued = true);
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => RoleDashboardRouter(role: 'OWNER'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Dark background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0A0A0F), Color(0xFF120A1E)],
                ),
              ),
            ),
          ),
          // Pulsing glow behind lock icon
          Center(
            child: AnimatedBuilder(
              animation: _pulse,
              builder: (_, _) => Transform.scale(
                scale: _pulse.value,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        widget.reason == LockoutReason.clockTampered
                            ? const Color(0xFFF59E0B).withOpacity(0.14)
                            : const Color(0xFFEF4444).withOpacity(0.14),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: widget.reason == LockoutReason.clockTampered
                  ? _buildClockTamperVariant()
                  : _buildTrialExpiredVariant(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Clock-tamper variant ──────────────────────────────────────────────────
  Widget _buildClockTamperVariant() {
    return _GlassCard(
      width: 500,
      borderColor: const Color(0xFFF59E0B),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF59E0B).withOpacity(0.15),
            ),
            child: Icon(LucideIcons.clock,
                size: 40, color: const Color(0xFFF59E0B)),
          ),
          const SizedBox(height: 24),
          const Text(
            'System Clock Anomaly Detected',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Your system clock appears to have been set to a time in the past. '
            'This security measure prevents license tampering.\n\n'
            'Please correct your system time in Windows Settings, then click '
            '"Retry" below.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          if (_error != null) ...[
            const SizedBox(height: 20),
            _ErrorBanner(message: _error!),
          ],
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _retryClockCheck,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFF59E0B),
                          ),
                        )
                      : const Icon(LucideIcons.refreshCw, size: 16),
                  label: const Text('Retry Clock Check'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF59E0B),
                    side: const BorderSide(color: Color(0xFFF59E0B)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'HatchLog Security — Anti-Clock-Tamper Protection',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.25),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── Trial-expired variant ─────────────────────────────────────────────────
  Widget _buildTrialExpiredVariant() {
    if (_rescued) return _buildSuccessState();

    return _GlassCard(
      width: 500,
      borderColor: const Color(0xFFEF4444),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Lock icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEF4444).withOpacity(0.15),
              ),
              child: Icon(LucideIcons.keyRound,
                  size: 40, color: const Color(0xFFEF4444)),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Your Trial Has Ended',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Your 30-day offline trial has expired. Sign in to your HatchLog '
            'account below to unlock a 10-day grace period and continue using '
            'your data.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Grace period badge
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF22C55E).withOpacity(0.35)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.shieldCheck,
                      size: 14, color: Color(0xFF22C55E)),
                  SizedBox(width: 6),
                  Text(
                    '10-Day Grace Period After Sign-In',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF22C55E),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Divider
          Divider(color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 20),

          // Login form
          const Text(
            'Sign in with your HatchLog account',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),

          if (_error != null) ...[
            _ErrorBanner(message: _error!),
            const SizedBox(height: 16),
          ],

          _GlassTextField(
            controller: _emailCtrl,
            label: 'Email address',
            hint: 'you@example.com',
            icon: LucideIcons.mail,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _GlassTextField(
            controller: _passwordCtrl,
            label: 'Password',
            hint: '••••••••',
            icon: LucideIcons.lock,
            obscureText: _obscurePassword,
            onSubmitted: (_) => _applyGracePeriod(),
            suffix: IconButton(
              icon: Icon(
                _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                size: 16,
                color: Colors.white54,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _applyGracePeriod,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.black87),
                      ),
                    )
                  : const Icon(LucideIcons.unlock, size: 18),
              label: Text(
                _isLoading ? 'Connecting…' : 'Unlock 10-Day Grace Period',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                foregroundColor: Colors.black87,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your offline data will be securely linked to your cloud account.',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.3),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return _GlassCard(
      width: 460,
      borderColor: const Color(0xFF22C55E),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF22C55E).withOpacity(0.15),
            ),
            child: const Icon(LucideIcons.checkCircle,
                size: 44, color: Color(0xFF22C55E)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Account Linked!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Your data has been migrated to your cloud account.\n'
            'You have 10 days of continued access.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const LinearProgressIndicator(
            color: Color(0xFF22C55E),
            backgroundColor: Colors.white12,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared sub-widgets (mirrors welcome_onboarding_screen.dart style)
// ─────────────────────────────────────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  final Widget child;
  final double width;
  final Color? borderColor;

  const _GlassCard({
    required this.child,
    this.width = 480,
    this.borderColor,
  });

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
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: borderColor?.withOpacity(0.35) ??
                  Colors.white.withOpacity(0.12),
              width: 1.5,
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
            color: Colors.white.withOpacity(0.65),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onSubmitted: onSubmitted,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w600),
              prefixIcon: Icon(icon, size: 16, color: Colors.white60),
              suffixIcon: suffix,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
            ),
          ),
        ),
      ],
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
          const Icon(LucideIcons.alertCircle,
              size: 16, color: Colors.redAccent),
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
