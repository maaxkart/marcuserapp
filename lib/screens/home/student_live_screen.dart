import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

// ─── Chat message model ───────────────────────────────────────────────────────
class _ChatMessage {
  final String sender;
  final String text;
  _ChatMessage({required this.sender, required this.text});
}

// ─── Floating heart model ─────────────────────────────────────────────────────
class _FloatingHeart {
  final String id;
  final double x;
  final Color color;
  final double size;
  _FloatingHeart({
    required this.id,
    required this.x,
    required this.color,
    required this.size,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
class StudentLiveScreen extends StatefulWidget {
  final String? viewerToken;
  final String title;
  final String? teacherName;
  final int? viewerCount;

  const StudentLiveScreen({
    super.key,
    this.viewerToken,
    required this.title,
    this.teacherName,
    this.viewerCount,
  });

  @override
  State<StudentLiveScreen> createState() => _StudentLiveScreenState();
}

class _StudentLiveScreenState extends State<StudentLiveScreen>
    implements HMSUpdateListener {
  // HMS
  late HMSSDK hmsSDK;
  HMSVideoTrack? remoteTrack;
  bool isLoading = true;
  String errorMessage = "";
  bool joinedRoom = false;

  // UI
  bool _showControls = true;
  int _viewerCount = 0;

  // Chat
  final List<_ChatMessage> _messages = [];
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _chatVisible = false;

  // Hearts (kept for spawn logic, no button)
  final List<_FloatingHeart> _hearts = [];
  final _rng = Random();
  final List<Color> _heartColors = [
    Colors.pinkAccent,
    Colors.redAccent,
    Colors.purpleAccent,
    Colors.orangeAccent,
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    _viewerCount = widget.viewerCount ?? 0;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    joinRoom();
  }

  Future<void> joinRoom() async {
    try {
      if (widget.viewerToken == null || widget.viewerToken!.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = "Viewer token missing";
        });
        return;
      }
      hmsSDK = HMSSDK();
      await hmsSDK.build();
      hmsSDK.addUpdateListener(listener: this);
      await hmsSDK.join(
        config: HMSConfig(
          authToken: widget.viewerToken!,
          userName: "Student",
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    try {
      if (joinedRoom) hmsSDK.leave();
      hmsSDK.removeUpdateListener(listener: this);
    } catch (e) {
      debugPrint(e.toString());
    }
    _chatController.dispose();
    _scrollController.dispose();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  void _toggleControls() {
    if (!_chatVisible) setState(() => _showControls = !_showControls);
  }

  String _formatCount(int n) {
    if (n >= 1000000) return "${(n / 1000000).toStringAsFixed(1)}M";
    if (n >= 1000) return "${(n / 1000).toStringAsFixed(1)}K";
    return n.toString();
  }

  // ── Hearts (spawned from reactions, no button) ────────────────────────────
  void _spawnHeart() {
    final heart = _FloatingHeart(
      id: UniqueKey().toString(),
      x: 0.3 + _rng.nextDouble() * 0.4,
      color: _heartColors[_rng.nextInt(_heartColors.length)],
      size: 24 + _rng.nextDouble() * 16,
    );
    setState(() => _hearts.add(heart));
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _hearts.removeWhere((h) => h.id == heart.id));
    });
  }

  // ── Chat ──────────────────────────────────────────────────────────────────
  void _openChat() {
    setState(() {
      _chatVisible = true;
      _showControls = true;
    });
  }

  void _closeChat() {
    FocusScope.of(context).unfocus();
    setState(() => _chatVisible = false);
  }

  void _sendMessage() async {

    final text =
    _chatController.text.trim();

    if (text.isEmpty) return;

    try {

      await hmsSDK.sendBroadcastMessage(

        message: text,

        type: "chat",
      );

      _chatController.clear();

    } catch (e) {

      debugPrint(e.toString());
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Exit ──────────────────────────────────────────────────────────────────
  void _exitLive() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Leave Live?",
          style:
          TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to leave this live class?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Stay",
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("Leave",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. VIDEO
            _buildVideoLayer(),

            // 2. GRADIENTS
            _buildGradients(),

            // 3. TOP BAR
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: _buildTopBar(),
            ),

            // 4. FLOATING HEARTS (no button; spawned by reactions)
            ..._hearts.map((h) => AnimatedHeartWidget(heart: h)),

            // 5. BOTTOM AREA
            _buildBottomArea(),

            // 6. ERROR
            if (errorMessage.isNotEmpty) _buildErrorOverlay(),
          ],
        ),
      ),
    );
  }

  // ── Video ─────────────────────────────────────────────────────────────────
  Widget _buildVideoLayer() {
    if (isLoading && remoteTrack == null && errorMessage.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }
    if (remoteTrack != null) {
      return HMSVideoView(track: remoteTrack!, matchParent: true);
    }
    return Container(color: Colors.black);
  }

  // ── Gradients ─────────────────────────────────────────────────────────────
  Widget _buildGradients() {
    return Column(
      children: [
        // top fade
        Container(
          height: 140,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xCC000000), Colors.transparent],
            ),
          ),
        ),
        const Spacer(),
        // bottom fade
        Container(
          height: 280,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color(0xEE000000), Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }

  // ── TOP BAR ───────────────────────────────────────────────────────────────
  //  [Avatar + Name + LIVE]  ←spacer→  [👁 Viewers]  [✕]
  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildTeacherInfo(),
            const Spacer(),
            _buildViewerCount(),
            const SizedBox(width: 8),
            _buildExitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherInfo() {
    return Row(
      children: [
        // Avatar
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.redAccent, width: 2.5),
            gradient: const LinearGradient(
              colors: [Color(0xFF833AB4), Color(0xFFF77737)],
            ),
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.teacherName ?? "Teacher",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "LIVE",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildViewerCount() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          const Icon(Icons.visibility, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Text(
            _formatCount(_viewerCount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExitButton() {
    return GestureDetector(
      onTap: _exitLive,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white30),
        ),
        child: const Icon(Icons.close, color: Colors.white, size: 20),
      ),
    );
  }

  // ── BOTTOM AREA ───────────────────────────────────────────────────────────
  //  Title
  //  Chat messages (scroll up)
  //  [Comment input — dark background, white text]
  Widget _buildBottomArea() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Class title
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Chat messages list
              if (_messages.isNotEmpty || _chatVisible)
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final msg = _messages[i];
                      final isMe = msg.sender == "You";
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${msg.sender}  ",
                              style: TextStyle(
                                color: isMe
                                    ? Colors.yellowAccent
                                    : Colors.lightBlueAccent,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                shadows: const [
                                  Shadow(
                                      color: Colors.black87,
                                      blurRadius: 4),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Text(
                                msg.text,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  shadows: [
                                    Shadow(
                                        color: Colors.black87,
                                        blurRadius: 4),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 8),

              // ── Comment input (full width, no heart button) ──
              _buildCommentInput(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Comment input ─────────────────────────────────────────────────────────
  Widget _buildCommentInput() {

    // CLOSED INPUT
    if (!_chatVisible) {

      return GestureDetector(

        onTap: _openChat,

        child: Container(

          height: 48,

          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),

          decoration: BoxDecoration(

            color: const Color(0xCC111111),

            borderRadius:
            BorderRadius.circular(24),

            border: Border.all(
              color: Colors.white24,
            ),
          ),

          alignment: Alignment.centerLeft,

          child: const Text(

            "Comment...",

            style: TextStyle(
              color: Colors.white60,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    // OPEN INPUT
    return Container(

      height: 50,

      decoration: BoxDecoration(

        color: const Color(0xFF121212),

        borderRadius:
        BorderRadius.circular(26),

        border: Border.all(
          color: Colors.white24,
        ),

        boxShadow: const [

          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),

      child: Row(

        children: [

          Expanded(

            child: Theme(

              data: Theme.of(context).copyWith(

                textSelectionTheme:
                const TextSelectionThemeData(

                  cursorColor: Colors.white,

                  selectionColor:
                  Colors.white24,

                  selectionHandleColor:
                  Colors.white,
                ),
              ),

              child: TextField(

                controller: _chatController,

                autofocus: true,

                style: const TextStyle(

                  color: Colors.white,

                  fontSize: 14,

                  fontWeight: FontWeight.w500,
                ),

                cursorColor: Colors.white,

                decoration: const InputDecoration(

                  hintText: "Say something...",

                  hintStyle: TextStyle(

                    color: Colors.white38,

                    fontSize: 14,
                  ),

                  border: InputBorder.none,

                  enabledBorder:
                  InputBorder.none,

                  focusedBorder:
                  InputBorder.none,

                  filled: true,

                  fillColor: Colors.transparent,

                  contentPadding:
                  EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                ),

                onSubmitted: (_) =>
                    _sendMessage(),
              ),
            ),
          ),

          // SEND BUTTON
          GestureDetector(

            onTap: _sendMessage,

            child: Container(

              width: 36,
              height: 36,

              margin:
              const EdgeInsets.only(
                right: 6,
              ),

              decoration: BoxDecoration(

                color: Colors.white10,

                borderRadius:
                BorderRadius.circular(18),
              ),

              child: const Icon(

                Icons.send_rounded,

                color: Colors.white,

                size: 20,
              ),
            ),
          ),

          // CLOSE CHAT
          GestureDetector(

            onTap: _closeChat,

            child: const Padding(

              padding: EdgeInsets.only(
                right: 12,
              ),

              child: Icon(

                Icons.keyboard_arrow_down,

                color: Colors.white54,

                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Error overlay ─────────────────────────────────────────────────────────
  Widget _buildErrorOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, color: Colors.white54, size: 48),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style:
                const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Go Back",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  HMS CALLBACKS
  // ══════════════════════════════════════════════════════════════════════════

  @override
  void onTrackUpdate({
    required HMSTrack track,
    required HMSTrackUpdate trackUpdate,
    required HMSPeer peer,
  }) {
    if (track.kind == HMSTrackKind.kHMSTrackKindVideo &&
        track is HMSVideoTrack &&
        !peer.isLocal) {
      if (mounted) {
        setState(() {
          remoteTrack = track;
          isLoading = false;
        });
      }
    }
  }

  @override
  void onJoin({required HMSRoom room}) {
    joinedRoom = true;
    if (mounted) setState(() => isLoading = false);
  }

  @override
  void onError({required HMSException error}) {
    if (mounted) {
      setState(() {
        isLoading = false;
        errorMessage = error.message ?? "Unknown error";
      });
    }
  }

  @override
  void onHMSError({required HMSException error}) {
    if (mounted) {
      setState(() {
        isLoading = false;
        errorMessage = error.message ?? "Unknown HMS error";
      });
    }
  }

  @override
  void onPeerUpdate(
      {required HMSPeer peer, required HMSPeerUpdate update}) {
    if (update == HMSPeerUpdate.peerJoined && mounted) {
      setState(() => _viewerCount++);
    } else if (update == HMSPeerUpdate.peerLeft && mounted) {
      setState(
              () => _viewerCount = (_viewerCount - 1).clamp(0, 999999));
    }
  }

  @override
  void onMessage({

    required HMSMessage message,
  }) {

    if (mounted) {

      setState(() {

        _messages.add(

          _ChatMessage(

            sender:
            message.sender?.name ??
                "Viewer",

            text:
            message.message,
          ),
        );
      });

      _scrollToBottom();
    }
  }

  @override void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {}
  @override void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {}
  @override void onReconnecting() {}
  @override void onReconnected() {}
  @override void onRemovedFromRoom({required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {
    if (mounted) Navigator.pop(context);
  }
  @override void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {}
  @override void onChangeTrackStateRequest({required HMSTrackChangeRequest hmsTrackChangeRequest}) {}
  @override void onAudioDeviceChanged({HMSAudioDevice? currentAudioDevice, List<HMSAudioDevice>? availableAudioDevice}) {}
  @override void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {}
  @override void onPeerListUpdate({required List<HMSPeer> addedPeers, required List<HMSPeer> removedPeers}) {}
}

// ─── Animated floating heart ──────────────────────────────────────────────────
class AnimatedHeartWidget extends StatefulWidget {
  final _FloatingHeart heart;
  const AnimatedHeartWidget({super.key, required this.heart});

  @override
  State<AnimatedHeartWidget> createState() => _AnimatedHeartWidgetState();
}

class _AnimatedHeartWidgetState extends State<AnimatedHeartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _rise;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();

    _rise = Tween(begin: 0.0, end: -220.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = Tween(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.5, 1.0)));
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.2), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 70),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final startX = widget.heart.x * screenW - widget.heart.size / 2;
    final startY = screenH * 0.72;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Positioned(
        left: startX,
        top: startY + _rise.value,
        child: Opacity(
          opacity: _fade.value,
          child: Transform.scale(
            scale: _scale.value,
            child: Icon(
              Icons.favorite,
              color: widget.heart.color,
              size: widget.heart.size,
              shadows: [
                Shadow(
                    color: widget.heart.color.withOpacity(0.5),
                    blurRadius: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}