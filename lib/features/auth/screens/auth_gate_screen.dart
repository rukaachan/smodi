import 'package:flutter/material.dart';
import 'package:smodi/core/di/injection_container.dart';
import 'package:smodi/core/services/auth_service.dart';
import 'package:smodi/features/auth/screens/login_screen.dart';
import 'package:smodi/features/shell_navigator/shell_navigator_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// This widget is now much simpler, with no state or listeners.
class AuthGateScreen extends StatelessWidget {
  const AuthGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: sl<AuthService>().authStateChanges,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data?.session;
        if (session != null) {
          return const ShellNavigatorScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
