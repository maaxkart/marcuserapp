import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../courses/course_video_screen.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen>
    with TickerProviderStateMixin {

  // ── Palette ───────────────────────────────────────────────────
  static const _violet  = Color(0xFF6C3CE7);
  static const _emerald = Color(0xFF00C87A);
  static const _pink    = Color(0xFFD63CF0);
  static const _ink     = Color(0xFF1A1060);
  static const _muted   = Color(0xFF9FA3B0);
  static const _bg1     = Color(0xFFF8F9FF);
  static const _bg2     = Color(0xFFF1F2FF);
  static const _bg3     = Color(0xFFE9ECFF);

  static const _cardGradients = [
    [Color(0xFF7C3AED), Color(0xFF3B82F6)],
    [Color(0xFF059669), Color(0xFF06D6D6)],
    [Color(0xFFDC2626), Color(0xFF7C3AED)],
    [Color(0xFFF59E0B), Color(0xFFEF4444)],
    [Color(0xFF0096FF), Color(0xFF7B2FFF)],
    [Color(0xFF06D6A0), Color(0xFF118AB2)],
  ];

  late final TabController _tabController;
  late final AnimationController _orbitCtrl;
  late final AnimationController _listCtrl;

  bool isLoading = true;
  List<dynamic> activeCourses    = [];
  List<dynamic> completedCourses = [];

  // ── Real streak state ─────────────────────────────────────────
  int    _streakDays    = 0;
  String _streakMessage = '';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _tabController = TabController(length: 2, vsync: this);
    _orbitCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 9))..repeat();
    _listCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    fetchCourses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _orbitCtrl.dispose();
    _listCtrl.dispose();
    super.dispose();
  }

  Future<void> fetchCourses() async {

    setState(() => isLoading = true);

    final data = await ApiService.getMyCourses();

    if (!mounted) return;

    int streakDays = 0;
    String streakMessage = '';

    // =========================
    // STREAK DATA
    // =========================

    streakDays =
        (data['streak'] as num?)?.toInt() ?? 0;

    streakMessage =
        data['streak_message'] ?? '';

    // =========================
    // FALLBACK MESSAGE
    // =========================

    if (streakMessage.isEmpty) {

      if (streakDays == 0) {

        streakMessage = 'Start learning today!';

      } else if (streakDays == 1) {

        streakMessage = 'Great start! Come back tomorrow';

      } else if (streakDays < 7) {

        streakMessage = 'Keep it up! You\'re building a habit';

      } else if (streakDays < 30) {

        streakMessage = 'You\'re on fire! Amazing streak 🔥';

      } else {

        streakMessage = 'Legendary learner! Unstoppable 🏆';
      }
    }

    // =========================
    // COURSES
    // =========================

    final courses = data['courses'] ?? [];

    setState(() {

      activeCourses = courses
          .where((e) => e['status'] == 'active')
          .toList();

      completedCourses = courses
          .where((e) => e['status'] == 'completed')
          .toList();

      _streakDays = streakDays;

      _streakMessage = streakMessage;

      isLoading = false;
    });

    _listCtrl
      ..reset()
      ..forward();
  }

  List<Color> _gradient(int index) =>
      _cardGradients[index % _cardGradients.length];

  // ── BUILD ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: fetchCourses,
      color: _violet,
      child: Scaffold(
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
              return Stack(children: [
                _orb(_violet.withOpacity(0.09), 300, top: -80, right: -80),
                _orb(_pink.withOpacity(0.06), 240, bottom: 60, left: -70),
                _orb(_emerald.withOpacity(0.05), 180, top: 280, right: -40),
                _floatDot(t,  _violet,  9, phase: 0.0, top: 68,  right: 40),
                _floatDot(t,  _emerald, 6, phase: 2.0, top: 112, right: 82),
                _floatDot(-t, _pink,    5, phase: 1.1, top: 90,  right: 152),
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      _buildStreakBanner(),
                      _buildTabs(),
                      Expanded(
                        child: isLoading
                            ? const Center(child: _Loader())
                            : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildList(activeCourses,
                                label: 'In Progress'),
                            _buildList(completedCourses,
                                label: 'Completed'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]);
            },
          ),
        ),
      ),
    );
  }

  Widget _orb(Color c, double s,
      {double? top, double? bottom, double? left, double? right}) =>
      Positioned(
          top: top, bottom: bottom, left: left, right: right,
          child: Container(width: s, height: s,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [c, Colors.transparent]))));

  Widget _floatDot(double t, Color c, double s,
      {required double phase, required double top, required double right}) =>
      Positioned(
          top:   top   + 24 * math.sin(t + phase),
          right: right + 24 * math.cos(t + phase),
          child: Container(width: s, height: s,
              decoration: BoxDecoration(shape: BoxShape.circle, color: c,
                  boxShadow: [BoxShadow(
                      color: c.withOpacity(0.5), blurRadius: s * 2.5)])));

  // ── Header ────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _violet.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _violet.withOpacity(0.18), width: 1),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 6, height: 6,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: _emerald)),
                  const SizedBox(width: 6),
                  Text('LEARNING', style: TextStyle(fontSize: 10,
                      fontWeight: FontWeight.w800, color: _violet,
                      letterSpacing: 1.2)),
                ]),
              ),
              const SizedBox(height: 10),
              const Text('My Courses', style: TextStyle(fontSize: 32,
                  fontWeight: FontWeight.w900, color: _ink,
                  letterSpacing: -1.2, height: 1.0)),
              const SizedBox(height: 4),
              const Text('Track your progress',
                  style: TextStyle(fontSize: 14, color: _muted)),
            ])),
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: Colors.white, shape: BoxShape.circle,
            border: Border.all(color: _violet.withOpacity(0.15), width: 1),
            boxShadow: [BoxShadow(color: _violet.withOpacity(0.12),
                blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: const Icon(Icons.notifications_none_rounded,
              color: _violet, size: 20),
        ),
      ]),
    );
  }

  // ── Streak Banner (REAL DATA) ─────────────────────────────────

  Widget _buildStreakBanner() {
    // Show nothing while loading (avoid flicker with 0)
    if (isLoading) return const SizedBox(height: 18);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _violet.withOpacity(0.08), width: 1),
          boxShadow: [BoxShadow(color: _violet.withOpacity(0.07),
              blurRadius: 20, offset: const Offset(0, 6))],
        ),
        child: Row(children: [
          // Flame icon box
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFEF4444)]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(
                  color: const Color(0xFFF59E0B).withOpacity(0.35),
                  blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Center(
              // Emoji changes based on streak length
              child: Text(
                _streakDays == 0
                    ? '💤'
                    : _streakDays >= 30
                    ? '🏆'
                    : '🔥',
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Learning Streak', style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w800, color: _ink)),
            const SizedBox(height: 2),
            Text(_streakMessage,
                style: const TextStyle(fontSize: 12, color: _muted)),
          ])),
          // Real streak count from API
          Text(
            _streakDays == 0 ? '—' : '${_streakDays}d',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: _streakDays == 0
                  ? _muted
                  : const Color(0xFFF59E0B),
              letterSpacing: -0.5,
            ),
          ),
        ]),
      ),
    );
  }

  // ── Tabs ──────────────────────────────────────────────────────

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _violet.withOpacity(0.10), width: 1),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            gradient: const LinearGradient(
                colors: [_violet, _pink],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(12),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: _muted,
          labelStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700),
          padding: const EdgeInsets.all(4),
          tabs: const [Tab(text: 'Active'), Tab(text: 'Completed')],
        ),
      ),
    );
  }

  // ── List ──────────────────────────────────────────────────────

  Widget _buildList(List<dynamic> courses, {required String label}) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
            child: _buildSectionLabel(label, courses.length)),
        if (courses.isEmpty)
          SliverFillRemaining(child: _buildEmptyState())
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (_, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: AnimatedBuilder(
                    animation: _listCtrl,
                    builder: (_, child) {
                      final delay = (index * 0.08).clamp(0.0, 0.5);
                      final progress = Curves.easeOutCubic.transform(
                          ((_listCtrl.value - delay) / 0.45)
                              .clamp(0.0, 1.0));
                      return Opacity(
                        opacity: progress,
                        child: Transform.translate(
                            offset: Offset(0, 24 * (1 - progress)),
                            child: child),
                      );
                    },
                    child: _buildCourseCard(courses[index], index),
                  ),
                ),
                childCount: courses.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionLabel(String label, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 14),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 18,
                fontWeight: FontWeight.w800, color: _ink,
                letterSpacing: -0.3)),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _violet.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: _violet.withOpacity(0.15), width: 1),
              ),
              child: Text('$count', style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: _violet)),
            ),
          ]),
    );
  }

  // ── Course Card ───────────────────────────────────────────────

  Widget _buildCourseCard(dynamic course, int index) {
    final grad     = _gradient(index);
    final accent   = grad[0];
    final progress = (course['progress'] as num?)?.toDouble() ?? 0.0;
    final isActive = course['status'] == 'active';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withOpacity(0.10), width: 1),
        boxShadow: [
          BoxShadow(color: accent.withOpacity(0.10),
              blurRadius: 20, offset: const Offset(0, 6)),
          BoxShadow(color: Colors.black.withOpacity(0.04),
              blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(children: [
          Positioned(top: 0, left: 0, right: 0,
              child: Container(height: 1.5,
                  decoration: BoxDecoration(gradient: LinearGradient(
                      colors: [Colors.transparent, grad[0],
                        grad[1], Colors.transparent])))),
          Positioned(top: -20, right: -20,
              child: Container(width: 80, height: 80,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        accent.withOpacity(0.12), Colors.transparent
                      ])))),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(children: [
              Row(children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: grad,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: accent.withOpacity(0.32),
                        blurRadius: 14, offset: const Offset(0, 5))],
                  ),
                  child: const Icon(Icons.play_circle_rounded,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course['title'] ?? '',
                          style: const TextStyle(fontSize: 15,
                              fontWeight: FontWeight.w800, color: _ink,
                              height: 1.3),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 5),
                      Row(children: [
                        Icon(Icons.book_outlined, size: 12, color: _muted),
                        const SizedBox(width: 4),
                        Text(
                            '${course['completed_lessons']}/${course['total_lessons']} lessons',
                            style: TextStyle(fontSize: 12, color: _muted)),
                      ]),
                    ])),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: accent.withOpacity(0.15), width: 1),
                  ),
                  child: Text('${(progress * 100).toInt()}%',
                      style: TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w800, color: accent)),
                ),
              ]),
              const SizedBox(height: 14),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Progress',
                        style: TextStyle(fontSize: 11, color: _muted)),
                    Text(
                        '${course['total_lessons'] - course['completed_lessons']} lessons left',
                        style: TextStyle(fontSize: 11, color: _muted)),
                  ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: accent.withOpacity(0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(grad[0]),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 14),
              if (isActive)
                GestureDetector(
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    await Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => CourseVideoScreen(
                            courseId: course['id'],
                            title: course['title'] ?? ''),
                        transitionsBuilder: (_, anim, __, child) =>
                            FadeTransition(opacity: anim, child: child),
                        transitionDuration:
                        const Duration(milliseconds: 350),
                      ),
                    );

                    fetchCourses();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: grad,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: accent.withOpacity(0.3),
                          blurRadius: 14, offset: const Offset(0, 4))],
                    ),
                    child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Continue Learning', style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800,
                              color: Colors.white)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 16),
                        ]),
                  ),
                ),
              if (!isActive)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF059669), Color(0xFF06D6D6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(
                        color: const Color(0xFF059669).withOpacity(0.3),
                        blurRadius: 14, offset: const Offset(0, 4))],
                  ),
                  child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('Course Completed', style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800,
                            color: Colors.white)),
                      ]),
                ),
            ]),
          ),
        ]),
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 68, height: 68,
          decoration: BoxDecoration(
            color: _violet.withOpacity(0.08), shape: BoxShape.circle,
            border: Border.all(color: _violet.withOpacity(0.15), width: 1),
          ),
          child: const Icon(Icons.school_outlined, color: _violet, size: 30),
        ),
        const SizedBox(height: 14),
        const Text('No courses yet', style: TextStyle(
            color: _ink, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        const Text('Explore and enroll to get started',
            style: TextStyle(color: _muted, fontSize: 13)),
      ]),
    );
  }
}

// ── Loader ────────────────────────────────────────────────────────

class _Loader extends StatelessWidget {
  const _Loader();
  static const _violet = Color(0xFF6C3CE7);
  static const _muted  = Color(0xFF9FA3B0);
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const SizedBox(width: 44, height: 44,
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(_violet),
              strokeWidth: 2.5)),
      const SizedBox(height: 14),
      const Text('Loading…',
          style: TextStyle(color: _muted, fontSize: 13)),
    ],
  );
}