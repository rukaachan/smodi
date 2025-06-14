import 'package:flutter/material.dart';
import 'package:smodi/core/colors/color.dart';
import 'package:smodi/features/auth/screens/camera_control_screen.dart';
import 'package:smodi/features/auth/screens/insights_screen.dart';
import 'package:smodi/features/home/widgets/feature_card.dart';

import 'package:flutter/cupertino.dart';
import 'package:smodi/core/di/injection_container.dart';
import 'package:smodi/core/services/auth_service.dart';

import '../focus_session/screens/focus_session_screen.dart';
import '../settings/screens/settings_screen.dart';
// import 'package:smodi/features/user_profile/screens/user_profile_screen.dart'; // Import UserProfileScreen
// import 'package:smodi/features/f1_focus/screens/focus_session_screen.dart';
// import 'package:smodi/features/f2_activity_insights/screens/activity_insight_screen.dart';// Import F2 screen
// import 'package:smodi/features/f3_camera_control/screens/camera_control_screen.dart'; // Import F3 screen
// import 'package:smodi/features/f4_settings/screens/settings_screen.dart'; // Import F4 screen
// import 'package:smodi/features/common_widgets/coming_soon_screen.dart'; // Import placeholder screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Untuk Bottom Navigation Bar, 0 = Home

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Dummy navigation for now based on bottom bar index
    if (index == 0) {
      // Stay on home
    } else {
      // Simulate navigation to other sections if implemented later
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigating to index $index (Coming Soon)!')),
      );
      // Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ComingSoonScreen(featureName: 'Bottom Nav Feature')));
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.headingText, // Background gelap sesuai desain
      appBar: AppBar(
        backgroundColor: AppColors.headingText, // App bar juga gelap
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white), // Icon hamburger
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Buka drawer
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white), // Icon profil
            onPressed: () {
              // Ganti navigasi ke UserProfileScreen
              // Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UserProfileScreen()));
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context), // Drawer navigasi
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome ,',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'this is Smodi', // Ganti WorkSight dengan FocusForge
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ready to learn?', // Atau 'Ready to start!'
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 32),
            // Kartu "Deep Focus"
            FeatureCard(
              title: 'Deep Focus',
              subtitle: 'Configuration',
              icon: Icons.lightbulb_outline,
              onTap: () {
                // Ganti ini untuk menavigasi ke FocusSessionScreen
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FocusSessionScreen()));
              },
              backgroundColor: const Color(0xFF1A237E),
            ),
            const SizedBox(height: 20),
            // Kartu "Activity and Productivity Tracker"
            FeatureCard(
              title: 'Activity and Productivity Tracker',
              icon: Icons.timer_outlined,
              onTap: () {
                // Ganti ini untuk menavigasi ke ActivityInsightsScreen
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InsightsScreen()));
              },
              backgroundColor: const Color(0xFF8BC34A),
            ),
            const SizedBox(height: 20),
            // Kartu "Camera Visual and Control"
            FeatureCard(
              title: 'Camera Visual and Control',
              subtitle: 'Configuration',
              icon: Icons.camera_alt_outlined,
              onTap: () {
                // Ganti ini untuk menavigasi ke CameraControlScreen
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CameraControlScreen()));
              },
              backgroundColor: const Color(0xFF009688), // Teal
            ),
            const SizedBox(height: 20),
            // Kartu "Settings and Personalization"
            FeatureCard(
              title: 'Settings and Personalization',
              icon: Icons.settings_outlined,
              onTap: () {
                // Ganti ini untuk menavigasi ke SettingsScreen
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
              backgroundColor: const Color(0xFF607D8B), // Abu-abu kebiruan
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor: Colors.black, // Latar belakang gelap
      //   selectedItemColor: AppColors.accentColor, // Warna ikon terpilih (kuning)
      //   unselectedItemColor: Colors.white54, // Warna ikon tidak terpilih
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.folder_open), // Ikon folder
      //       label: 'Activity',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.history), // Ikon history/reload
      //       label: 'History',
      //     ),
      //   ],
      // ),
    );
  }

  // Widget untuk Navigation Drawer
  Widget _buildDrawer(BuildContext context) {
    final authService = sl<AuthService>();
    return Drawer(
      backgroundColor: AppColors.headingText, // Warna drawer gelap
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.headingText, // Warna header drawer
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.tabIndicatorColor,
                  child: Icon(Icons.person, size: 40, color: AppColors.headingText),
                ),
                const SizedBox(height: 10),
                const Text(
                  'User Name', // Placeholder nama pengguna
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                const Text(
                  'user.email@example.com', // Placeholder email
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Item menu drawer (sesuai "Frame 1" dan sitemap)
          _buildDrawerMenuItem(
            context,
            title: 'Home',
            icon: Icons.home,
            onTap: () {
              Navigator.pop(context); // Tutup drawer
              setState(() => _selectedIndex = 0); // Set home sebagai selected
              // Tidak perlu navigasi karena sudah di home
            },
            isActive: _selectedIndex == 0,
          ),
          _buildDrawerMenuItem(
            context,
            title: 'Deep Focus',
            subtitle: 'Configuration',
            icon: Icons.lightbulb_outline,
            onTap: () {
              Navigator.pop(context); // Tutup drawer
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FocusSessionScreen())); // <--- Navigasi ke sini
            },
          ),
          _buildDrawerMenuItem(
            context,
            title: 'Activity and Productivity Tracker',
            icon: Icons.timer_outlined,
            onTap: () {
              Navigator.pop(context); // Tutup drawer
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InsightsScreen())); // <--- Navigasi ke sini
            },
          ),
          _buildDrawerMenuItem(
            context,
            title: 'Camera Visual and Control',
            subtitle: 'Configuration',
            icon: Icons.camera_alt_outlined,
            onTap: () {
              Navigator.pop(context); // Tutup drawer
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CameraControlScreen())); // <--- Navigasi ke sini
            },
          ),
          _buildDrawerMenuItem(
            context,
            title: 'Settings and Personalization',
            icon: Icons.settings_outlined,
            onTap: () {
              Navigator.pop(context); // Tutup drawer
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())); // <--- Navigasi ke sini
            },
          ),
          const Divider(color: Colors.white24), // Pemisah
          ListTile(
            leading:
            Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
            title: Text('Sign Out',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onTap: () async {
              final didRequestSignOut = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out?'),
                  content: const Text(
                      'This will delete all local data on this device. It will be re-synced from the cloud the next time you log in.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );

              if (didRequestSignOut ?? false) {
                await authService.signOut();
              }
            },
          ),
        ],
      ),
    );
  }

  // Helper untuk item menu drawer
  Widget _buildDrawerMenuItem(
      BuildContext context, {
        required String title,
        String? subtitle,
        required IconData icon,
        required VoidCallback onTap,
        bool isActive = false,
      }) {
    return Container(
      color: isActive ? Colors.white.withOpacity(0.2) : Colors.transparent, // Warna latar belakang jika aktif
      child: ListTile(
        leading: Icon(icon, color: isActive ? AppColors.tabIndicatorColor : Colors.white54),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? AppColors.tabIndicatorColor : Colors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
          subtitle,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        )
            : null,
        onTap: onTap,
        trailing: isActive
            ? Icon(Icons.keyboard_arrow_right, color: AppColors.tabIndicatorColor) // Indikator jika aktif
            : null,
      ),
    );
  }
}