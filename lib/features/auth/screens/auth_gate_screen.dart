import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smodi/core/di/injection_container.dart';
import 'package:smodi/core/services/auth_service.dart';
import 'package:smodi/features/auth/screens/login_screen.dart';
import 'package:smodi/features/shell_navigator/shell_navigator_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    // We immediately start listening to the live auth stream.
    // The Supabase client will emit its initial state (likely "logged out").
    _authSubscription = sl<AuthService>().authStateChanges.listen((data) {
      // This listener will handle live logins and logouts.
      // We don't need to do anything here because the StreamBuilder below will handle it.
    });

    // We also attempt to recover the session from secure storage.
    // If successful, this will cause the Supabase client to emit a new
    // "logged in" state on the stream, which the StreamBuilder will catch.
    sl<AuthService>().recoverSession();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The UI is a StreamBuilder that ALWAYS listens for auth changes.
    return StreamBuilder<AuthState>(
      stream: sl<AuthService>().authStateChanges,
      builder: (context, snapshot) {
        // The `recoverSession` call in initState will eventually cause this
        // stream to fire with a valid session if one was cached.
        if (snapshot.hasData && snapshot.data?.session != null) {
          return const ShellNavigatorScreen();
        } else {
          // The initial state, or the state after a logout, will have no session.
          return const LoginScreen();
        }
      },
    );
  }
}
