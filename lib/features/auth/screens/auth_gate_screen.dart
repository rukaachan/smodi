import 'package:flutter/material.dart';
import 'package:smodi/core/di/injection_container.dart';
import 'package:smodi/core/services/auth_service.dart';
import 'package:smodi/features/auth/screens/login_screen.dart';
import 'package:smodi/features/shell_navigator/shell_navigator_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGateScreen extends StatelessWidget {
  const AuthGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: sl<AuthService>().authStateChanges,
      builder: (context, snapshot) {
        // The stream will emit an initial value. If a session was recovered in main.dart,
        // `snapshot.data.session` will not be null.
        final session = snapshot.data?.session;

        if (session != null) {
          // If a session exists (from login, QR sync, or startup recovery), show the main app.
          return const ShellNavigatorScreen();
        } else {
          // If no session, show the login screen.
          return const LoginScreen();
        }
      },
    );
  }
}
