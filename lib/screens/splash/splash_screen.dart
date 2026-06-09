import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main_navigation.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _orbitCtrl;
  late AnimationController _logoCtrl;
  late AnimationController _loaderCtrl;

  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _loaderFade;
  late Animation<double> _progress;

  static const _violet  = Color(0xFF6C3CE7);
  static const _emerald = Color(0xFF00FFA3);
  static const _pink    = Color(0xFFD63CF0);

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _orbitCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
    _logoCtrl   = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _loaderCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));

    _logoFade  = CurvedAnimation(parent: _logoCtrl, curve: const Interval(0, .7, curve: Curves.easeOut));
    _logoScale = Tween<double>(begin: .6, end: 1).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));
    _loaderFade = CurvedAnimation(parent: _logoCtrl, curve: const Interval(.6, 1, curve: Curves.easeOut));
    _progress = CurvedAnimation(parent: _loaderCtrl, curve: Curves.easeInOut);

    _runSequence();
  }

  Future<void> _runSequence() async {

    await Future.delayed(
      const Duration(milliseconds: 200),
    );

    if (!mounted) return;

    _logoCtrl.forward();

    await Future.delayed(
      const Duration(milliseconds: 700),
    );

    if (!mounted) return;

    _loaderCtrl.forward();

    await Future.delayed(
      const Duration(milliseconds: 3200),
    );

    if (!mounted) return;

    // ==========================================
    // CHECK LOGIN
    // ==========================================

    final prefs =
    await SharedPreferences.getInstance();

    final token =
    prefs.getString("token");

    // ==========================================
    // AUTO LOGIN
    // ==========================================

    final nextScreen =

    token != null &&
        token.isNotEmpty

        ? const MainNavigation()

        : const LoginScreen();

    Navigator.of(context).pushReplacement(

      PageRouteBuilder(

        pageBuilder:
            (_, __, ___) => nextScreen,

        transitionsBuilder:
            (_, anim, __, child) =>

            FadeTransition(
              opacity: anim,
              child: child,
            ),

        transitionDuration:
        const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  void dispose() {
    _orbitCtrl.dispose();
    _logoCtrl.dispose();
    _loaderCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF8F9FF),
              Color(0xFFF1F2FF),
              Color(0xFFE9ECFF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: AnimatedBuilder(
          animation: Listenable.merge([_orbitCtrl, _logoCtrl, _loaderCtrl]),
          builder: (_, __) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// 🔥 LOGO ONLY (NO BOX)
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: _buildLogo(size),
                  ),
                ),

                const SizedBox(height: 80),

                /// ⚡ LOADER
                FadeTransition(
                  opacity: _loaderFade,
                  child: _buildLoader(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(Size size) {
    final s = size.width * 0.35;
    final t = _orbitCtrl.value * 2 * math.pi;

    return SizedBox(
      width: s + 100,
      height: s + 100,
      child: Stack(
        alignment: Alignment.center,
        children: [

          /// 🌌 Soft Glow Background
          Container(
            width: s * 1.8,
            height: s * 1.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _violet.withOpacity(.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          /// 🔄 Orbit Dot
          Transform.translate(
            offset: Offset(60 * math.cos(t), 60 * math.sin(t)),
            child: _dot(_violet, 10),
          ),

          /// 🔄 Orbit Dot 2
          Transform.translate(
            offset: Offset(45 * math.cos(-t), 45 * math.sin(-t)),
            child: _dot(_emerald, 7),
          ),

          /// ✨ Floating Logo (MAIN)
          Transform.translate(
            offset: Offset(0, math.sin(t) * 6),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _violet.withOpacity(.35),
                    blurRadius: 50,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/marc_logo.png',
                width: s,
                height: s,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.flutter_dash,
                  size: 80,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoader() {
    return Column(
      children: [

        /// ⚡ PREMIUM BAR
        Container(
          width: 180,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.black.withOpacity(.05),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: _progress.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [
                        _emerald,
                        _violet,
                        _pink,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _violet.withOpacity(.6),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        Text(
          '${(_progress.value * 100).toInt()}%',
          style: const TextStyle(
            color: Color(0xFF9FA3B0),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _dot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(.6),
            blurRadius: size * 2,
          ),
        ],
      ),
    );
  }
}