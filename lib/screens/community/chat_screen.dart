import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

// ══════════════════════════════════════════════════════════════════
// CHAT SCREEN — ULTRA PREMIUM (Explore Design Language)
// ══════════════════════════════════════════════════════════════════

class ChatScreen extends StatefulWidget {
  final int myId;
  final int otherUserId;
  final String otherName;

  const ChatScreen({
    super.key,
    required this.myId,
    required this.otherUserId,
    required this.otherName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {

  // ── Palette (matches ExploreScreen exactly) ───────────────────
  static const _violet  = Color(0xFF6C3CE7);
  static const _emerald = Color(0xFF00C87A);
  static const _pink    = Color(0xFFD63CF0);
  static const _ink     = Color(0xFF1A1060);
  static const _muted   = Color(0xFF9FA3B0);
  static const _hint    = Color(0xFFC5C0E8);
  static const _bg1     = Color(0xFFF8F9FF);
  static const _bg2     = Color(0xFFF1F2FF);
  static const _bg3     = Color(0xFFE9ECFF);

  // ── Controllers ───────────────────────────────────────────────
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final FocusNode _inputFocus = FocusNode();

  // ── State ─────────────────────────────────────────────────────
  bool _inputFocused = false;
  bool _showEmojis   = false;
  bool _isSending    = false;
  Map<String, dynamic>? _replyingMsg;

  // ── Firebase ──────────────────────────────────────────────────
  late DatabaseReference _messagesRef;

  String get _chatRoomId {
    final ids = [widget.myId, widget.otherUserId]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  // ── Animations ────────────────────────────────────────────────
  late final AnimationController _orbitCtrl;
  late final AnimationController _sendCtrl;

  static const List<String> _emojis = [
    '😀','😂','😍','🥰','😎','🔥','❤️','👍',
    '👏','🙏','🤩','😭','😅','🎉','💯','😇',
    '🥺','🤗','😡','🤔','💪','✨','🤝','😴',
  ];

  // ── Lifecycle ─────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _orbitCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 12))..repeat();
    _sendCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    _messagesRef = FirebaseDatabase.instance
        .ref().child('chat_rooms').child(_chatRoomId).child('messages');

    _inputFocus.addListener(() {
      setState(() {
        _inputFocused = _inputFocus.hasFocus;
        if (_inputFocus.hasFocus) _showEmojis = false;
      });
    });
  }

  @override
  void dispose() {
    _orbitCtrl.dispose();
    _sendCtrl.dispose();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  // ── Send message ──────────────────────────────────────────────

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() => _isSending = true);
    _sendCtrl.forward().then((_) => _sendCtrl.reverse());

    final reply = _replyingMsg;
    _msgCtrl.clear();
    setState(() => _replyingMsg = null);

    await _messagesRef.push().set({
      'senderId': widget.myId,
      'receiverId': widget.otherUserId,
      'message': text,
      'timestamp': ServerValue.timestamp,
      'replyMessage': reply?['message'],
      'replySender': reply?['senderId'],
      'isDeleted': false,
    });

    setState(() => _isSending = false);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  // ── Helpers ───────────────────────────────────────────────────

  String _formatTime(dynamic ts) {
    if (ts == null) return '';
    return DateFormat('hh:mm a').format(
        DateTime.fromMillisecondsSinceEpoch(ts));
  }

  String _initials(String name) {
    final p = name.trim().split(' ');
    return p.length >= 2
        ? '${p[0][0]}${p[1][0]}'.toUpperCase()
        : name[0].toUpperCase();
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
            return Stack(
              children: [
                // Subtle background orbs (lighter in chat context)
                _orb(_violet.withOpacity(0.05), 280, top: -80, right: -80),
                _orb(_pink.withOpacity(0.04), 200, bottom: 100, left: -60),
                _orb(_emerald.withOpacity(0.04), 160, top: 200, right: -40),

                // Floating dots (smaller in chat)
                _floatDot(t, _violet,  6, phase: 0.0, top: 80,  right: 50),
                _floatDot(t, _emerald, 4, phase: 2.0, top: 130, right: 90),

                SafeArea(
                  child: Column(
                    children: [
                      _buildAppBar(t),
                      Expanded(child: _buildMessageList()),
                      _buildInputArea(),
                      _buildEmojiPanel(),
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

  // ── Orb & dot helpers ─────────────────────────────────────────

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
          top: top + 20 * math.sin(t + phase),
          right: right + 20 * math.cos(t + phase),
          child: Container(
              width: s, height: s,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: c,
                  boxShadow: [BoxShadow(color: c.withOpacity(0.5),
                      blurRadius: s * 2.5)])));

  // ── App Bar ───────────────────────────────────────────────────

  Widget _buildAppBar(double t) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        border: Border.all(color: _violet.withOpacity(0.10), width: 1),
        boxShadow: [
          BoxShadow(color: _violet.withOpacity(0.10),
              blurRadius: 20, offset: const Offset(0, 6)),
          BoxShadow(color: Colors.black.withOpacity(0.04),
              blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Back
          GestureDetector(
            onTap: () { HapticFeedback.lightImpact(); Navigator.pop(context); },
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _violet.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _violet.withOpacity(0.15), width: 1),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _violet, size: 16),
            ),
          ),
          const SizedBox(width: 12),

          // Avatar
          Stack(clipBehavior: Clip.none, children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_violet, _pink],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: _violet.withOpacity(0.30),
                    blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Center(
                child: Text(_initials(widget.otherName),
                    style: const TextStyle(color: Colors.white,
                        fontSize: 18, fontWeight: FontWeight.w800)),
              ),
            ),
            // Online dot
            Positioned(
              bottom: 2, right: 2,
              child: Container(
                width: 12, height: 12,
                decoration: BoxDecoration(
                  color: _emerald,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [BoxShadow(color: _emerald.withOpacity(0.5),
                      blurRadius: 6)],
                ),
              ),
            ),
          ]),
          const SizedBox(width: 12),

          // Name & status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.otherName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                        color: _ink, letterSpacing: -0.3)),
                const SizedBox(height: 3),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: _emerald.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 5, height: 5,
                          decoration: const BoxDecoration(
                              color: _emerald, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      const Text('Active now',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                              color: _emerald)),
                    ]),
                  ),
                ]),
              ],
            ),
          ),

          // Call icon
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: _violet.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _violet.withOpacity(0.15), width: 1),
            ),
            child: const Icon(Icons.call_rounded, color: _violet, size: 18),
          ),
        ],
      ),
    );
  }

  // ── Message list ──────────────────────────────────────────────

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _messagesRef.orderByChild('timestamp').onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return _buildEmptyState();
        }

        final raw = Map<dynamic, dynamic>.from(
            snapshot.data!.snapshot.value as Map);
        final messages = raw.entries.map((e) =>
        {'key': e.key, ...Map<String, dynamic>.from(e.value)}).toList()
          ..sort((a, b) =>
              (a['timestamp'] ?? 0).compareTo(b['timestamp'] ?? 0));

        return ListView.builder(
          controller: _scrollCtrl,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          itemCount: messages.length,
          itemBuilder: (_, i) {
            final msg  = messages[i];
            final isMe = msg['senderId'] == widget.myId;
            // Show date separator if needed
            final showDate = i == 0 || _isDifferentDay(
                messages[i - 1]['timestamp'], msg['timestamp']);
            return Column(
              children: [
                if (showDate) _buildDateSeparator(msg['timestamp']),
                _buildBubble(msg, isMe),
              ],
            );
          },
        );
      },
    );
  }

  bool _isDifferentDay(dynamic ts1, dynamic ts2) {
    if (ts1 == null || ts2 == null) return false;
    final d1 = DateTime.fromMillisecondsSinceEpoch(ts1);
    final d2 = DateTime.fromMillisecondsSinceEpoch(ts2);
    return d1.day != d2.day || d1.month != d2.month || d1.year != d2.year;
  }

  Widget _buildDateSeparator(dynamic ts) {
    if (ts == null) return const SizedBox.shrink();
    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
    final now = DateTime.now();
    String label;
    if (dt.day == now.day && dt.month == now.month) {
      label = 'Today';
    } else if (dt.day == now.day - 1) {
      label = 'Yesterday';
    } else {
      label = DateFormat('MMM d, yyyy').format(dt);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(children: [
        Expanded(child: Container(height: 1,
            color: _violet.withOpacity(0.10))),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _violet.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _violet.withOpacity(0.15), width: 1),
          ),
          child: Text(label,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                  color: _violet, letterSpacing: 0.5)),
        ),
        Expanded(child: Container(height: 1,
            color: _violet.withOpacity(0.10))),
      ]),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_violet, _pink],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [BoxShadow(color: _violet.withOpacity(0.30),
                blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: const Icon(Icons.chat_bubble_outline_rounded,
              color: Colors.white, size: 36),
        ),
        const SizedBox(height: 18),
        const Text('Start the conversation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                color: _ink, letterSpacing: -0.3)),
        const SizedBox(height: 6),
        Text('Say hi! 👋',
            style: TextStyle(fontSize: 14, color: _muted)),
      ]),
    );
  }

  // ── Chat Bubble ───────────────────────────────────────────────

  Widget _buildBubble(Map<String, dynamic> msg, bool isMe) {
    final text      = msg['message'] ?? '';
    final time      = _formatTime(msg['timestamp']);
    final isDeleted = msg['isDeleted'] == true;

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _showMsgOptions(msg, isMe);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment:
          isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Other avatar (left side)
            if (!isMe) ...[
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_violet, _pink]),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: Text(_initials(widget.otherName),
                      style: const TextStyle(color: Colors.white,
                          fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 8),
            ],

            // Bubble
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                decoration: BoxDecoration(
                  gradient: isMe
                      ? const LinearGradient(
                      colors: [_violet, _pink],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight)
                      : null,
                  color: isMe ? null : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isMe ? 20 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 20),
                  ),
                  border: isMe
                      ? null
                      : Border.all(color: _violet.withOpacity(0.10), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: isMe
                          ? _violet.withOpacity(0.22)
                          : Colors.black.withOpacity(0.06),
                      blurRadius: isMe ? 16 : 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reply preview
                    if (msg['replyMessage'] != null) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.white.withOpacity(0.18)
                              : _violet.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border(
                            left: BorderSide(
                              color: isMe
                                  ? Colors.white.withOpacity(0.60)
                                  : _violet,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg['replySender'] == widget.myId
                                  ? 'You'
                                  : widget.otherName,
                              style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w800,
                                color: isMe ? Colors.white : _violet,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              msg['replyMessage'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: isMe
                                    ? Colors.white.withOpacity(0.75)
                                    : _muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Message text
                    Text(
                      isDeleted ? 'This message was deleted' : text,
                      style: TextStyle(
                        fontSize: 14.5,
                        color: isDeleted
                            ? (isMe ? Colors.white60 : _muted)
                            : (isMe ? Colors.white : _ink),
                        fontStyle: isDeleted ? FontStyle.italic : FontStyle.normal,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Time + tick
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(time,
                            style: TextStyle(
                              fontSize: 10,
                              color: isMe
                                  ? Colors.white.withOpacity(0.65)
                                  : _hint,
                            )),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.done_all_rounded,
                              size: 12,
                              color: Colors.white.withOpacity(0.65)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (isMe) const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  // ── Message Options ───────────────────────────────────────────

  void _showMsgOptions(Map<String, dynamic> msg, bool isMe) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FF),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: _violet.withOpacity(0.12),
              blurRadius: 24, offset: const Offset(0, -4))],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: _hint,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),

          _optionTile(Icons.reply_rounded, 'Reply', _violet, () {
            Navigator.pop(context);
            setState(() => _replyingMsg = msg);
          }),
          _optionTile(Icons.copy_rounded, 'Copy', const Color(0xFF0096FF), () {
            Clipboard.setData(ClipboardData(text: msg['message'] ?? ''));
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Copied to clipboard'),
                backgroundColor: _violet,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }),
          if (isMe) ...[
            _optionTile(Icons.delete_outline_rounded, 'Delete for me',
                const Color(0xFFFF8C42), () async {
                  Navigator.pop(context);
                  await _messagesRef.child(msg['key']).remove();
                }),
            _optionTile(Icons.delete_forever_rounded, 'Delete for everyone',
                const Color(0xFFD63CF0), () async {
                  Navigator.pop(context);
                  await _messagesRef.child(msg['key']).update({
                    'message': 'This message was deleted',
                    'isDeleted': true,
                  });
                }),
          ],
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  Widget _optionTile(IconData icon, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.12), width: 1),
          boxShadow: [BoxShadow(color: color.withOpacity(0.06),
              blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Text(title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                  color: _ink)),
        ]),
      ),
    );
  }

  // ── Input area ────────────────────────────────────────────────

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        border: Border(
          top: BorderSide(color: _violet.withOpacity(0.10), width: 1),
        ),
        boxShadow: [
          BoxShadow(color: _violet.withOpacity(0.08),
              blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Reply preview
        if (_replyingMsg != null) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: _violet.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _violet.withOpacity(0.15), width: 1),
            ),
            child: Row(children: [
              Container(
                width: 4, height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [_violet, _pink],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _replyingMsg!['senderId'] == widget.myId
                          ? 'You'
                          : widget.otherName,
                      style: const TextStyle(fontSize: 11,
                          fontWeight: FontWeight.w800, color: _violet),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _replyingMsg!['message'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: _muted),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _replyingMsg = null),
                child: Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: _hint.withOpacity(0.40),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.close_rounded, size: 14, color: _muted),
                ),
              ),
            ]),
          ),
        ],

        // Input row
        Row(children: [
          // Emoji toggle
          GestureDetector(
            onTap: () {
              if (!_showEmojis) _inputFocus.unfocus();
              setState(() => _showEmojis = !_showEmojis);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: _showEmojis
                    ? _violet.withOpacity(0.12)
                    : _violet.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _showEmojis
                      ? _violet.withOpacity(0.30)
                      : _violet.withOpacity(0.12),
                  width: 1,
                ),
              ),
              child: Icon(
                _showEmojis
                    ? Icons.keyboard_rounded
                    : Icons.emoji_emotions_rounded,
                color: _violet, size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Text field
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: _violet.withOpacity(0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _inputFocused ? _violet : _violet.withOpacity(0.12),
                  width: 1.5,
                ),
                boxShadow: _inputFocused
                    ? [BoxShadow(color: _violet.withOpacity(0.08),
                    blurRadius: 0, spreadRadius: 3)]
                    : [],
              ),
              child: TextField(
                controller: _msgCtrl,
                focusNode: _inputFocus,
                maxLines: 5,
                minLines: 1,
                style: TextStyle(fontSize: 14, color: _ink,
                    fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Type a message…',
                  hintStyle: TextStyle(
                      color: _hint.withOpacity(0.8), fontSize: 13.5),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Send button
          ScaleTransition(
            scale: Tween(begin: 1.0, end: 0.88)
                .animate(CurvedAnimation(parent: _sendCtrl,
                curve: Curves.easeInOut)),
            child: GestureDetector(
              onTap: _send,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 50, height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_violet, _pink],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: [
                    BoxShadow(color: _violet.withOpacity(0.35),
                        blurRadius: 14, offset: const Offset(0, 5)),
                    BoxShadow(color: _pink.withOpacity(0.15),
                        blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: _isSending
                    ? const Center(
                    child: SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2)))
                    : const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ),
        ]),
      ]),
    );
  }

  // ── Emoji panel ───────────────────────────────────────────────

  Widget _buildEmojiPanel() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      height: _showEmojis ? 240 : 0,
      decoration: const BoxDecoration(color: Colors.white),
      child: _showEmojis
          ? GridView.builder(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        itemCount: _emojis.length,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () {
            _msgCtrl.text += _emojis[i];
            _msgCtrl.selection = TextSelection.fromPosition(
                TextPosition(offset: _msgCtrl.text.length));
          },
          child: Center(
            child: Text(_emojis[i],
                style: const TextStyle(fontSize: 26)),
          ),
        ),
      )
          : const SizedBox.shrink(),
    );
  }
}