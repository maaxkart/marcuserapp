import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  @override State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Fees', 'Attendance', 'Exams', 'General'];

  final List<Map<String, dynamic>> _notifications = [
    {'title': 'Exam Fee Due Soon',         'body': 'Your exam fee of ₹2,000 is due on Sep 10. Pay now to avoid late charges.',  'type': 'Fees',       'icon': Icons.account_balance_wallet_rounded, 'color': const Color(0xFF059669), 'bg': const Color(0xFFD1FAE5), 'time': '2 hrs ago',    'read': false, 'urgent': true},
    {'title': 'Low Attendance Warning',    'body': 'Your Chemistry attendance is at 70%. Minimum 75% required for exams.',        'type': 'Attendance', 'icon': Icons.bar_chart_rounded,              'color': const Color(0xFFEF4444), 'bg': const Color(0xFFFEE2E2), 'time': '5 hrs ago',    'read': false, 'urgent': true},
    {'title': 'New Course Available',      'body': 'Advanced Python Programming is now open for enrollment. Limited seats!',       'type': 'General',    'icon': Icons.school_rounded,                 'color': const Color(0xFF6C63FF), 'bg': const Color(0xFFEEEDFE), 'time': 'Yesterday',    'read': true,  'urgent': false},
    {'title': 'Mid-Term Timetable Released','body': 'Mid-term exams scheduled Oct 14–22. Check your exam hall & seat number.',   'type': 'Exams',      'icon': Icons.assignment_rounded,             'color': const Color(0xFFD97706), 'bg': const Color(0xFFFEF3C7), 'time': '2 days ago',   'read': true,  'urgent': false},
    {'title': 'Class Cancelled',           'body': 'Physics class on Friday (Sep 6) is cancelled. It will be rescheduled.',        'type': 'Attendance', 'icon': Icons.event_busy_rounded,             'color': const Color(0xFF3B82F6), 'bg': const Color(0xFFDBEAFE), 'time': '3 days ago',   'read': true,  'urgent': false},
    {'title': 'Fee Receipt Generated',     'body': 'Your tuition fee receipt for Aug 2024 has been generated. Download now.',     'type': 'Fees',       'icon': Icons.receipt_long_rounded,           'color': const Color(0xFF059669), 'bg': const Color(0xFFD1FAE5), 'time': '1 week ago',   'read': true,  'urgent': false},
    {'title': 'Holiday Announced',         'body': 'College will remain closed on Sep 5 (Teachers Day). Enjoy the holiday!',      'type': 'General',    'icon': Icons.celebration_rounded,            'color': const Color(0xFF7C3AED), 'bg': const Color(0xFFEDE9FE), 'time': '1 week ago',   'read': true,  'urgent': false},
    {'title': 'Assignment Reminder',       'body': 'Math assignment submission deadline is Sep 8. Upload to student portal.',      'type': 'Exams',      'icon': Icons.edit_document,                  'color': const Color(0xFFD97706), 'bg': const Color(0xFFFEF3C7), 'time': '1 week ago',   'read': true,  'urgent': false},
  ];

  List<Map<String, dynamic>> get _filtered =>
      _selectedFilter == 0 ? _notifications : _notifications.where((n) => n['type'] == _filters[_selectedFilter]).toList();

  int get _unread => _notifications.where((n) => !(n['read'] as bool)).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            backgroundColor: const Color(0xFFEF4444),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16)),
            ),
            actions: [
              GestureDetector(
                onTap: () => setState(() { for (var n in _notifications) n['read'] = true; }),
                child: Container(margin: const EdgeInsets.all(10), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                    child: const Text('Mark all read', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFDC2626), Color(0xFFEF4444)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                child: Stack(children: [
                  Positioned(right: -20, top: -20, child: Container(width: 140, height: 140, decoration: const BoxDecoration(color: Color(0x10FFFFFF), shape: BoxShape.circle))),
                  SafeArea(child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 50, 22, 20),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                      Row(children: [
                        const Text('Notifications', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                        const SizedBox(width: 10),
                        if (_unread > 0)
                          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                              child: Text('$_unread new', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFEF4444)))),
                      ]),
                    ]),
                  )),
                ]),
              ),
            ),
          ),

          // Filters
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: SizedBox(height: 36, child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final active = _selectedFilter == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color: active ? const Color(0xFFEF4444) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: active ? Colors.transparent : const Color(0xFFE5E7EB), width: 0.8),
                    ),
                    child: Text(_filters[i], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? Colors.white : const Color(0xFF6B7280))),
                  ),
                );
              },
            )),
          )),

          // Notification list
          SliverList(delegate: SliverChildBuilderDelegate(
                (_, i) {
              final n = _filtered[i];
              final bool read = n['read'] as bool;
              return GestureDetector(
                onTap: () => setState(() => n['read'] = true),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: read ? Colors.white : const Color(0xFFFFF8F8),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: read ? const Color(0xFFE5E7EB) : (n['color'] as Color).withOpacity(0.25), width: read ? 0.8 : 1.0),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Stack(children: [
                      Container(width: 44, height: 44, decoration: BoxDecoration(color: n['bg'] as Color, borderRadius: BorderRadius.circular(14)),
                          child: Icon(n['icon'] as IconData, color: n['color'] as Color, size: 22)),
                      if (!read)
                        Positioned(right: -2, top: -2, child: Container(width: 10, height: 10, decoration: BoxDecoration(color: const Color(0xFFEF4444), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)))),
                    ]),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        if (n['urgent'] as bool)
                          Container(margin: const EdgeInsets.only(right: 6), padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(5)),
                              child: const Text('URGENT', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: Color(0xFFEF4444)))),
                        Expanded(child: Text(n['title'] as String, style: TextStyle(fontSize: 13, fontWeight: read ? FontWeight.w600 : FontWeight.w800, color: const Color(0xFF1A1A2E)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ]),
                      const SizedBox(height: 4),
                      Text(n['body'] as String, style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280), height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(children: [
                        Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: (n['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                            child: Text(n['type'] as String, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: n['color'] as Color))),
                        const Spacer(),
                        const Icon(Icons.access_time_rounded, size: 11, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 3),
                        Text(n['time'] as String, style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                      ]),
                    ])),
                  ]),
                ),
              );
            },
            childCount: _filtered.length,
          )),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}