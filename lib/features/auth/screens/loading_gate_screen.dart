import 'package:flutter/material.dart';
import 'package:smodi/core/di/injection_container.dart';
import 'package:smodi/core/services/auth_service.dart';
import 'package:smodi/features/auth/screens/login_screen.dart';
import 'package:smodi/features/shell_navigator/shell_navigator_screen.dart';

class LoadingGateScreen extends StatefulWidget {
  const LoadingGateScreen({super.key});

  @override
  State<LoadingGateScreen> createState() => _LoadingGateScreenState();
}

class _LoadingGateScreenState extends State<LoadingGateScreen> {
  @override
  void initState() {
    super.initState();
    _determineInitialRoute();
  }

  Future<void> _determineInitialRoute() async {
    final authService = sl<AuthService>();

    // Use the robust method we already built.
    // This checks for a live session first, then falls back to the secure cache.
    final session = await authService.getCurrentUserSession();

    // Use `mounted` check to prevent errors if the user navigates away
    // while this async operation is in progress.
    if (!mounted) return;

    if (session != null) {
      // If a session exists (live or cached), go to the main app.
      // `pushAndRemoveUntil` ensures the user can't press "back" to the loading screen.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ShellNavigatorScreen()),
        (route) => false,
      );
    } else {
      // If no session exists, go to the login screen.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a simple loading indicator while we determine the route.
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
