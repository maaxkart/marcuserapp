import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import '../courses/course_video_screen.dart';
class CourseListScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CourseListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen>
    with TickerProviderStateMixin {

  // ── Palette (light — same as login) ──────────────────────────────────────
  static const _violet  = Color(0xFF6C3CE7);
  static const _emerald = Color(0xFF00C87A);
  static const _pink    = Color(0xFFD63CF0);
  static const _ink     = Color(0xFF1A1060);
  static const _muted   = Color(0xFF9FA3B0);
  static const _hint    = Color(0xFFC5C0E8);

  static const _bg1 = Color(0xFFF8F9FF);
  static const _bg2 = Color(0xFFF1F2FF);
  static const _bg3 = Color(0xFFE9ECFF);

  List<dynamic> courses = [];
  bool isLoading = true;

  late final AnimationController _orbitCtrl;
  late final AnimationController _listCtrl;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _orbitCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 8))..repeat();
    _listCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    fetchCourses();
  }

  @override
  void dispose() {
    _orbitCtrl.dispose();
    _listCtrl.dispose();
    super.dispose();
  }

  Future<void> fetchCourses() async {
    try {
      final data = await ApiService.getCoursesByCategory(widget.categoryId);
      setState(() {
        courses = data;
        isLoading = false;
      });
      _listCtrl.forward();
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Color _accentFor(int i) => [_violet, _pink, _emerald][i % 3];

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
                // Background glow orbs
                _orb(_violet.withOpacity(0.08), 320, top: -80,  right: -80),
                _orb(_pink.withOpacity(0.06),   260, bottom: 80, left: -70),
                _orb(_emerald.withOpacity(0.05), 200, top: 280,  right: -50),

                // Floating dots
                _floatDot(t,  _violet,  9, phase: 0.0, top: 60,  right: 30),
                _floatDot(t,  _emerald, 6, phase: 1.8, top: 120, right: 65),
                _floatDot(-t, _pink,    5, phase: 0.9, top: 85,  right: 115),

                SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(),
                      Expanded(child: _buildBody()),
                    ],
                  ),
                ),
              ],
            );
          },
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
          top: top + 24 * math.sin(t + phase),
          right: right + 24 * math.cos(t + phase),
          child: Container(width: s, height: s,
              decoration: BoxDecoration(shape: BoxShape.circle, color: c,
                  boxShadow: [BoxShadow(color: c.withOpacity(0.5), blurRadius: s * 2.5)])));

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: _violet.withOpacity(0.15), width: 1),
                    boxShadow: [BoxShadow(color: _violet.withOpacity(0.08),
                        blurRadius: 12, offset: const Offset(0, 3))]),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: _violet, size: 16)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.categoryName,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                          color: _ink, letterSpacing: -0.5, height: 1.1)),
                  if (!isLoading)
                    Text('${courses.length} course${courses.length == 1 ? '' : 's'} available',
                        style: TextStyle(fontSize: 12, color: _muted,
                            fontWeight: FontWeight.w500)),
                ]),
          ),
          // Filter button
          Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_violet, _pink],
                      begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [BoxShadow(color: _violet.withOpacity(0.35),
                      blurRadius: 16, offset: const Offset(0, 4))]),
              child: const Icon(Icons.tune_rounded, color: Colors.white, size: 18)),
        ],
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(width: 44, height: 44,
              child: CircularProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation(_violet), strokeWidth: 2.5)),
          const SizedBox(height: 14),
          Text('Loading courses…', style: TextStyle(color: _muted, fontSize: 13)),
        ]),
      );
    }

    if (courses.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 68, height: 68,
              decoration: BoxDecoration(
                  color: _violet.withOpacity(0.08), shape: BoxShape.circle,
                  border: Border.all(color: _violet.withOpacity(0.15), width: 1)),
              child: Icon(Icons.school_outlined, color: _violet, size: 30)),
          const SizedBox(height: 14),
          const Text('No courses yet',
              style: TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Check back soon for new content',
              style: TextStyle(color: _muted, fontSize: 13)),
        ]),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _listCtrl,
          builder: (_, child) {
            final delay    = (index * 0.07).clamp(0.0, 0.56);
            final progress = Curves.easeOutCubic.transform(
                ((_listCtrl.value - delay) / 0.44).clamp(0.0, 1.0));
            return Opacity(opacity: progress,
                child: Transform.translate(
                    offset: Offset(0, 22 * (1 - progress)), child: child));
          },
          child: _buildCard(courses[index], index),
        );
      },
    );
  }

  // ── Course card ───────────────────────────────────────────────────────────

  Widget _buildCard(Map<String, dynamic> course, int index) {
    final accent   = _accentFor(index);
    final price    = course['price'];
    final priceStr = (price == null || price == 0 || price == '0') ? 'Free' : '₹$price';
    final isFree   = priceStr == 'Free';

    return GestureDetector(
      onTap: () async {

        HapticFeedback.lightImpact();

        await ApiService.enrollCourse(course['id']);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CourseVideoScreen(
              courseId: course['id'],
              title: course['title'] ?? 'Course',
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withOpacity(0.12), width: 1),
            boxShadow: [
              BoxShadow(color: accent.withOpacity(0.08), blurRadius: 20,
                  offset: const Offset(0, 6)),
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6,
                  offset: const Offset(0, 2)),
            ]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(children: [
            // Top shimmer line
            Positioned(top: 0, left: 0, right: 0,
                child: Container(height: 1.5,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Colors.transparent, accent, accent.withOpacity(0.3),
                          Colors.transparent
                        ])))),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Thumbnail
                Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: accent.withOpacity(0.06),
                        border: Border.all(color: accent.withOpacity(0.15), width: 1)),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: course['thumbnail'] != null
                            ? Image.network(course['thumbnail'], fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _thumbFallback(accent))
                            : _thumbFallback(accent))),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course['title'] ?? 'Untitled',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                                color: _ink, height: 1.3),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        if (course['tutor'] != null)
                          Row(children: [
                            Icon(Icons.person_outline_rounded, size: 12, color: _muted),
                            const SizedBox(width: 4),
                            Expanded(child: Text(course['tutor'],
                                style: TextStyle(fontSize: 11, color: _muted,
                                    fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis)),
                          ]),
                        const SizedBox(height: 10),
                        Row(children: [
                          // Price badge
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                  color: isFree
                                      ? _emerald.withOpacity(0.10)
                                      : _violet.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: isFree
                                          ? _emerald.withOpacity(0.3)
                                          : _violet.withOpacity(0.2),
                                      width: 1)),
                              child: Text(priceStr,
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                                      color: isFree ? _emerald : _violet))),
                          const Spacer(),
                          if (course['rating'] != null) ...[
                            Icon(Icons.star_rounded, size: 13,
                                color: Colors.amber[600]),
                            const SizedBox(width: 3),
                            Text(course['rating'].toString(),
                                style: TextStyle(fontSize: 11,
                                    fontWeight: FontWeight.w600, color: _ink)),
                            const SizedBox(width: 10),
                          ],
                          // Arrow chip
                          Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                  color: accent.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: accent.withOpacity(0.20), width: 1)),
                              child: Icon(Icons.arrow_forward_ios_rounded,
                                  size: 12, color: accent)),
                        ]),
                      ]),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _thumbFallback(Color accent) => Container(
      decoration: BoxDecoration(
          gradient: RadialGradient(colors: [
            accent.withOpacity(0.15), accent.withOpacity(0.03)
          ])),
      child: Icon(Icons.play_circle_outline_rounded, color: accent, size: 28));
}