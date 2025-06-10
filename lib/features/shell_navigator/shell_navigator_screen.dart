import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smodi/features/focus_session/screens/focus_session_screen.dart';

/// The main application shell that holds the bottom navigation bar.
///
/// This screen acts as the primary container for the main features of the app,
/// allowing the user to switch between them seamlessly. It directly corresponds
/// to the "Layar Beranda" in the sitemap.
class ShellNavigatorScreen extends StatefulWidget {
  const ShellNavigatorScreen({super.key});

  @override
  State<ShellNavigatorScreen> createState() => _ShellNavigatorScreenState();
}

class _ShellNavigatorScreenState extends State<ShellNavigatorScreen> {
  int _selectedIndex = 0;

  // A list of the main feature screens. For now, others are placeholders.
  // This directly implements the navigation structure from the sitemap.
  static const List<Widget> _widgetOptions = <Widget>[
    FocusSessionScreen(),
    PlaceholderWidget(text: 'AI Insights & Activity'), // Placeholder for F2
    PlaceholderWidget(text: 'Camera Control & View'), // Placeholder for F3
    PlaceholderWidget(text: 'Settings & Personalization'), // Placeholder for F4
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.timer),
            label: 'Focus',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar_square),
            label: 'Insights',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.camera),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // These properties are essential for a modern look with more than 3 items.
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).textTheme.bodySmall?.color,
        showUnselectedLabels: true,
      ),
    );
  }
}

/// A simple placeholder widget for unimplemented screens.
class PlaceholderWidget extends StatelessWidget {
  final String text;
  const PlaceholderWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}
