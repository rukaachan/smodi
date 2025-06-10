import 'package:supabase_flutter/supabase_flutter.dart';

/// Abstract interface for the Authentication service.
///
/// This decouples our UI and business logic from the specific auth provider
/// (Supabase), adhering to clean architecture principles.
abstract class AuthService {
  /// Stream that notifies of authentication state changes.
  Stream<AuthState> get authStateChanges;

  /// The current user, if one is signed in.
  User? get currentUser;

  /// Signs up a new user with email and password.
  Future<void> signUp({required String email, required String password});

  /// Signs in a user with email and password.
  Future<void> signIn({required String email, required String password});

  /// Signs out the current user.
  Future<void> signOut();
}
