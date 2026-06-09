import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../services/api_service.dart';

class CourseVideoScreen extends StatefulWidget {
  final int courseId;
  final String title;

  const CourseVideoScreen({
    super.key,
    required this.courseId,
    required this.title,
  });

  @override
  State<CourseVideoScreen> createState() => _CourseVideoScreenState();
}

class _CourseVideoScreenState extends State<CourseVideoScreen>
    with TickerProviderStateMixin {
  // ── Palette ───────────────────────────────────────────────────────────────
  static const _violet  = Color(0xFF6C3CE7);
  static const _emerald = Color(0xFF00C87A);
  static const _pink    = Color(0xFFD63CF0);
  static const _ink     = Color(0xFF1A1060);
  static const _muted   = Color(0xFF9FA3B0);
  static const _bg1     = Color(0xFFF8F9FF);
  static const _bg2     = Color(0xFFF1F2FF);
  static const _bg3     = Color(0xFFE9ECFF);

  // ── State ─────────────────────────────────────────────────────────────────
  List<dynamic> lessons     = [];
  int    _selectedIndex     = 0;
  bool   isLoading          = true;
  bool   _hasError          = false;
  bool   _showControls      = true;
  bool   _isFullscreen      = false;
  bool   _isLocked          = false;
  double _playbackSpeed     = 1.0;
  double _volume            = 100.0;
  double _brightness        = 1.0;
  bool   _showVolumeBar     = false;
  bool   _showBrightnessBar = false;

  // ── media_kit ─────────────────────────────────────────────────────────────
  late final Player          _player;
  late final VideoController _videoController;

  // ── Animation ─────────────────────────────────────────────────────────────
  late final AnimationController _orbitCtrl;
  late final AnimationController _listCtrl;
  late final AnimationController _controlsFadeCtrl;
  late final AnimationController _lockBounceCtrl;

  static const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  // ── Bunny URL resolver ────────────────────────────────────────────────────
  String _resolveBunnyUrl(String url) {
    try {
      final uri  = Uri.parse(url);
      final host = uri.host;
      if (host == 'player.mediadelivery.net') {
        final segs = uri.pathSegments;
        if (segs.length >= 3) {
          return 'https://vz-645d8a93-295.b-cdn.net/${segs[2]}/playlist.m3u8';
        }
      }
      if (host.contains('b-cdn.net')) {
        final segs = uri.pathSegments;
        if (segs.isNotEmpty) {
          return uri
              .replace(pathSegments: [segs[0], 'playlist.m3u8'])
              .toString();
        }
      }
    } catch (_) {}
    return url;
  }

  @override
  void initState() {
    super.initState();
    _player = Player();
    _videoController = VideoController(_player);

    _orbitCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 10))
      ..repeat();
    _listCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _controlsFadeCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 250),
        value: 1.0);
    _lockBounceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    fetchLessons();

    _player.stream.completed.listen((completed) async {

      if (completed && lessons.isNotEmpty) {

        final lesson = lessons[_selectedIndex];

        // COMPLETE LESSON
        await ApiService.completeLesson(
          lessonId: lesson['id'],
          courseId: widget.courseId,
        );

        // UPDATE STREAK
        await ApiService.updateStreak();
        if (mounted) {

          Navigator.pop(context, true);
        }
        print("LESSON COMPLETED SAVED");

        print("STREAK UPDATED");
      }
    });
  }

  @override
  void dispose() {

    _player.dispose();

    _orbitCtrl.dispose();
    _listCtrl.dispose();
    _controlsFadeCtrl.dispose();
    _lockBounceCtrl.dispose();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    super.dispose();
  }

  // ── Fullscreen ────────────────────────────────────────────────────────────

  void _enterFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    setState(() => _isFullscreen = true);
  }

  void _exitFullscreen() {

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // IMPORTANT
    if (!mounted) return;

    _isFullscreen = false;
    _isLocked = false;
  }

  void _toggleFullscreen() =>
      _isFullscreen ? _exitFullscreen() : _enterFullscreen();

  // ── Data ──────────────────────────────────────────────────────────────────

  Future<void> fetchLessons() async {
    try {
      final data = await ApiService.getLessons(widget.courseId);
      setState(() { lessons = data; isLoading = false; });
      _listCtrl.forward();
      if (lessons.isNotEmpty && lessons[0]['video_url'] != null) {
        await _playVideo(lessons[0]['video_url'], 0);
      }
    } catch (_) {
      setState(() { isLoading = false; _hasError = true; });
    }
  }

  Future<void> _playVideo(String rawUrl, int index) async {
    setState(() => _selectedIndex = index);
    final url = _resolveBunnyUrl(rawUrl);
    debugPrint('▶ Playing: $url');
    await _player.open(Media(url));
    await _player.setRate(_playbackSpeed);
    await _player.setVolume(_volume);
    _autoHideControls();
  }

  // ── Controls ──────────────────────────────────────────────────────────────

  void _togglePlay() { _player.playOrPause(); setState(() {}); }

  void _skipForward() =>
      _player.seek(_player.state.position + const Duration(seconds: 10));
  void _skipBackward() =>
      _player.seek(_player.state.position - const Duration(seconds: 10));

  void _setVolume(double v) {
    _player.setVolume(v);
    setState(() { _volume = v; _showVolumeBar = true; });
    Future.delayed(const Duration(seconds: 2),
            () { if (mounted) setState(() => _showVolumeBar = false); });
  }

  void _toggleMute() => _setVolume(_volume == 0 ? 100.0 : 0.0);

  void _setSpeed(double speed) {
    _player.setRate(speed);
    setState(() => _playbackSpeed = speed);
  }

  void _toggleControls() {
    if (_isLocked) {
      _lockBounceCtrl.forward(from: 0).then((_) => _lockBounceCtrl.reverse());
      return;
    }
    if (_showControls) {
      _controlsFadeCtrl.reverse()
          .then((_) { if (mounted) setState(() => _showControls = false); });
    } else {
      setState(() => _showControls = true);
      _controlsFadeCtrl.forward();
      _autoHideControls();
    }
  }

  void _autoHideControls() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _player.state.playing && !_isLocked) {
        _controlsFadeCtrl.reverse()
            .then((_) { if (mounted) setState(() => _showControls = false); });
      }
    });
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  Color _accentFor(int i) => [_violet, _pink, _emerald][i % 3];

  // ═════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    // Fullscreen takes over entire scaffold
    if (_isFullscreen) return _buildFullscreenScaffold();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [_bg1, _bg2, _bg3],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: AnimatedBuilder(
          animation: _orbitCtrl,
          builder: (_, __) {
            final t = _orbitCtrl.value * 2 * math.pi;
            return Stack(children: [
              _orb(_violet.withOpacity(0.07),  300, bottom: -60, right: -60),
              _orb(_pink.withOpacity(0.05),    220, top: 300,    left: -50),
              _orb(_emerald.withOpacity(0.04), 180, top: 100,    right: -40),
              _floatDot(t,  _violet,  8, phase: 0.3, top: 55,  right: 28),
              _floatDot(-t, _pink,    5, phase: 1.2, top: 90,  right: 70),
              _floatDot(t,  _emerald, 6, phase: 2.1, top: 72,  right: 120),
              SafeArea(
                child: Column(children: [
                  _buildHeader(),
                  Expanded(child: _buildBody()),
                ]),
              ),
            ]);
          },
        ),
      ),
    );
  }

  // ── Fullscreen scaffold ───────────────────────────────────────────────────

  Widget _buildFullscreenScaffold() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleControls,
        onDoubleTapDown: (d) {
          final w = MediaQuery.of(context).size.width;
          d.localPosition.dx < w / 2 ? _skipBackward() : _skipForward();
        },
        // Swipe right side = volume, left side = brightness
        onVerticalDragUpdate: (d) {
          final w     = MediaQuery.of(context).size.width;
          final delta = -d.delta.dy / 200;
          if (d.globalPosition.dx > w / 2) {
            _setVolume((_volume + delta * 100).clamp(0.0, 100.0));
          } else {
            setState(() {
              _brightness        = (_brightness + delta).clamp(0.0, 1.0);
              _showBrightnessBar = true;
            });
            Future.delayed(const Duration(seconds: 2),
                    () { if (mounted) setState(() => _showBrightnessBar = false); });
          }
        },
        child: Stack(children: [
          // ── Video surface ──────────────────────────────────────────────
          SizedBox.expand(
            child: Video(
              controller: _videoController,
              controls: NoVideoControls,
              fill: Colors.black,
            ),
          ),

          // ── Brightness dim overlay ─────────────────────────────────────
          if (_brightness < 1.0)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                    color: Colors.black.withOpacity(1.0 - _brightness)),
              ),
            ),

          // ── Lock button (always tappable when locked) ──────────────────
          if (_isLocked)
            Positioned(
              right: 20, top: 0, bottom: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _lockBounceCtrl,
                  builder: (_, __) => Transform.scale(
                    scale: 1.0 + 0.3 * _lockBounceCtrl.value,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        setState(() { _isLocked = false; _showControls = true; });
                        _controlsFadeCtrl.forward();
                        _autoHideControls();
                      },
                      child: Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 1.5),
                        ),
                        child: const Icon(Icons.lock_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ── Controls overlay ───────────────────────────────────────────
          if (_showControls && !_isLocked)
            FadeTransition(
                opacity: _controlsFadeCtrl,
                child: _buildFullscreenOverlay()),

          // ── Volume side bar ────────────────────────────────────────────
          if (_showVolumeBar)
            Positioned(
              right: 20, top: 0, bottom: 0,
              child: IgnorePointer(
                child: Center(child: _buildSideBar(
                    _volume / 100, Icons.volume_up_rounded, _violet)),
              ),
            ),

          // ── Brightness side bar ────────────────────────────────────────
          if (_showBrightnessBar)
            Positioned(
              left: 20, top: 0, bottom: 0,
              child: IgnorePointer(
                child: Center(child: _buildSideBar(
                    _brightness, Icons.brightness_6_rounded, _emerald)),
              ),
            ),
        ]),
      ),
    );
  }

  Widget _buildSideBar(double value, IconData icon, Color color) {
    return Container(
      width: 40,
      height: 160,
      decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(height: 8),
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                thumbShape:
                const RoundSliderThumbShape(enabledThumbRadius: 5),
                overlayShape: SliderComponentShape.noOverlay,
                thumbColor: Colors.white,
                activeTrackColor: color,
                inactiveTrackColor: Colors.white24,
              ),
              child: Slider(min: 0, max: 1, value: value, onChanged: (_) {}),
            ),
          ),
        ),
        Text('${(value * 100).toInt()}%',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _buildFullscreenOverlay() {
    return StreamBuilder<bool>(
      stream: _player.stream.playing,
      initialData: _player.state.playing,
      builder: (_, playSnap) {
        final isPlaying = playSnap.data ?? false;
        return StreamBuilder<Duration>(
          stream: _player.stream.position,
          initialData: _player.state.position,
          builder: (_, posSnap) {
            final position = posSnap.data ?? Duration.zero;
            return StreamBuilder<Duration>(
              stream: _player.stream.duration,
              initialData: _player.state.duration,
              builder: (_, durSnap) {
                final duration = durSnap.data ?? Duration.zero;
                return Stack(children: [
                  // Gradient scrim
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // ── Top bar ──────────────────────────────────────────────
                  Positioned(
                    top: 0, left: 0, right: 0,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: Row(children: [
                        _fsCircleBtn(
                            Icons.arrow_back_ios_new_rounded,
                            _exitFullscreen,
                            size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            lessons.isNotEmpty
                                ? (lessons[_selectedIndex]['title'] ??
                                widget.title)
                                : widget.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Speed badge
                        GestureDetector(
                          onTap: _showSpeedSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [_violet, _pink]),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('${_playbackSpeed}x',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Lock
                        _fsCircleBtn(
                          Icons.lock_open_rounded,
                              () {
                            HapticFeedback.mediumImpact();
                            setState(() => _isLocked = true);
                            _controlsFadeCtrl.reverse().then((_) {
                              if (mounted) {
                                setState(() => _showControls = false);
                              }
                            });
                          },
                        ),
                      ]),
                    ),
                  ),

                  // ── Center play controls ──────────────────────────────────
                  Center(
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      _overlayBtn(Icons.replay_10_rounded, _skipBackward),
                      const SizedBox(width: 32),
                      GestureDetector(
                        onTap: _togglePlay,
                        child: Container(
                          width: 68, height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                                colors: [_violet, _pink],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight),
                            boxShadow: [BoxShadow(
                                color: _violet.withOpacity(0.5),
                                blurRadius: 24,
                                offset: const Offset(0, 6))],
                          ),
                          child: Icon(
                              isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white, size: 34),
                        ),
                      ),
                      const SizedBox(width: 32),
                      _overlayBtn(Icons.forward_10_rounded, _skipForward),
                    ]),
                  ),

                  // ── Bottom bar ────────────────────────────────────────────
                  Positioned(
                    left: 0, right: 0, bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildScrubBar(position, duration),
                            const SizedBox(height: 6),
                            Row(children: [
                              Text(_fmt(position),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                              Text(' / ${_fmt(duration)}',
                                  style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500)),
                              const Spacer(),
                              // Mute icon
                              GestureDetector(
                                onTap: _toggleMute,
                                child: Icon(
                                    _volume == 0
                                        ? Icons.volume_off_rounded
                                        : _volume < 50
                                        ? Icons.volume_down_rounded
                                        : Icons.volume_up_rounded,
                                    color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 6),
                              // Volume slider
                              SizedBox(
                                width: 90,
                                child: SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 2.5,
                                    thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 5),
                                    overlayShape:
                                    SliderComponentShape.noOverlay,
                                    thumbColor: Colors.white,
                                    activeTrackColor: _violet,
                                    inactiveTrackColor: Colors.white30,
                                  ),
                                  child: Slider(
                                      min: 0,
                                      max: 100,
                                      value: _volume,
                                      onChanged: _setVolume),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Exit fullscreen
                              GestureDetector(
                                onTap: _exitFullscreen,
                                child: const Icon(
                                    Icons.fullscreen_exit_rounded,
                                    color: Colors.white, size: 24),
                              ),
                            ]),
                          ]),
                    ),
                  ),
                ]);
              },
            );
          },
        );
      },
    );
  }

  Widget _fsCircleBtn(IconData icon, VoidCallback onTap,
      {double size = 20}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.12),
            border:
            Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Icon(icon, color: Colors.white, size: size),
        ),
      );

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _orb(Color c, double s,
      {double? top, double? bottom, double? left, double? right}) =>
      Positioned(
          top: top, bottom: bottom, left: left, right: right,
          child: Container(
              width: s, height: s,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient:
                  RadialGradient(colors: [c, Colors.transparent]))));

  Widget _floatDot(double t, Color c, double s,
      {required double phase,
        required double top,
        required double right}) =>
      Positioned(
          top:   top   + 20 * math.sin(t + phase),
          right: right + 20 * math.cos(t + phase),
          child: Container(
              width: s, height: s,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c,
                  boxShadow: [BoxShadow(
                      color: c.withOpacity(0.5),
                      blurRadius: s * 2.5)])));

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(children: [
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
                  border: Border.all(
                      color: _violet.withOpacity(0.15), width: 1),
                  boxShadow: [BoxShadow(
                      color: _violet.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 3))]),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _violet, size: 16)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800,
                        color: _ink, letterSpacing: -0.5, height: 1.1),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                if (!isLoading)
                  Text(
                      '${lessons.length} lesson${lessons.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                          fontSize: 12,
                          color: _muted,
                          fontWeight: FontWeight.w500)),
              ]),
        ),
        GestureDetector(
          onTap: _showSpeedSheet,
          child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [_violet, _pink],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [BoxShadow(
                      color: _violet.withOpacity(0.32),
                      blurRadius: 14,
                      offset: const Offset(0, 4))]),
              child: Text('${_playbackSpeed}x',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3))),
        ),
      ]),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(
              width: 44, height: 44,
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(_violet),
                  strokeWidth: 2.5)),
          const SizedBox(height: 14),
          const Text('Loading lessons…',
              style: TextStyle(color: _muted, fontSize: 13)),
        ]),
      );
    }

    if (_hasError || lessons.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 68, height: 68,
              decoration: BoxDecoration(
                  color: _violet.withOpacity(0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: _violet.withOpacity(0.15), width: 1)),
              child: const Icon(Icons.video_library_outlined,
                  color: _violet, size: 30)),
          const SizedBox(height: 14),
          Text(_hasError ? 'Failed to load' : 'No lessons yet',
              style: const TextStyle(
                  color: _ink, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Check back soon',
              style: TextStyle(color: _muted, fontSize: 13)),
        ]),
      );
    }

    return Column(children: [
      const SizedBox(height: 16),
      _buildVideoPlayer(),
      const SizedBox(height: 16),
      Expanded(child: _buildLessonList()),
    ]);
  }

  // ── Portrait player ───────────────────────────────────────────────────────

  Widget _buildVideoPlayer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: _violet.withOpacity(0.18),
                  blurRadius: 30,
                  offset: const Offset(0, 10)),
              BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
            ]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: GestureDetector(
              onTap: _toggleControls,
              onDoubleTapDown: (d) {
                final w = context.size?.width ?? 300;
                d.localPosition.dx < w / 2
                    ? _skipBackward()
                    : _skipForward();
              },
              child: Stack(children: [
                Video(
                  controller: _videoController,
                  controls: NoVideoControls,
                  fill: Colors.black,
                ),
                if (_showControls)
                  FadeTransition(
                      opacity: _controlsFadeCtrl,
                      child: _buildPortraitOverlay()),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitOverlay() {
    return StreamBuilder<bool>(
      stream: _player.stream.playing,
      initialData: _player.state.playing,
      builder: (_, playSnap) {
        final isPlaying = playSnap.data ?? false;
        return StreamBuilder<Duration>(
          stream: _player.stream.position,
          initialData: _player.state.position,
          builder: (_, posSnap) {
            final position = posSnap.data ?? Duration.zero;
            return StreamBuilder<Duration>(
              stream: _player.stream.duration,
              initialData: _player.state.duration,
              builder: (_, durSnap) {
                final duration = durSnap.data ?? Duration.zero;
                return Stack(children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.55),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.65),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // Center controls
                  Center(
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      _overlayBtn(Icons.replay_10_rounded, _skipBackward),
                      const SizedBox(width: 28),
                      GestureDetector(
                        onTap: _togglePlay,
                        child: Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                                colors: [_violet, _pink],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight),
                            boxShadow: [BoxShadow(
                                color: _violet.withOpacity(0.45),
                                blurRadius: 22,
                                offset: const Offset(0, 6))],
                          ),
                          child: Icon(
                              isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white, size: 30),
                        ),
                      ),
                      const SizedBox(width: 28),
                      _overlayBtn(Icons.forward_10_rounded, _skipForward),
                    ]),
                  ),

                  // Bottom bar
                  Positioned(
                    left: 0, right: 0, bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildScrubBar(position, duration),
                            const SizedBox(height: 8),
                            Row(children: [
                              Text(_fmt(position),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                              Text(' / ${_fmt(duration)}',
                                  style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500)),
                              const Spacer(),
                              GestureDetector(
                                onTap: _toggleMute,
                                child: Icon(
                                    _volume == 0
                                        ? Icons.volume_off_rounded
                                        : Icons.volume_up_rounded,
                                    color: Colors.white, size: 18),
                              ),
                              const SizedBox(width: 12),
                              // ← FULLSCREEN BUTTON ──────────────────────────
                              GestureDetector(
                                onTap: _toggleFullscreen,
                                child: const Icon(Icons.fullscreen_rounded,
                                    color: Colors.white, size: 22),
                              ),
                            ]),
                          ]),
                    ),
                  ),
                ]);
              },
            );
          },
        );
      },
    );
  }

  Widget _overlayBtn(IconData icon, VoidCallback onTap) => GestureDetector(
      onTap: onTap,
      child: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
              border: Border.all(
                  color: Colors.white.withOpacity(0.25), width: 1)),
          child: Icon(icon, color: Colors.white, size: 22)));

  Widget _buildScrubBar(Duration position, Duration duration) {
    final total   = duration.inMilliseconds.toDouble();
    final current = position.inMilliseconds
        .toDouble()
        .clamp(0.0, total == 0 ? 1.0 : total);

    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
        thumbColor: Colors.white,
        activeTrackColor: _violet,
        inactiveTrackColor: Colors.white.withOpacity(0.25),
        overlayColor: _violet.withOpacity(0.2),
      ),
      child: Slider(
        min: 0,
        max: total == 0 ? 1.0 : total,
        value: current,
        onChanged: (v) =>
            _player.seek(Duration(milliseconds: v.toInt())),
      ),
    );
  }

  // ── Lesson list ───────────────────────────────────────────────────────────

  Widget _buildLessonList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Row(children: [
            Container(
                width: 4, height: 18,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [_violet, _pink],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            const Text('Lessons',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800,
                    color: _ink, letterSpacing: -0.3)),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _listCtrl,
                builder: (_, child) {
                  final delay    = (index * 0.07).clamp(0.0, 0.56);
                  final progress = Curves.easeOutCubic.transform(
                      ((_listCtrl.value - delay) / 0.44).clamp(0.0, 1.0));
                  return Opacity(
                      opacity: progress,
                      child: Transform.translate(
                          offset: Offset(0, 18 * (1 - progress)),
                          child: child));
                },
                child: _buildLessonCard(lessons[index], index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLessonCard(Map<String, dynamic> lesson, int index) {
    final accent     = _accentFor(index);
    final isSelected = index == _selectedIndex;
    final hasVideo   = lesson['video_url'] != null;

    return GestureDetector(
      onTap: () {
        if (!hasVideo) return;
        HapticFeedback.selectionClick();
        _playVideo(lesson['video_url'], index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            color: isSelected ? accent.withOpacity(0.06) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isSelected
                    ? accent.withOpacity(0.35)
                    : accent.withOpacity(0.10),
                width: isSelected ? 1.5 : 1),
            boxShadow: [
              BoxShadow(
                  color: isSelected
                      ? accent.withOpacity(0.14)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: isSelected ? 18 : 8,
                  offset: const Offset(0, 4)),
            ]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(children: [
            if (isSelected)
              Positioned(
                  top: 0, left: 0, right: 0,
                  child: Container(
                      height: 1.5,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Colors.transparent, accent,
                            accent.withOpacity(0.4), Colors.transparent
                          ])))),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              child: Row(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                      color: isSelected
                          ? accent
                          : accent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : accent.withOpacity(0.20),
                          width: 1),
                      boxShadow: isSelected
                          ? [BoxShadow(
                          color: accent.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4))]
                          : []),
                  child: Icon(
                      isSelected
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_arrow_rounded,
                      color: isSelected ? Colors.white : accent,
                      size: isSelected ? 20 : 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lesson['title'] ?? 'Lesson ${index + 1}',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? accent : _ink,
                                height: 1.3),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        if (lesson['duration'] != null) ...[
                          const SizedBox(height: 3),
                          Row(children: [
                            const Icon(Icons.access_time_rounded,
                                size: 11, color: _muted),
                            const SizedBox(width: 3),
                            Text(lesson['duration'].toString(),
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: _muted,
                                    fontWeight: FontWeight.w500)),
                          ]),
                        ],
                      ]),
                ),
                Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: isSelected
                            ? accent.withOpacity(0.12)
                            : _bg3,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                            color: isSelected
                                ? accent.withOpacity(0.25)
                                : Colors.transparent,
                            width: 1)),
                    child: Text('${index + 1}',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? accent : _muted))),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Speed sheet ───────────────────────────────────────────────────────────

  void _showSpeedSheet() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: _violet.withOpacity(0.10), width: 1),
            boxShadow: [BoxShadow(
                color: _violet.withOpacity(0.12),
                blurRadius: 30,
                offset: const Offset(0, -4))]),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 14),
          Container(
              width: 38, height: 4,
              decoration: BoxDecoration(
                  color: _violet.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Playback Speed',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _ink)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10, runSpacing: 10,
            alignment: WrapAlignment.center,
            children: _speeds.map((s) {
              final sel = s == _playbackSpeed;
              return GestureDetector(
                onTap: () { _setSpeed(s); Navigator.pop(context); },
                child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 72, height: 42,
                    decoration: BoxDecoration(
                        gradient: sel
                            ? const LinearGradient(
                            colors: [_violet, _pink],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight)
                            : null,
                        color: sel ? null : _bg2,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: sel
                                ? Colors.transparent
                                : _violet.withOpacity(0.12),
                            width: 1),
                        boxShadow: sel
                            ? [BoxShadow(
                            color: _violet.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4))]
                            : []),
                    child: Center(
                        child: Text('${s}x',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color:
                                sel ? Colors.white : _muted)))),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}