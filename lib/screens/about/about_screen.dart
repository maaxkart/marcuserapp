import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const List<Map<String, dynamic>> _features = [
    {'icon': Icons.play_lesson_rounded,          'title': 'Smart Learning',      'desc': 'AI-powered course recommendations tailored for you.',          'color': Color(0xFF6C63FF), 'bg': Color(0xFFEEEDFE)},
    {'icon': Icons.bar_chart_rounded,            'title': 'Attendance Tracker',  'desc': 'Real-time attendance monitoring with subject-wise insights.',  'color': Color(0xFFD97706), 'bg': Color(0xFFFEF3C7)},
    {'icon': Icons.account_balance_wallet_rounded,'title': 'Fee Management',     'desc': 'Pay and track all your academic fees in one place.',           'color': Color(0xFF059669), 'bg': Color(0xFFD1FAE5)},
    {'icon': Icons.diversity_3_rounded,          'title': 'Community',           'desc': 'Connect with peers, ask doubts and share resources.',          'color': Color(0xFF3B82F6), 'bg': Color(0xFFDBEAFE)},
    {'icon': Icons.notifications_active_rounded, 'title': 'Smart Alerts',        'desc': 'Never miss an exam, deadline or important announcement.',      'color': Color(0xFFEF4444), 'bg': Color(0xFFFEE2E2)},
  ];

  static const List<Map<String, dynamic>> _team = [
    {'name': 'Nowfal Nazar',   'role': 'Founder & CEO',       'avatar': 'NN', 'color': Color(0xFF6C63FF), 'bg': Color(0xFFEEEDFE)},
    {'name': 'Priya Menon',    'role': 'Lead Developer',       'avatar': 'PM', 'color': Color(0xFF059669), 'bg': Color(0xFFD1FAE5)},
    {'name': 'Alex Thomas',    'role': 'UI/UX Designer',       'avatar': 'AT', 'color': Color(0xFF3B82F6), 'bg': Color(0xFFDBEAFE)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF4F46E5),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF8B5CF6)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                child: Stack(children: [
                  Positioned(right: -30, top: -30, child: Container(width: 180, height: 180, decoration: const BoxDecoration(color: Color(0x10FFFFFF), shape: BoxShape.circle))),
                  Positioned(left: 30, bottom: 20, child: Container(width: 80, height: 80, decoration: const BoxDecoration(color: Color(0x08FFFFFF), shape: BoxShape.circle))),
                  SafeArea(child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 50, 22, 24),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                      // App icon
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5)),
                        child: const Center(child: Text('M', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white))),
                      ),
                      const SizedBox(height: 12),
                      const Text('Marc App', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                      const Text('Student Dashboard  ·  v2.4.1', style: TextStyle(color: Color(0xBBFFFFFF), fontSize: 12)),
                    ]),
                  )),
                ]),
              ),
            ),
          ),

          SliverToBoxAdapter(child: Column(children: [
            // ── What is Marc? ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE8E4FF), width: 0.8),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFFEEEDFE), borderRadius: BorderRadius.circular(11)), child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF6C63FF), size: 18)),
                    const SizedBox(width: 10),
                    const Text('What is Marc?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                  ]),
                  const SizedBox(height: 12),
                  const Text(
                    'Marc is an ultra-premium student dashboard app designed to simplify academic life. From tracking attendance and managing fees to discovering courses and connecting with the community — Marc keeps everything in one beautiful place.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.7),
                  ),
                ]),
              ),
            ),

            // ── Stats ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(children: [
                _statCard('50K+', 'Students', const Color(0xFF6C63FF), const Color(0xFFEEEDFE)),
                const SizedBox(width: 10),
                _statCard('200+', 'Courses', const Color(0xFF059669), const Color(0xFFD1FAE5)),
                const SizedBox(width: 10),
                _statCard('4.9★', 'Rating', const Color(0xFFD97706), const Color(0xFFFEF3C7)),
              ]),
            ),

            // ── Features ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Key Features', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 10),
                ..._features.map((f) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE8E4FF), width: 0.8),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))]),
                  child: Row(children: [
                    Container(width: 44, height: 44, decoration: BoxDecoration(color: f['bg'] as Color, borderRadius: BorderRadius.circular(13)), child: Icon(f['icon'] as IconData, color: f['color'] as Color, size: 22)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(f['title'] as String, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 2),
                      Text(f['desc'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), height: 1.4)),
                    ])),
                  ]),
                )),
              ]),
            ),

            // ── Meet the team ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Meet the Team', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 10),
                Row(children: _team.map((t) => Expanded(child: Container(
                  margin:  EdgeInsets.only(right: t == _team.last ? 0 : 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: (t['color'] as Color).withOpacity(0.15), width: 0.8)),
                  child: Column(children: [
                    Container(width: 46, height: 46, decoration: BoxDecoration(color: t['bg'] as Color, borderRadius: BorderRadius.circular(15), border: Border.all(color: (t['color'] as Color).withOpacity(0.2), width: 0.8)),
                        child: Center(child: Text(t['avatar'] as String, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: t['color'] as Color)))),
                    const SizedBox(height: 8),
                    Text(t['name'] as String, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)), textAlign: TextAlign.center),
                    const SizedBox(height: 2),
                    Text(t['role'] as String, style: const TextStyle(fontSize: 9.5, color: Color(0xFF9CA3AF)), textAlign: TextAlign.center),
                  ]),
                ))).toList()),
              ]),
            ),

            // ── Version info ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFF8F7FF), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE8E4FF), width: 0.8)),
                child: Column(children: [
                  _infoRow('Version', '2.4.1 (Build 241)'),
                  const SizedBox(height: 8),
                  _infoRow('Last Updated', 'September 2024'),
                  const SizedBox(height: 8),
                  _infoRow('Platform', 'Flutter · Android & iOS'),
                  const SizedBox(height: 8),
                  _infoRow('Developed by', 'Marc Technologies Pvt. Ltd.'),
                ]),
              ),
            ),

            // ── CTA ────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: const Column(children: [
                  Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 24),
                  SizedBox(height: 6),
                  Text('Rate Marc App', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                  SizedBox(height: 4),
                  Text('Your feedback helps us improve!', style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 12)),
                ]),
              ),
            ),
          ])),
        ],
      ),
    );
  }

  Widget _statCard(String val, String label, Color color, Color bg) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.15), width: 0.8)),
    child: Column(children: [
      Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
    ]),
  ));

  Widget _infoRow(String label, String value) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
    Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
  ]);
}