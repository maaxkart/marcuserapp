import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import 'chat_screen.dart';

// ══════════════════════════════════════════════════════════════════
// COMMUNITY SCREEN — New Design + Real Firebase/ApiService Data
// ══════════════════════════════════════════════════════════════════

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with TickerProviderStateMixin {

  // ── Palette ───────────────────────────────────────────────────
  static const _violet  = Color(0xFF6C3CE7);
  static const _emerald = Color(0xFF00C87A);
  static const _pink    = Color(0xFFD63CF0);
  static const _ink     = Color(0xFF1A1060);
  static const _muted   = Color(0xFF9FA3B0);
  static const _hint    = Color(0xFFC5C0E8);
  static const _bg1     = Color(0xFFF8F9FF);
  static const _bg2     = Color(0xFFF1F2FF);
  static const _bg3     = Color(0xFFE9ECFF);

  static const _avatarAccents = [
    [Color(0xFF6C3CE7), Color(0xFF9B59F5)],
    [Color(0xFF00C87A), Color(0xFF00D4E8)],
    [Color(0xFFD63CF0), Color(0xFFFF6B9D)],
    [Color(0xFFFF8C42), Color(0xFFFFD166)],
    [Color(0xFF0096FF), Color(0xFF7B2FFF)],
    [Color(0xFF06D6A0), Color(0xFF118AB2)],
  ];

  // ── State (identical to original) ────────────────────────────
  bool isLoading = true;
  int currentUserId = 0;
  List<dynamic> tutors = [];
  List<dynamic> filteredTutors = [];
  bool _searchFocused = false;

  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  late final AnimationController _orbitCtrl;
  late final AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _orbitCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 9))..repeat();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _searchFocus.addListener(
            () => setState(() => _searchFocused = _searchFocus.hasFocus));
    _loadTutors();
  }

  @override
  void dispose() {
    _orbitCtrl.dispose();
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ── Real data loading (unchanged) ─────────────────────────────
  Future<void> _loadTutors() async {
    final prefs = await SharedPreferences.getInstance();
    final data  = await ApiService.getTutors();
    setState(() {
      currentUserId  = prefs.getInt('user_id') ?? 0;
      tutors         = data;
      filteredTutors = data;
      isLoading      = false;
    });
    _fadeCtrl.forward();
  }

  void _search(String v) => setState(() {
    filteredTutors = v.isEmpty
        ? tutors
        : tutors.where((t) => t['name']
        .toString().toLowerCase().contains(v.toLowerCase())).toList();
  });

  Stream<bool> _onlineStream(int userId) =>
      FirebaseDatabase.instance
          .ref().child('users').child(userId.toString()).child('online')
          .onValue.map((e) => e.snapshot.value == true);

  String _roomId(int otherId) => currentUserId < otherId
      ? '${currentUserId}_$otherId' : '${otherId}_$currentUserId';

  String _initials(String name) {
    final p = name.trim().split(' ');
    return p.length >= 2
        ? '${p[0][0]}${p[1][0]}'.toUpperCase()
        : name[0].toUpperCase();
  }

  void _openChat(dynamic tutor) {
    HapticFeedback.lightImpact();
    Navigator.push(context, PageRouteBuilder(
      pageBuilder: (_, __, ___) => ChatScreen(
          myId: currentUserId,
          otherUserId: tutor['id'],
          otherName: tutor['name']),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 350),
    ));
  }

  void _showAskDoubtSheet() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AskDoubtSheet(),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────

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
            return Stack(children: [
              _orb(_violet.withOpacity(0.08), 340, top: -100, right: -100),
              _orb(_pink.withOpacity(0.06),   260, bottom: 60,  left: -80),
              _orb(_emerald.withOpacity(0.05), 200, top: 260,   right: -50),
              _floatDot(t,  _violet,  9, phase: 0.0, top: 70,  right: 40),
              _floatDot(t,  _emerald, 6, phase: 2.0, top: 130, right: 80),
              _floatDot(-t, _pink,    5, phase: 1.1, top: 95,  right: 150),
              SafeArea(
                child: isLoading
                    ? const Center(child: _Loader())
                    : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader()),
                    SliverToBoxAdapter(child: _buildSearchBar()),
                    SliverToBoxAdapter(child: _buildAskDoubtBanner()),
                    SliverToBoxAdapter(child: _buildOnlineSection()),
                    SliverToBoxAdapter(child: _buildMessagesSection()),
                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                ),
              ),
            ]);
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
          top: top + 26 * math.sin(t + phase),
          right: right + 26 * math.cos(t + phase),
          child: Container(width: s, height: s,
              decoration: BoxDecoration(shape: BoxShape.circle, color: c,
                  boxShadow: [BoxShadow(color: c.withOpacity(0.5),
                      blurRadius: s * 2.5)])));

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
                  Text('COMMUNITY', style: TextStyle(fontSize: 10,
                      fontWeight: FontWeight.w800, color: _violet,
                      letterSpacing: 1.2)),
                ]),
              ),
              const SizedBox(height: 10),
              const Text('Chat', style: TextStyle(fontSize: 36,
                  fontWeight: FontWeight.w900, color: _ink,
                  letterSpacing: -1.2, height: 1.0)),
              const SizedBox(height: 4),
              Row(children: [
                Container(width: 8, height: 8,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: _emerald)),
                const SizedBox(width: 6),
                Text('${tutors.length} tutors available',
                    style: const TextStyle(fontSize: 14, color: _muted)),
              ]),
            ])),
        Container(
          width: 46, height: 46,
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _searchFocused ? _violet : _violet.withOpacity(0.12),
            width: 1.5,
          ),
          boxShadow: _searchFocused
              ? [BoxShadow(color: _violet.withOpacity(0.10),
              blurRadius: 0, spreadRadius: 3)]
              : [BoxShadow(color: _violet.withOpacity(0.06),
              blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          const SizedBox(width: 14),
          Icon(Icons.search_rounded, size: 18,
              color: _searchFocused ? _violet : _hint),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              focusNode: _searchFocus,
              style: const TextStyle(fontSize: 14, color: _ink,
                  fontWeight: FontWeight.w500),
              onChanged: _search,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search tutors…',
                hintStyle: TextStyle(color: _hint.withOpacity(0.8),
                    fontSize: 13.5),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (_searchCtrl.text.isNotEmpty)
            GestureDetector(
              onTap: () { _searchCtrl.clear(); _search(''); },
              child: Padding(padding: const EdgeInsets.only(right: 12),
                  child: Icon(Icons.close_rounded, size: 16, color: _muted)),
            )
          else
            Container(
              margin: const EdgeInsets.only(right: 8),
              width: 34, height: 34,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_violet, _pink]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.tune_rounded,
                  color: Colors.white, size: 16),
            ),
        ]),
      ),
    );
  }

  // ── Ask Doubt AI Banner ───────────────────────────────────────

  Widget _buildAskDoubtBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: GestureDetector(
        onTap: _showAskDoubtSheet,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C3CE7), Color(0xFFAB47F5), Color(0xFFD63CF0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(color: _violet.withOpacity(0.35),
                  blurRadius: 24, offset: const Offset(0, 10)),
              BoxShadow(color: _pink.withOpacity(0.20),
                  blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: Text('✦',
                  style: TextStyle(fontSize: 26, color: Colors.white))),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Ask Doubt with AI',
                  style: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w900, fontSize: 17,
                      letterSpacing: -0.3)),
              const SizedBox(height: 4),
              Text('Powered by Gemini · instant answers',
                  style: TextStyle(color: Colors.white.withOpacity(0.80),
                      fontSize: 12.5, fontWeight: FontWeight.w400)),
            ])),
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white, size: 14),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Online Now ────────────────────────────────────────────────

  Widget _buildOnlineSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildSectionLabel('Online Now', filteredTutors.length),
      const SizedBox(height: 14),
      SizedBox(
        height: 110,
        child: filteredTutors.isEmpty
            ? Center(child: Text('No tutors found',
            style: TextStyle(color: _muted, fontSize: 13)))
            : ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          itemCount: filteredTutors.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (_, i) {
            final tutor = filteredTutors[i];
            final grad = _avatarAccents[i % _avatarAccents.length];
            return StreamBuilder<bool>(
              stream: _onlineStream(tutor['id']),
              builder: (_, snap) => GestureDetector(
                onTap: () => _openChat(tutor),
                child: _OnlineAvatar(
                    initials: _initials(tutor['name']),
                    name: tutor['name'],
                    isOnline: snap.data ?? false,
                    grad: grad),
              ),
            );
          },
        ),
      ),
    ]);
  }

  // ── Messages ──────────────────────────────────────────────────

  Widget _buildMessagesSection() {
    return StreamBuilder(
      stream: FirebaseDatabase.instance.ref().child('chat_rooms').onValue,
      builder: (context, snapshot) {
        List<dynamic> activeChats = [];
        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final data = Map<dynamic, dynamic>.from(
              snapshot.data!.snapshot.value as Map);
          for (var tutor in tutors) {
            if (data.containsKey(_roomId(tutor['id']))) {
              activeChats.add(tutor);
            }
          }
        }
        if (activeChats.isEmpty) return const SizedBox.shrink();
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 28),
          _buildSectionLabel('Messages', activeChats.length),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: List.generate(activeChats.length,
                    (i) => _buildChatTile(activeChats[i], i))),
          ),
        ]);
      },
    );
  }

  Widget _buildChatTile(dynamic tutor, int index) {
    final roomId = _roomId(tutor['id']);
    final grad   = _avatarAccents[index % _avatarAccents.length];
    final accent = grad[0] as Color;
    return StreamBuilder(
      stream: FirebaseDatabase.instance
          .ref().child('chat_rooms').child(roomId).child('messages')
          .limitToLast(1).onValue,
      builder: (_, msgSnap) {
        String lastMsg = 'Tap to start chatting';
        String time    = '';
        bool unread    = false;
        if (msgSnap.hasData && msgSnap.data!.snapshot.value != null) {
          final raw = Map<String, dynamic>.from(
              msgSnap.data!.snapshot.value as Map);
          final msg = raw.values.first as Map<dynamic, dynamic>;
          lastMsg = msg['message'] ?? '';
          unread  = msg['senderId'] != currentUserId;
          if (msg['timestamp'] != null) {
            time = DateFormat('hh:mm a').format(
                DateTime.fromMillisecondsSinceEpoch(msg['timestamp']));
          }
        }
        return StreamBuilder<bool>(
          stream: _onlineStream(tutor['id']),
          builder: (_, onlineSnap) => _ChatTile(
            name: tutor['name'],
            initials: _initials(tutor['name']),
            lastMsg: lastMsg, time: time,
            isOnline: onlineSnap.data ?? false, unread: unread,
            accent: accent, grad: grad, onTap: () => _openChat(tutor),
          ),
        );
      },
    );
  }

  Widget _buildSectionLabel(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: const TextStyle(fontSize: 20,
            fontWeight: FontWeight.w900, color: _ink, letterSpacing: -0.4)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _violet.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _violet.withOpacity(0.15), width: 1),
          ),
          child: Text('$count', style: TextStyle(fontSize: 12,
              fontWeight: FontWeight.w700, color: _violet)),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// ASK DOUBT SHEET — unchanged logic, opens Gemini app
// ══════════════════════════════════════════════════════════════════

class _AskDoubtSheet extends StatefulWidget {
  const _AskDoubtSheet();
  @override
  State<_AskDoubtSheet> createState() => _AskDoubtSheetState();
}

class _AskDoubtSheetState extends State<_AskDoubtSheet> {
  static const _violet = Color(0xFF6C3CE7);
  static const _pink   = Color(0xFFD63CF0);
  static const _ink    = Color(0xFF1A1060);
  static const _muted  = Color(0xFF9FA3B0);
  static const _hint   = Color(0xFFC5C0E8);

  final _ctrl = TextEditingController();
  bool _opening = false;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _openInGemini() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _opening = true);
    HapticFeedback.lightImpact();

    final encoded = Uri.encodeComponent(text);
    final androidIntent = Uri.parse(
      'intent://gemini.google.com/app?prompt=$encoded'
          '#Intent;scheme=https;package=com.google.android.apps.bard;end',
    );
    final universalLink = Uri.parse(
        'https://gemini.google.com/app?prompt=$encoded');

    bool launched = false;
    try {
      launched = await launchUrl(androidIntent,
          mode: LaunchMode.externalApplication);
    } catch (_) {}

    if (!launched) {
      await launchUrl(universalLink, mode: LaunchMode.externalApplication);
    }

    setState(() => _opening = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: _violet.withOpacity(0.15),
            blurRadius: 40, offset: const Offset(0, -8))],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 28,
        ),
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: _hint,
                      borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 22),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_violet, _pink]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: _violet.withOpacity(0.30),
                        blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('✦', style: TextStyle(color: Colors.white, fontSize: 14)),
                    SizedBox(width: 6),
                    Text('Gemini', style: TextStyle(color: Colors.white,
                        fontWeight: FontWeight.w800, fontSize: 13)),
                  ]),
                ),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Ask Your Doubt',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                          color: _ink, letterSpacing: -0.4)),
                  Text('Opens in the Gemini app',
                      style: TextStyle(fontSize: 11, color: _muted)),
                ]),
              ]),
              const SizedBox(height: 22),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _violet.withOpacity(0.18), width: 1.5),
                  boxShadow: [BoxShadow(color: _violet.withOpacity(0.06),
                      blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: TextField(
                  controller: _ctrl, maxLines: 5, minLines: 3, autofocus: true,
                  style: const TextStyle(fontSize: 14, color: _ink,
                      fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Type your doubt here…',
                    hintStyle: TextStyle(color: _hint.withOpacity(0.8),
                        fontSize: 13.5),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Icon(Icons.info_outline_rounded, size: 13, color: _muted),
                const SizedBox(width: 6),
                Expanded(child: Text(
                  'Your doubt will be sent to the Gemini app on your phone.',
                  style: TextStyle(fontSize: 11, color: _muted, height: 1.4),
                )),
              ]),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _opening ? null : _openInGemini,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: _opening
                        ? [_violet.withOpacity(0.55), _pink.withOpacity(0.55)]
                        : [_violet, _pink]),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: _opening ? [] : [BoxShadow(
                        color: _violet.withOpacity(0.35),
                        blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: Center(child: _opening
                      ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                      : const Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('✦', style: TextStyle(
                        color: Colors.white, fontSize: 16)),
                    SizedBox(width: 8),
                    Text('Open in Gemini', style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800,
                        fontSize: 15, letterSpacing: 0.2)),
                  ])),
                ),
              ),
            ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// ONLINE AVATAR
// ══════════════════════════════════════════════════════════════════

class _OnlineAvatar extends StatelessWidget {
  final String initials, name;
  final bool isOnline;
  final List<Color> grad;
  const _OnlineAvatar({required this.initials, required this.name,
    required this.isOnline, required this.grad});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Stack(clipBehavior: Clip.none, children: [
        Container(
          width: 68, height: 68,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: grad,
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: grad[0].withOpacity(0.28),
                blurRadius: 14, offset: const Offset(0, 6))],
          ),
          child: Center(child: Text(initials, style: const TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800))),
        ),
        Positioned(bottom: 3, right: 3, child: Container(
          width: 15, height: 15,
          decoration: BoxDecoration(
            color: isOnline ? const Color(0xFF00C87A) : const Color(0xFFCBD5E1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: isOnline ? [BoxShadow(
                color: const Color(0xFF00C87A).withOpacity(0.5),
                blurRadius: 6)] : [],
          ),
        )),
      ]),
      const SizedBox(height: 8),
      SizedBox(width: 74, child: Text(name,
          textAlign: TextAlign.center, maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: Color(0xFF1A1060)))),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════
// CHAT TILE
// ══════════════════════════════════════════════════════════════════

class _ChatTile extends StatefulWidget {
  final String name, initials, lastMsg, time;
  final bool isOnline, unread;
  final Color accent;
  final List<Color> grad;
  final VoidCallback onTap;
  const _ChatTile({required this.name, required this.initials,
    required this.lastMsg, required this.time, required this.isOnline,
    required this.unread, required this.accent, required this.grad,
    required this.onTap});
  @override
  State<_ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<_ChatTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp:   (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: widget.unread
                  ? widget.accent.withOpacity(0.20)
                  : widget.accent.withOpacity(0.10),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(color: widget.accent.withOpacity(0.10),
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
                          colors: [Colors.transparent, widget.grad[0],
                            widget.grad[1], Colors.transparent])))),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Stack(clipBehavior: Clip.none, children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: widget.grad,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(
                            color: widget.accent.withOpacity(0.28),
                            blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Center(child: Text(widget.initials,
                          style: const TextStyle(color: Colors.white,
                              fontSize: 18, fontWeight: FontWeight.w800))),
                    ),
                    Positioned(bottom: 1, right: 1, child: Container(
                      width: 13, height: 13,
                      decoration: BoxDecoration(
                        color: widget.isOnline
                            ? const Color(0xFF00C87A)
                            : const Color(0xFFCBD5E1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    )),
                  ]),
                  const SizedBox(width: 14),
                  Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(child: Text(widget.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1A1060)))),
                          Text(widget.time, style: TextStyle(fontSize: 10,
                              color: widget.unread
                                  ? widget.accent
                                  : const Color(0xFF9FA3B0),
                              fontWeight: widget.unread
                                  ? FontWeight.w700 : FontWeight.w400)),
                        ]),
                        const SizedBox(height: 4),
                        Row(children: [
                          Expanded(child: Text(widget.lastMsg,
                              overflow: TextOverflow.ellipsis, maxLines: 1,
                              style: TextStyle(fontSize: 12.5,
                                  fontWeight: widget.unread
                                      ? FontWeight.w600 : FontWeight.w400,
                                  color: widget.unread
                                      ? const Color(0xFF1A1060)
                                      : const Color(0xFF9FA3B0)))),
                          if (widget.unread) ...[
                            const SizedBox(width: 6),
                            Container(width: 9, height: 9,
                                decoration: BoxDecoration(
                                    color: widget.accent,
                                    shape: BoxShape.circle)),
                          ],
                        ]),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: widget.isOnline
                                ? const Color(0xFF00C87A).withOpacity(0.10)
                                : const Color(0xFF9FA3B0).withOpacity(0.10),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Container(width: 5, height: 5,
                                decoration: BoxDecoration(
                                    color: widget.isOnline
                                        ? const Color(0xFF00C87A)
                                        : const Color(0xFFCBD5E1),
                                    shape: BoxShape.circle)),
                            const SizedBox(width: 4),
                            Text(widget.isOnline ? 'Active now' : 'Offline',
                                style: TextStyle(fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: widget.isOnline
                                        ? const Color(0xFF00C87A)
                                        : const Color(0xFF9FA3B0))),
                          ]),
                        ),
                      ])),
                  Container(
                    width: 30, height: 30, margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: widget.accent.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                          color: widget.accent.withOpacity(0.20), width: 1),
                    ),
                    child: Icon(Icons.arrow_forward_rounded,
                        size: 14, color: widget.accent),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// LOADER
// ══════════════════════════════════════════════════════════════════

class _Loader extends StatelessWidget {
  const _Loader();
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 44, height: 44,
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF6C3CE7)),
                strokeWidth: 2.5)),
        const SizedBox(height: 14),
        const Text('Loading…',
            style: TextStyle(color: Color(0xFF9FA3B0), fontSize: 13)),
      ]);
}