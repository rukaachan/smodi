import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smodi/core/services/auth_service.dart';

/// The Supabase implementation of the AuthService.
///
/// This class handles all direct interactions with Supabase for authentication.
/// It also demonstrates how to create a corresponding public profile entry
/// after a new user signs up.
class SupabaseAuthService implements AuthService {
  final SupabaseClient _supabaseClient;

  SupabaseAuthService(this._supabaseClient);

  @override
  Stream<AuthState> get authStateChanges =>
      _supabaseClient.auth.onAuthStateChange;

  @override
  User? get currentUser => _supabaseClient.auth.currentUser;

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      // It's good practice to catch specific exceptions and rethrow
      // them as a custom, domain-specific exception type. For now, we print.
      print('Error signing in: ${e.message}');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    try {
      // We no longer need a custom emailRedirectTo. Supabase will use the
      // default Site URL from your dashboard settings.
      await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      print('Error signing up: ${e.message}');
      rethrow;
    }
  }
}
