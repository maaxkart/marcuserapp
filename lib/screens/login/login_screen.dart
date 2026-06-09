import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import '../../main_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Same palette as SplashScreen ─────────────────────────────────────────
  static const _violet  = Color(0xFF6C3CE7);
  static const _emerald = Color(0xFF00FFA3);
  static const _pink    = Color(0xFFD63CF0);
  static const _ink     = Color(0xFF1A1060);
  static const _hint    = Color(0xFFC5C0E8);
  static const _muted   = Color(0xFF9FA3B0);

  // Background gradient — identical to splash
  static const _bg1 = Color(0xFFF8F9FF);
  static const _bg2 = Color(0xFFF1F2FF);
  static const _bg3 = Color(0xFFE9ECFF);

  late final AnimationController _orbitCtrl;
  late final AnimationController _entryCtrl;

  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus  = FocusNode();

  bool _obscure      = true;
  bool _loading      = false;
  bool _emailFocused = false;
  bool _passFocused  = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _fade  = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    _emailFocus.addListener(() => setState(() => _emailFocused = _emailFocus.hasFocus));
    _passFocus.addListener(()  => setState(() => _passFocused  = _passFocus.hasFocus));
  }

  @override
  void dispose() {
    _orbitCtrl.dispose();
    _entryCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_bg1, _bg2, _bg3],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: AnimatedBuilder(
          animation: _orbitCtrl,
          builder: (_, __) {
            final t = _orbitCtrl.value * 2 * math.pi;
            return Stack(
              children: [
                // Background glow orbs — mirroring splash aesthetic
                _buildOrb(_violet.withOpacity(0.08), 320, top: -80, right: -80),
                _buildOrb(_emerald.withOpacity(0.07), 280, bottom: -60, left: -60),
                _buildOrb(_pink.withOpacity(0.06), 200, top: null, left: -40),

                // Floating orbit dots (same as splash)
                _buildFloatingDot(t, _violet, 10, radius: 180, phase: 0,   top: 80,  right: 40),
                _buildFloatingDot(t, _emerald, 7,  radius: 140, phase: 2.1, top: 140, right: 80),

                SafeArea(
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: Center(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 32),
                          child: _buildCard(t),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Orb helper ────────────────────────────────────────────────────────────

  Widget _buildOrb(Color color, double size,
      {double? top, double? bottom, double? left, double? right}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      ),
    );
  }

  // ── Floating orbit dot (matches splash _dot) ──────────────────────────────

  Widget _buildFloatingDot(double t, Color color, double size,
      {required double radius, required double phase,
        required double top, required double right}) {
    return Positioned(
      top:   top   + 30 * math.sin(t + phase),
      right: right + 30 * math.cos(t + phase),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.6), blurRadius: size * 2),
          ],
        ),
      ),
    );
  }

  // ── Card ──────────────────────────────────────────────────────────────────

  Widget _buildCard(double t) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _violet.withOpacity(0.10), width: 1),
        boxShadow: [
          BoxShadow(
            color: _violet.withOpacity(0.12),
            offset: const Offset(0, 1),
            blurRadius: 0,
          ),
          BoxShadow(
            color: _violet.withOpacity(0.08),
            blurRadius: 60,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: _violet.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Top shimmer line — violet → emerald → pink, same as splash progress bar
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                height: 1,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, _violet, _emerald, _pink, Colors.transparent],
                  ),
                ),
              ),
            ),

            // Small orbit dots inside card corner (echo of splash dots)
            Positioned(
              top: 20,
              right: 24,
              child: _orbitDot(_violet, 8, t, offset: 4),
            ),
            Positioned(
              top: 44,
              right: 48,
              child: _orbitDot(_emerald, 5, -t, offset: 3),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeading(),
                  const SizedBox(height: 26),
                  _buildLabel('Email'),
                  const SizedBox(height: 8),
                  _buildEmailField(),
                  const SizedBox(height: 16),
                  _buildLabel('Password'),
                  const SizedBox(height: 8),
                  _buildPasswordField(),
                  const SizedBox(height: 8),
                  _buildForgot(),
                  const SizedBox(height: 24),
                  _buildSignInButton(),
                  const SizedBox(height: 22),
                 // _buildFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Animated corner dot ───────────────────────────────────────────────────

  Widget _orbitDot(Color color, double size, double t, {double offset = 5}) {
    return Transform.translate(
      offset: Offset(math.cos(t) * offset, math.sin(t) * offset),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.6), blurRadius: size * 1.5),
          ],
        ),
      ),
    );
  }

  // ── Heading ───────────────────────────────────────────────────────────────

  Widget _buildHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome back',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: _ink,
            letterSpacing: -0.5,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sign in to your campus account',
          style: TextStyle(fontSize: 13, color: _muted),
        ),
      ],
    );
  }

  // ── Label ─────────────────────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _violet,
        letterSpacing: 0.8,
      ),
    );
  }

  // ── Email field ───────────────────────────────────────────────────────────

  Widget _buildEmailField() {
    return _Field(
      isFocused: _emailFocused,
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(Icons.alternate_email_rounded, size: 16,
              color: _emailFocused ? _violet : _hint),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _emailCtrl,
              focusNode: _emailFocus,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _ink),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'you@institution.edu',
                hintStyle: TextStyle(color: _hint.withOpacity(0.7), fontSize: 13.5),
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }

  // ── Password field ────────────────────────────────────────────────────────

  Widget _buildPasswordField() {
    return _Field(
      isFocused: _passFocused,
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(Icons.lock_outline_rounded, size: 16,
              color: _passFocused ? _violet : _hint),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _passCtrl,
              focusNode: _passFocus,
              obscureText: _obscure,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _ink),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter your password',
                hintStyle: TextStyle(color: _hint.withOpacity(0.7), fontSize: 13.5),
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 17,
              color: _hint,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
            padding: const EdgeInsets.only(right: 6),
          ),
        ],
      ),
    );
  }

  // ── Forgot ────────────────────────────────────────────────────────────────

  Widget _buildForgot() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(
          'Forgot password?',
          style: TextStyle(color: _violet, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ── Sign in button — gradient matches splash progress bar ──────────────────

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [_violet, _pink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: _violet.withOpacity(0.35),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: _violet.withOpacity(0.20),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: MaterialButton(
          onPressed: _loading ? null : _handleLogin,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          splashColor: Colors.white.withOpacity(0.2),
          child: _loading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
          )
              : const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sign in',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(width: 8),
              _ArrowChip(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Center(
      child: Text.rich(
        TextSpan(
          text: 'New to MARC? ',
          style: TextStyle(color: _muted, fontSize: 13),
          children: [
            WidgetSpan(
              child: GestureDetector(
                onTap: () {},
                child: const Text(
                  'Request campus access',
                  style: TextStyle(
                    color: _violet,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    HapticFeedback.lightImpact();

    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Enter email & password");
      return;
    }

    setState(() => _loading = true);

    try {
      final res = await ApiService.login(
        email: email,
        password: password,
      );

      setState(() => _loading = false);

      if (res['success'] == true) {
        final data = res['data'];
        final user = data["user"];


        final prefs = await SharedPreferences.getInstance();

        await prefs.setString("token", data["token"] ?? "");
        await prefs.setString("name", user?["name"] ?? "");
        await prefs.setString("email", user?["email"] ?? "");
        await prefs.setString("role", user?["role"] ?? "");

        print("FULL RESPONSE: $res");
        print("DATA PART: ${res['data']}");

        if (data['role'] == 'student') {
          _showMessage("Student login successful 🎓");
        } else {
          _showMessage("Login successful ✅");
        }

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainNavigation(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );

      } else {
        _showMessage(res['message'] ?? "Login failed");
      }

    } catch (e) {
      setState(() => _loading = false);
      _showMessage("Something went wrong. Try again.");
    }
  }
}

// ── Field wrapper ─────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final Widget child;
  final bool isFocused;
  const _Field({required this.child, required this.isFocused});

  static const _violet = Color(0xFF6C3CE7);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: isFocused ? Colors.white : _violet.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFocused ? _violet : _violet.withOpacity(0.12),
          width: 1.5,
        ),
        boxShadow: isFocused
            ? [BoxShadow(color: _violet.withOpacity(0.10), blurRadius: 0, spreadRadius: 3)]
            : [],
      ),
      child: child,
    );
  }
}

// ── Arrow chip on button ──────────────────────────────────────────────────────

class _ArrowChip extends StatelessWidget {
  const _ArrowChip();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
    );
  }
}