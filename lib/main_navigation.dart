import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Bottom Nav Screens
import '../screens/home/home_screen.dart';
import './screens/explore/explore_screen.dart';
import './screens/mycourses/mycourses_screen.dart';
import './screens/profile/profile_screen.dart';
import './screens/community/community_screen.dart';

// Drawer Screens

import '../screens/notifications/notification_screen.dart';
import '../screens/about/about_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  /// 🔥 Bottom Nav Screens ONLY
  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    MyCoursesScreen(),
    CommunityScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  /// =======================
  /// 🔥 DRAWER (UTILITY)
  /// =======================
  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [

          /// HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF9D5FF5)],
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Text(
                    "N",
                    style: TextStyle(
                      color: Color(0xFF6C63FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nowfal Nazar",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "Student Dashboard",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// MENU ITEMS

          _drawerItem(Icons.notifications, "Notifications", Colors.red),

          const Divider(),

          _drawerItem(Icons.info_outline, "About", Colors.grey),

          const Spacer(),

          /// LOGOUT
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  /// =======================
  /// 🔥 DRAWER ITEM (FIXED)
  /// =======================
  Widget _drawerItem(IconData icon, String title, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);

        /// 🔥 NAVIGATION
        if (title == "Notifications") {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const NotificationScreen()));
        } else if (title == "About") {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AboutScreen()));
        }
      },
    );
  }

  /// =======================
  /// 🔥 BOTTOM NAV (MAIN)
  /// =======================
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
      selectedItemColor: AppColors.accentViolet,
      unselectedItemColor: AppColors.textMuted,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
        BottomNavigationBarItem(icon: Icon(Icons.play_circle), label: "Courses"),
        BottomNavigationBarItem(icon: Icon(Icons.forum), label: "Community"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}