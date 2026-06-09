import 'dart:async';
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/course_card.dart';
import '../courses/course_list_screen.dart';
import '../profile/notifications_screen.dart';
import '../../search/search_screen.dart';
import '../courses/course_video_screen.dart';
import '../home/student_live_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  final ScrollController _scrollController = ScrollController();

  // Banner auto-scroll
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;
  Timer? _liveReloadTimer;
  int _bannerPage = 0;

  int selectedCategory = 0;
  bool isLoading = true;

  // ── API DATA ─────────────────────────────────────────────────
  List<dynamic> categories = [];
  List<dynamic> popularCourses = [];
  List<dynamic> continueCourses = [];
  List<dynamic> instructors = [];
  List<dynamic> liveCourses = [];
  List<dynamic> banners = [];
  String userName = "User";

  // ── COMPUTED STATS (real API counts) ─────────────────────────
  int get enrolledCount => continueCourses.length;
  int get coursesCount  => popularCourses.length;
  int get tutorsCount   => instructors.length;

  // ─────────────────────────────────────────────────────────────
  // INIT
  // ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
    loadHomeData();
    _liveReloadTimer = Timer.periodic(

      const Duration(seconds: 5),

          (_) {

        refreshLiveCourses();
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // LOAD DATA (parallel)
  // ─────────────────────────────────────────────────────────────

  Future<void> loadHomeData() async {
    try {
      final results = await Future.wait([
        ApiService.getBanners(),        // 0
        ApiService.getCategories(),     // 1
        ApiService.getPopularCourses(), // 2
        ApiService.getMyCourses(),      // 3
        ApiService.getTopTutors(),      // 4
        ApiService.getLiveCourses(),    // 5
        ApiService.getProfile(),        // 6
      ]);

      setState(() {

        banners =
        results[0] as List<dynamic>;

        categories =
        results[1] as List<dynamic>;

        popularCourses =
        results[2] as List<dynamic>;

        final myCoursesResponse =
        results[3] as Map<String, dynamic>;

        continueCourses =
        List<dynamic>.from(
          myCoursesResponse['courses'] ?? [],
        );

        instructors =
        results[4] as List<dynamic>;

        liveCourses =
        results[5] as List<dynamic>;

        final profile =
        results[6] as Map<String, dynamic>;

        userName =
            profile['name']?.toString() ?? "User";

        print("USERNAME : $userName");

        print("INSTRUCTORS : $instructors");

        isLoading = false;
      });

      _startBannerTimer();
    } catch (e) {
      debugPrint(e.toString());
      setState(() => isLoading = false);
    }
  }

  Future<void> refreshLiveCourses() async {

    try {

      final data =
      await ApiService.getLiveCourses();

      if (mounted) {

        setState(() {

          liveCourses = List<dynamic>.from(data);
        });
      }

    } catch (e) {

      debugPrint(e.toString());
    }
  }

  void _startBannerTimer() {
    if (banners.length <= 1) return;
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _bannerPage = (_bannerPage + 1) % banners.length;
      _bannerController.animateToPage(
        _bannerPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _scrollController.dispose();
    _bannerController.dispose();
    _bannerTimer?.cancel();
    _liveReloadTimer?.cancel();

    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F6FF),
      child: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6C63FF),
          strokeWidth: 2.5,
        ),
      )
          : FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // APP BAR
  // ─────────────────────────────────────────────────────────────

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      snap: true,
      backgroundColor: const Color(0xFFF7F6FF),
      elevation: 0,
      title: _buildAppBarContent(),
      centerTitle: false,
      actions: [
        _buildNotificationButton(),
        const SizedBox(width: 8),
        _buildSearchButton(),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildAppBarContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 50),
      child: Image.asset(
        "assets/images/marc_logo.png",
        height: 80,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildNotificationButton() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
      ),
      child: Stack(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.10),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF6C63FF),
              size: 20,
            ),
          ),
          Positioned(
            top: 9,
            right: 9,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFFF4D6D),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SearchScreen()),
      ),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.10),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.search_rounded,
          color: Color(0xFF6C63FF),
          size: 20,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // BODY
  // ─────────────────────────────────────────────────────────────

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreetingSection(),
          const SizedBox(height: 24),
         // _buildStatsBar(),
          //const SizedBox(height: 28),
          if (banners.isNotEmpty) ...[
            _buildBannerSlider(),
            const SizedBox(height: 28),
          ],
          _buildLiveTutorsSection(),
          const SizedBox(height: 28),
          _buildCategorySection(),
          const SizedBox(height: 28),
          _buildCoursesSection(),
          const SizedBox(height: 28),
          _buildContinueLearningSection(),
          const SizedBox(height: 28),
          _buildTopInstructors(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // GREETING
  // ─────────────────────────────────────────────────────────────

  Widget _buildGreetingSection() {
    final hour = DateTime.now().hour;
    final String greeting =
    hour < 12 ? "Good Morning" : hour < 17 ? "Good Afternoon" : "Good Evening";
    final String emoji = hour < 12 ? "☀️" : hour < 17 ? "🌤️" : "🌙";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.08),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 6),
                Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6C63FF),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                "Hey, ",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                  height: 1.1,
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF9F6BFF)],
                ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                child: Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ),
              const Text(
                " 👋",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                  height: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Let's build something amazing today 🚀",
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF1A1A2E).withOpacity(0.45),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // STATS BAR  — real counts from API
  // ─────────────────────────────────────────────────────────────

  Widget _buildStatsBar() {
    final stats = [
      {"icon": Icons.play_lesson_rounded,       "value": "$enrolledCount", "label": "Enrolled"},
      {"icon": Icons.workspace_premium_rounded, "value": "$coursesCount",  "label": "Courses"},
      {"icon": Icons.people_alt_rounded,        "value": "$tutorsCount",   "label": "Tutors"},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(stats.length, (i) {
            final s = stats[i];
            return Expanded(
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEEECFF), Color(0xFFE0DCFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(s["icon"] as IconData, color: const Color(0xFF6C63FF), size: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s["value"] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s["label"] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFF1A1A2E).withOpacity(0.4),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // BANNER SLIDER
  // ─────────────────────────────────────────────────────────────

  Widget _buildBannerSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Text(
                "Featured",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              Text(
                "${banners.length} banners",
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF6C63FF).withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: 170,
              child: PageView.builder(
                controller: _bannerController,
                itemCount: banners.length,
                onPageChanged: (page) => setState(() => _bannerPage = page),
                itemBuilder: (_, index) {
                  final banner   = banners[index];
                  final imageUrl = banner['image']?.toString() ?? "";
                  final title    = banner['title']?.toString() ?? "";

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      imageUrl.isNotEmpty
                          ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildBannerFallback(title),
                      )
                          : _buildBannerFallback(title),
                      // Dark gradient overlay so title is always readable
                      if (title.isNotEmpty)
                        Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(16, 36, 16, 14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.58),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                shadows: [Shadow(blurRadius: 6, color: Colors.black45)],
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        // Dot indicators
        if (banners.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(banners.length, (i) {
              final isActive = i == _bannerPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF6C63FF)
                      : const Color(0xFF6C63FF).withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildBannerFallback(String title) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF9F6BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.campaign_rounded, color: Colors.white, size: 38),
            if (title.isNotEmpty) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // LIVE CLASSES
  // ─────────────────────────────────────────────────────────────

  Widget _buildLiveTutorsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF4D6D), Color(0xFFFF8FA3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF4D6D).withOpacity(0.28),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.live_tv_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Live Classes",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6, height: 6,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        "LIVE",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            liveCourses.isEmpty
                ? _buildEmptyLive()
                : SizedBox(
              height: 178,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: liveCourses.take(10).length,
                itemBuilder: (_, index) {
                  final course = liveCourses.take(10).toList()[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentLiveScreen(
                          viewerToken: course['viewer_token']?.toString(),
                          title: course['title'] ?? 'Live Class',
                          teacherName: course['teacher_name']?.toString(),
                          viewerCount: int.tryParse(course['viewer_count']?.toString() ?? '0') ?? 0,
                        ),
                      ),
                    ),
                    child: _buildLiveCourseCard(course),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyLive() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
            ),
            child: const Icon(Icons.live_tv_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 14),
          const Text(
            "No Live Classes Available",
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            "Live courses will appear here 🚀",
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveCourseCard(dynamic course) {

    final title =
        course['title']?.toString() ??
            course['course']?['title']?.toString() ??
            "Live Class";

    final tutorName =
        course['tutor_name']?.toString() ??
            course['tutor']?['name']?.toString() ??
            "Live Tutor";

    final thumbnail =
        course['thumbnail']?.toString() ??
            course['course']?['thumbnail']?.toString() ??
            "";

    return Container(
      width: 238,
      margin: const EdgeInsets.only(right: 14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      clipBehavior: Clip.hardEdge,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          // IMAGE
          Stack(
            children: [

              SizedBox(
                height: 100,
                width: double.infinity,

                child: thumbnail.isNotEmpty
                    ? Image.network(
                  thumbnail,
                  fit: BoxFit.cover,

                  errorBuilder: (_, __, ___) {

                    return Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFF4D6D),
                            Color(0xFFFF8FA3),
                          ],
                        ),
                      ),

                      child: const Center(
                        child: Icon(
                          Icons.live_tv_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    );
                  },
                )
                    : Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFF4D6D),
                        Color(0xFFFF8FA3),
                      ],
                    ),
                  ),

                  child: const Center(
                    child: Icon(
                      Icons.live_tv_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 10,
                left: 10,

                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4D6D),

                    borderRadius: BorderRadius.circular(20),

                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF4D6D)
                            .withOpacity(0.4),

                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),

                  child: const Row(
                    children: [

                      Icon(
                        Icons.circle,
                        size: 7,
                        color: Colors.white,
                      ),

                      SizedBox(width: 4),

                      Text(
                        "LIVE",

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // DETAILS
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                14,
                10,
                14,
                10,
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

                children: [

                  Text(
                    title,

                    maxLines: 2,

                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E),
                      height: 1.3,
                    ),
                  ),

                  Text(
                    tutorName,

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      color: const Color(0xFF1A1A2E)
                          .withOpacity(0.45),

                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // CATEGORIES
  // ─────────────────────────────────────────────────────────────

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Text(
                'Categories',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E), letterSpacing: -0.3),
              ),
              const Spacer(),
              Text(
                "${categories.length} total",
                style: TextStyle(fontSize: 12, color: const Color(0xFF6C63FF).withOpacity(0.7), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length,
            itemBuilder: (_, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: CategoryChip(
                  label: categories[index]['name']?.toString() ?? "Category",
                  icon: "📚",
                  isSelected: selectedCategory == index,
                  onTap: () {
                    setState(() => selectedCategory = index);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourseListScreen(
                          categoryId: categories[index]['id'],
                          categoryName: categories[index]['name']?.toString() ?? "Category",
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // POPULAR COURSES
  // ─────────────────────────────────────────────────────────────

  Widget _buildCoursesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Text(
                "Popular Courses",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E), letterSpacing: -0.3),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF9F6BFF)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text("See All", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 310,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: popularCourses.length,
            itemBuilder: (_, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 14),
                child: GestureDetector(
                  onTap: () {
                    final course = popularCourses[index];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourseVideoScreen(
                          courseId: course['id'],
                          title: course['title']?.toString() ?? "Course",
                        ),
                      ),
                    );
                  },
                  child: CourseCard(data: popularCourses[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // CONTINUE LEARNING
  // ─────────────────────────────────────────────────────────────

  Widget _buildContinueLearningSection() {
    final pendingCourses = continueCourses
        .where((c) => ((c['progress'] ?? 0) as num).toDouble() < 1)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Text(
                "Continue Learning",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E), letterSpacing: -0.3),
              ),
              const Spacer(),
              if (pendingCourses.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${pendingCourses.length} pending",
                    style: const TextStyle(fontSize: 11, color: Color(0xFF6C63FF), fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        pendingCourses.isEmpty
            ? _buildEmptyContinue()
            : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: continueCourses.length,
          itemBuilder: (_, index) {
            final course = continueCourses[index];
            if (((course['progress'] ?? 0) as num).toDouble() >= 1) {
              return const SizedBox.shrink();
            }
            return _buildContinueCourseCard(course);
          },
        ),
      ],
    );
  }

  Widget _buildEmptyContinue() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFEEECFF), Color(0xFFDDD9FF)]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.play_circle_outline_rounded, size: 28, color: Color(0xFF6C63FF)),
            ),
            const SizedBox(height: 16),
            const Text(
              "No Pending Courses",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 6),
            Text(
              "Start learning new premium courses 🚀",
              style: TextStyle(color: const Color(0xFF1A1A2E).withOpacity(0.45), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueCourseCard(dynamic course) {
    final progress = ((course['progress'] ?? 0.4) as num).toDouble();
    final percent  = (progress * 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.06), blurRadius: 18, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              course['thumbnail']?.toString() ?? "",
              width: 86, height: 86, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 86, height: 86,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF9F6BFF)]),
                ),
                child: const Icon(Icons.school_rounded, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['title']?.toString() ?? "Course",
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E), height: 1.3),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$percent% complete",
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF6C63FF)),
                    ),
                    const Text(
                      "Continue →",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF6C63FF)),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Stack(
                  children: [
                    Container(
                      height: 7,
                      decoration: BoxDecoration(color: const Color(0xFFEEECFF), borderRadius: BorderRadius.circular(20)),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        height: 7,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF9F6BFF)]),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.35), blurRadius: 6, offset: const Offset(0, 2)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TOP INSTRUCTORS
  // ─────────────────────────────────────────────────────────────

  Widget _buildTopInstructors() {
    final gradients = [
      [const Color(0xFF6C63FF), const Color(0xFF9F6BFF)],
      [const Color(0xFFFF4D6D), const Color(0xFFFF8FA3)],
      [const Color(0xFF00B4D8), const Color(0xFF48CAE4)],
      [const Color(0xFFFF9F43), const Color(0xFFFFBE76)],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Top Instructors",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E), letterSpacing: -0.3),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: instructors.length,
            itemBuilder: (_, index) {
              final inst    = instructors[index];
              final name    = inst['name']?.toString() ?? "T";
              final initial = name.substring(0, 1).toUpperCase();
              final grad    = gradients[index % gradients.length];

              return Container(
                width: 104,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(color: grad[0].withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 6)),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: grad),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: grad[0].withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 11),
                        const SizedBox(width: 2),
                        Text(
                          inst['rating']?.toString() ?? "4.9",
                          style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A2E).withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}