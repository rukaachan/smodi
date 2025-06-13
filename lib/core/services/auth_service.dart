import 'package:smodi/data/models/local_session_model.dart';
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

  // Caches the current session
  Future<void> cacheCurrentSession();

  // Caches a specific session
  Future<void> cacheSession(LocalSession session);

  /// Retrieves the locally cached session, if available.
  Future<LocalSession?> getCurrentUserSession();

  /// Signs out the current user.
  Future<void> signOut();

  /// Recovers the session from local storage if available.
  Future<void> recoverSession();
}
