import 'package:flutter/material.dart';
import 'package:smodi/core/di/injection_container.dart';
import 'package:smodi/core/services/auth_service.dart';
import 'package:smodi/features/auth/screens/login_screen.dart';
import 'package:smodi/features/shell_navigator/shell_navigator_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    // This StreamBuilder handles live logouts while the user is in the app.
    return StreamBuilder<AuthState>(
      stream: sl<AuthService>().authStateChanges,
      builder: (context, snapshot) {
        // If at any point the auth state becomes null (e.g., after signOut),
        // we immediately navigate back to the login screen.
        if (snapshot.data?.session == null &&
            snapshot.connectionState != ConnectionState.waiting) {
          // Use a post-frame callback to avoid "setState during build" errors.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          });
        }

        // As long as there is a session, show the main app.
        return const ShellNavigatorScreen();
      },
    );
  }
}
