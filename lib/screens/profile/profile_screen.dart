import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import 'edit_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notifications_screen.dart';
import 'privacy_security_screen.dart';
import 'help_support_screen.dart';
import '../login/login_screen.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {

  // ── Same palette as Splash & Login ───────────────────────────────────────
  static const _violet  = Color(0xFF6C3CE7);
  static const _pink    = Color(0xFFD63CF0);
  static const _emerald = Color(0xFF00FFA3);
  static const _gold    = Color(0xFFFFB800);
  static const _ink     = Color(0xFF1A1060);
  static const _muted   = Color(0xFF9FA3B0);
  static const _surface = Color(0xFFF4F5FF);

  late final AnimationController _orbCtrl;
  String userName = "";
  String userEmail = "";
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _loadUser();

  }

  @override
  void dispose() {
    _orbCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      userName = prefs.getString("name") ?? "User";
      userEmail = prefs.getString("email") ?? "No email";
      isLoading = false;
    });
  }

  // ── Settings data ─────────────────────────────────────────────────────────

  final _accountItems = const [
    _SettingItem(icon: Icons.person_outline_rounded,    label: 'Edit Profile',       sub: 'Name,email',        color: Color(0xFF6C3CE7), badge: null),
    _SettingItem(icon: Icons.notifications_outlined,    label: 'Notifications',       sub: 'Push, email, SMS',        color: Color(0xFFFFB800), badge: '3 new'),
  ];

  final _supportItems = const [
    _SettingItem(icon: Icons.shield_outlined,           label: 'Privacy Policy',  sub: 'Password, 2FA, data',    color: Color(0xFF10B981), badge: null),
    _SettingItem(icon: Icons.help_outline_rounded,      label: 'Help & Support',      sub: 'FAQs, contact us',       color: Color(0xFF3B82F6), badge: null),
  ];

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel('Account'),
                  const SizedBox(height: 12),
                  _buildSettingsGroup(_accountItems),
                  const SizedBox(height: 20),
                  _buildSectionLabel('Support'),
                  const SizedBox(height: 12),
                  _buildSettingsGroup(_supportItems),
                  const SizedBox(height: 20),
                  _buildSignOutCard(),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _orbCtrl,
      builder: (_, __) {
        final t = _orbCtrl.value * 2 * math.pi;
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFFFFF), Color(0xFFF5F7FF)],
            ),
          ),
          child: Stack(
            children: [
              // Background orbs — same style as splash/login
              Positioned(
                top: -70,
                right: -50,
                child: _Orb(color: _violet.withOpacity(0.07), size: 220),
              ),
              Positioned(
                bottom: -40,
                left: -40,
                child: _Orb(color: _pink.withOpacity(0.06), size: 160),
              ),
              // Floating orbit dots — echo of splash
              Positioned(
                top: 40 + 8 * math.sin(t),
                right: 30 + 8 * math.cos(t),
                child: _Dot(color: _violet, size: 7),
              ),
              Positioned(
                top: 64 + 6 * math.sin(-t),
                right: 58 + 6 * math.cos(-t),
                child: _Dot(color: _emerald, size: 5),
              ),

              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(child: _buildAvatar()),
                      const SizedBox(height: 14),
                      isLoading
                          ? const CircularProgressIndicator()
                          : Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                          letterSpacing: -0.6,
                        ),
                      ),

                      const SizedBox(height: 4),

                      isLoading
                          ? const SizedBox()
                          : Text(
                        userEmail,
                        style: TextStyle(fontSize: 13.5, color: _muted),
                      ),
                      const SizedBox(height: 10),
                      Center(child: _buildGoldBadge()),

                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Avatar ────────────────────────────────────────────────────────────────

  Widget _buildAvatar() {

    // =====================================================
    // GET USER INITIALS
    // =====================================================

    String initials = "U";

    if (userName.trim().isNotEmpty) {

      final parts =
      userName.trim().split(" ");

      if (parts.length == 1) {

        initials =
            parts[0][0].toUpperCase();
      }

      else {

        initials =
            parts[0][0].toUpperCase() +
                parts[1][0].toUpperCase();
      }
    }

    return Stack(

      alignment: Alignment.center,

      children: [

        // =================================================
        // PREMIUM GLOW RING
        // =================================================

        Container(

          width: 110,
          height: 110,

          decoration: BoxDecoration(

            shape: BoxShape.circle,

            gradient:
            const LinearGradient(

              colors: [

                _violet,

                _pink,

                _emerald,
              ],

              begin: Alignment.topLeft,

              end: Alignment.bottomRight,
            ),

            boxShadow: [

              BoxShadow(

                color:
                _violet.withOpacity(.35),

                blurRadius: 28,

                spreadRadius: 4,
              ),
            ],
          ),

          padding:
          const EdgeInsets.all(3),

          child: Container(

            decoration:
            const BoxDecoration(

              shape: BoxShape.circle,

              gradient:
              LinearGradient(

                colors: [

                  _violet,

                  _pink,
                ],

                begin: Alignment.topLeft,

                end: Alignment.bottomRight,
              ),
            ),

            child: Container(

              decoration:
              BoxDecoration(

                shape: BoxShape.circle,

                border: Border.all(

                  color: Colors.white,

                  width: 3,
                ),
              ),

              child: CircleAvatar(

                backgroundColor:
                Colors.transparent,

                child: Text(

                  initials,

                  style: const TextStyle(

                    fontSize: 30,

                    fontWeight:
                    FontWeight.w900,

                    color: Colors.white,

                    letterSpacing: -1,
                  ),
                ),
              ),
            ),
          ),
        ),

        // =================================================
        // ONLINE INDICATOR
        // =================================================

        Positioned(

          top: 10,
          right: 10,

          child: Container(

            height: 18,
            width: 18,

            decoration: BoxDecoration(

              color: const Color(0xff00C853),

              shape: BoxShape.circle,

              border: Border.all(

                color: Colors.white,

                width: 3,
              ),

              boxShadow: [

                BoxShadow(

                  color:
                  Colors.green.withOpacity(.5),

                  blurRadius: 10,
                ),
              ],
            ),
          ),
        ),

        // =================================================
        // EDIT BUTTON
        // =================================================

        Positioned(

          bottom: 0,
          right: 0,

          child: GestureDetector(

            onTap: () async {

              final refresh =
              await Navigator.push(

                context,

                MaterialPageRoute(

                  builder: (_) =>
                      EditProfileScreen(

                        name: userName,

                        email: userEmail,
                      ),
                ),
              );

              if (refresh == true) {

                _loadUser();
              }
            },

            child: Container(

              width: 34,
              height: 34,

              decoration: BoxDecoration(

                color: _gold,

                shape: BoxShape.circle,

                border: Border.all(

                  color: Colors.white,

                  width: 3,
                ),

                boxShadow: [

                  BoxShadow(

                    color:
                    _gold.withOpacity(.45),

                    blurRadius: 10,

                    offset:
                    const Offset(0, 3),
                  ),
                ],
              ),

              child: const Icon(

                Icons.edit_rounded,

                color: Colors.white,

                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Gold badge ────────────────────────────────────────────────────────────

  Widget _buildGoldBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: _gold.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withOpacity(0.35), width: 1),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('⭐', style: TextStyle(fontSize: 13)),
          SizedBox(width: 6),
          Text(
            'Premium Member',
            style: TextStyle(
              color: Color(0xFFB45309),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats strip ───────────────────────────────────────────────────────────



  Widget _buildStat(String val, String lbl,
      {bool isFirst = false, bool isLast = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft:     Radius.circular(isFirst ? 18 : 0),
            bottomLeft:  Radius.circular(isFirst ? 18 : 0),
            topRight:    Radius.circular(isLast  ? 18 : 0),
            bottomRight: Radius.circular(isLast  ? 18 : 0),
          ),
        ),
        child: Column(
          children: [
            Text(val,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: _ink, letterSpacing: -0.5)),
            const SizedBox(height: 2),
            Text(lbl.toUpperCase(),
                style: TextStyle(
                    fontSize: 9.5, fontWeight: FontWeight.w700, color: _muted, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, color: _violet.withOpacity(0.07), margin: const EdgeInsets.symmetric(vertical: 12));
  }

  // ── Section label ─────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _violet,
          letterSpacing: 1,
        ),
      ),
    );
  }

  // ── Membership card ───────────────────────────────────────────────────────



  // ── Settings group ────────────────────────────────────────────────────────

  Widget _buildSettingsGroup(List<_SettingItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _violet.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(color: _violet.withOpacity(0.06), blurRadius: 24, offset: const Offset(0, 4)),
          BoxShadow(color: _violet.withOpacity(0.10), offset: const Offset(0, 1), blurRadius: 0),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 18),
          color: _violet.withOpacity(0.06),
        ),
        itemBuilder: (_, i) => _buildSettingRow(items[i]),
      ),
    );
  }

  Widget _buildSettingRow(_SettingItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {

          // =========================================
          // EDIT PROFILE
          // =========================================

          if (item.label == 'Edit Profile') {

            final refresh =
            await Navigator.push(

              context,

              MaterialPageRoute(

                builder: (_) =>
                    EditProfileScreen(

                      name: userName,

                      email: userEmail,
                    ),
              ),
            );

            if (refresh == true) {

              _loadUser();
            }
          }

          // =========================================
          // NOTIFICATIONS
          // =========================================

          else if (
          item.label == 'Notifications'
          ) {

            Navigator.push(

              context,

              MaterialPageRoute(

                builder: (_) =>
                const NotificationsScreen(),
              ),
            );
          }

          // =========================================
          // PRIVACY
          // =========================================

          else if (
          item.label ==
              'Privacy Policy'
          ) {

            Navigator.push(

              context,

              MaterialPageRoute(

                builder: (_) =>
                const PrivacySecurityScreen(),
              ),
            );
          }

          // =========================================
          // HELP
          // =========================================

          else if (
          item.label ==
              'Help & Support'
          ) {

            Navigator.push(

              context,

              MaterialPageRoute(

                builder: (_) =>
                const HelpSupportScreen(),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(22),
        splashColor: _violet.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              // Icon chip
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color, size: 20),
              ),
              const SizedBox(width: 14),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.label,
                        style: const TextStyle(
                            fontSize: 14.5, fontWeight: FontWeight.w600, color: _ink)),
                    if (item.sub != null)
                      Text(item.sub!,
                          style: TextStyle(fontSize: 11.5, color: _muted)),
                  ],
                ),
              ),
              // Badge or arrow
              if (item.badge != null)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.badge!,
                    style: const TextStyle(
                        fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFFEF4444)),
                  ),
                ),
              Icon(Icons.arrow_forward_ios_rounded, size: 13, color: _muted.withOpacity(0.7)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sign out card ─────────────────────────────────────────────────────────

  Widget _buildSignOutCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.10)),
        boxShadow: [
          BoxShadow(color: const Color(0xFFEF4444).withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {

            final prefs =
            await SharedPreferences.getInstance();

            await prefs.clear();

            if (!mounted) return;

            Navigator.pushAndRemoveUntil(

              context,

              MaterialPageRoute(

                builder: (_) =>
                const LoginScreen(),
              ),

                  (route) => false,
            );
          },
          borderRadius: BorderRadius.circular(22),
          splashColor: const Color(0xFFEF4444).withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Sign Out',
                  style: TextStyle(
                      fontSize: 14.5, fontWeight: FontWeight.w600, color: Color(0xFFEF4444)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────

class _SettingItem {
  final IconData icon;
  final String label;
  final String? sub;
  final Color color;
  final String? badge;
  const _SettingItem({
    required this.icon,
    required this.label,
    this.sub,
    required this.color,
    this.badge,
  });
}

// ── Shared primitives (same as Splash/Login) ──────────────────────────────────

class _Orb extends StatelessWidget {
  final Color color;
  final double size;
  const _Orb({required this.color, required this.size});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final double size;
  const _Dot({required this.color, required this.size});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: size * 2)],
      ),
    );
  }
}