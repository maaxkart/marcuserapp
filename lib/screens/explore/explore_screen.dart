import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import '../courses/course_list_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
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

  // Per-card accent pairs
  static const _cardAccents = [
    [Color(0xFF6C3CE7), Color(0xFF9B59F5)],
    [Color(0xFF00C87A), Color(0xFF00D4E8)],
    [Color(0xFFD63CF0), Color(0xFFFF6B9D)],
    [Color(0xFFFF8C42), Color(0xFFFFD166)],
    [Color(0xFF0096FF), Color(0xFF7B2FFF)],
    [Color(0xFF06D6A0), Color(0xFF118AB2)],
  ];

  static const _fallbackIcons = [
    Icons.code_rounded,
    Icons.bar_chart_rounded,
    Icons.design_services_rounded,
    Icons.psychology_rounded,
    Icons.language_rounded,
    Icons.camera_alt_rounded,
  ];

  List<dynamic> categories = [];
  bool isLoading = true;
  String _searchQuery = '';

  late final AnimationController _orbitCtrl;
  late final AnimationController _gridCtrl;
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _searchFocused = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _orbitCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 9))..repeat();
    _gridCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _searchFocus.addListener(
            () => setState(() => _searchFocused = _searchFocus.hasFocus));
    fetchCategories();
  }

  @override
  void dispose() {
    _orbitCtrl.dispose();
    _gridCtrl.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> fetchCategories() async {
    try {
      final data = await ApiService.getCategories();
      setState(() {
        categories = data;
        isLoading = false;
      });
      _gridCtrl.forward();
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  List<dynamic> get _filtered {
    if (_searchQuery.isEmpty) return categories;
    return categories
        .where((c) => (c['name'] ?? '')
        .toString()
        .toLowerCase()
        .contains(_searchQuery.toLowerCase()))
        .toList();
  }

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
                _orb(_violet.withOpacity(0.08), 340, top: -100, right: -100),
                _orb(_pink.withOpacity(0.06),   260, bottom: 60,  left: -80),
                _orb(_emerald.withOpacity(0.05), 200, top: 260,   right: -50),

                // Floating dots
                _floatDot(t,  _violet,  9, phase: 0.0, top: 70,  right: 40),
                _floatDot(t,  _emerald, 6, phase: 2.0, top: 130, right: 80),
                _floatDot(-t, _pink,    5, phase: 1.1, top: 95,  right: 150),

                SafeArea(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(child: _buildHeader(t)),
                      SliverToBoxAdapter(child: _buildSearchBar()),
                      SliverToBoxAdapter(child: _buildSectionLabel()),
                      if (isLoading)
                        const SliverFillRemaining(
                            child: Center(child: _Loader()))
                      else if (_filtered.isEmpty)
                        const SliverFillRemaining(child: _EmptyState())
                      else
                        _buildGrid(),
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
          child: Container(
              width: s, height: s,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [c, Colors.transparent]))));

  Widget _floatDot(double t, Color c, double s,
      {required double phase, required double top, required double right}) =>
      Positioned(
          top: top + 26 * math.sin(t + phase),
          right: right + 26 * math.cos(t + phase),
          child: Container(
              width: s, height: s,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: c,
                  boxShadow: [BoxShadow(color: c.withOpacity(0.5), blurRadius: s * 2.5)])));

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(double t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge pill
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: _violet.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _violet.withOpacity(0.18), width: 1)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 6, height: 6,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: _emerald)),
                      const SizedBox(width: 6),
                      Text('DISCOVER', style: TextStyle(fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _violet, letterSpacing: 1.2)),
                    ])),
                const SizedBox(height: 10),
                const Text('Explore',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900,
                        color: _ink, letterSpacing: -1.2, height: 1.0)),
                const SizedBox(height: 4),
                Text('Discover your next skill',
                    style: TextStyle(fontSize: 14, color: _muted)),
              ],
            ),
          ),
          // Notification button
          Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: _violet.withOpacity(0.15), width: 1),
                  boxShadow: [BoxShadow(color: _violet.withOpacity(0.12),
                      blurRadius: 16, offset: const Offset(0, 4))]),
              child: Icon(Icons.notifications_none_rounded, color: _violet, size: 20)),
        ],
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: _searchFocused ? _violet : _violet.withOpacity(0.12),
                width: 1.5),
            boxShadow: _searchFocused
                ? [BoxShadow(color: _violet.withOpacity(0.10),
                blurRadius: 0, spreadRadius: 3)]
                : [BoxShadow(color: _violet.withOpacity(0.06),
                blurRadius: 12, offset: const Offset(0, 4))]),
        child: Row(children: [
          const SizedBox(width: 14),
          Icon(Icons.search_rounded, size: 18,
              color: _searchFocused ? _violet : _hint),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              focusNode: _searchFocus,
              style: TextStyle(fontSize: 14, color: _ink, fontWeight: FontWeight.w500),
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search courses, topics…',
                  hintStyle: TextStyle(color: _hint.withOpacity(0.8), fontSize: 13.5),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
          Container(
              margin: const EdgeInsets.only(right: 8),
              width: 32, height: 32,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_violet, _pink]),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.tune_rounded, color: Colors.white, size: 15)),
        ]),
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────────────────────

  Widget _buildSectionLabel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Browse Topics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                  color: _ink, letterSpacing: -0.3)),
          if (!isLoading)
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: _violet.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _violet.withOpacity(0.15), width: 1)),
                child: Text('${_filtered.length}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                        color: _violet))),
        ],
      ),
    );
  }

  // ── Grid ──────────────────────────────────────────────────────────────────

  Widget _buildGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.15,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) => AnimatedBuilder(
            animation: _gridCtrl,
            builder: (_, child) {
              final delay    = (index * 0.06).clamp(0.0, 0.5);
              final progress = Curves.easeOutCubic.transform(
                  ((_gridCtrl.value - delay) / 0.45).clamp(0.0, 1.0));
              return Opacity(opacity: progress,
                  child: Transform.translate(
                      offset: Offset(0, 20 * (1 - progress)), child: child));
            },
            child: _buildTopicCard(_filtered[index], index),
          ),
          childCount: _filtered.length,
        ),
      ),
    );
  }

  // ── Topic card ────────────────────────────────────────────────────────────

  Widget _buildTopicCard(Map<String, dynamic> category, int index) {
    final grad        = _cardAccents[index % _cardAccents.length];
    final accent      = grad[0];
    final fallbackIcon = _fallbackIcons[index % _fallbackIcons.length];
    final count       = category['courses_count'] ?? 0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(context, PageRouteBuilder(
            pageBuilder: (_, __, ___) => CourseListScreen(
              categoryId: category['id'],
              categoryName: category['name'],
            ),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 350)));
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: accent.withOpacity(0.12), width: 1),
            boxShadow: [
              BoxShadow(color: accent.withOpacity(0.10), blurRadius: 20,
                  offset: const Offset(0, 6)),
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8,
                  offset: const Offset(0, 2)),
            ]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(children: [
            // Shimmer line top
            Positioned(top: 0, left: 0, right: 0,
                child: Container(height: 1.5,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Colors.transparent, grad[0], grad[1], Colors.transparent
                        ])))),
            // Glow blob top-right
            Positioned(top: -18, right: -18,
                child: Container(width: 70, height: 70,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          accent.withOpacity(0.15), Colors.transparent
                        ])))),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Icon box
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: grad,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(13),
                            boxShadow: [BoxShadow(color: accent.withOpacity(0.35),
                                blurRadius: 12, offset: const Offset(0, 4))]),
                        child: category['icon'] != null
                            ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(category['icon'],
                                width: 44, height: 44, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    Icon(fallbackIcon, color: Colors.white, size: 22)))
                            : Icon(fallbackIcon, color: Colors.white, size: 22),
                      ),
                      // Arrow
                      Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                              color: accent.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: accent.withOpacity(0.20), width: 1)),
                          child: Icon(Icons.arrow_forward_rounded, size: 13, color: accent)),
                    ],
                  ),
                  const Spacer(),
                  // Name
                  Text(category['name'] ?? '',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                          color: _ink, height: 1.2),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  // Count pill
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: accent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6)),
                      child: Text('$count course${count == 1 ? '' : 's'}',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                              color: accent))),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Shared loader ─────────────────────────────────────────────────────────────

class _Loader extends StatelessWidget {
  const _Loader();
  static const _violet = Color(0xFF6C3CE7);
  static const _muted  = Color(0xFF9FA3B0);
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 44, height: 44,
            child: CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation(_violet), strokeWidth: 2.5)),
        const SizedBox(height: 14),
        const Text('Loading…', style: TextStyle(color: _muted, fontSize: 13)),
      ]);
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  static const _violet = Color(0xFF6C3CE7);
  static const _muted  = Color(0xFF9FA3B0);
  static const _ink    = Color(0xFF1A1060);
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 68, height: 68,
            decoration: BoxDecoration(
                color: _violet.withOpacity(0.08), shape: BoxShape.circle,
                border: Border.all(color: _violet.withOpacity(0.15), width: 1)),
            child: Icon(Icons.search_off_rounded, color: _violet, size: 30)),
        const SizedBox(height: 14),
        const Text('Nothing found',
            style: TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        const Text('Try a different search term',
            style: TextStyle(color: _muted, fontSize: 13)),
      ]);
}