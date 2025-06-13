import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smodi/core/services/auth_service.dart';
import 'package:smodi/data/models/local_session_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The Supabase implementation of the AuthService.
///
/// This class handles all direct interactions with Supabase for authentication
/// and securely caches the user's session for offline access.
class SupabaseAuthService implements AuthService {
  final SupabaseClient _supabaseClient;
  final FlutterSecureStorage _secureStorage;
  static const _localSessionKey = 'local_session';

  SupabaseAuthService(this._supabaseClient, this._secureStorage);

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
      // After a successful online sign-in, cache the session.
      await cacheCurrentSession();
    } on AuthException {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
    // When signing out, clear the local cache.
    await _secureStorage.delete(key: _localSessionKey);
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    try {
      await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'io.supabase.smodi://login-callback/',
      );
    } on AuthException {
      rethrow;
    }
  }

  @override
  Future<void> cacheCurrentSession() async {
    final session = _supabaseClient.auth.currentSession;
    final user = _supabaseClient.auth.currentUser;

    if (user != null && session?.refreshToken != null) {
      final localSession = LocalSession(
        userId: user.id,
        email: user.email!,
        refreshToken: session!.refreshToken!,
      );
      await _secureStorage.write(
        key: _localSessionKey,
        value: localSession.toRawJson(),
      );
      print('✅ Session successfully cached to secure storage.');
    } else {
      print('Could not cache session: No user or refresh token available.');
    }
  }

  @override
  Future<void> cacheSession(LocalSession session) async {
    await _secureStorage.write(
      key: _localSessionKey,
      value: session.toRawJson(),
    );
    print('✅ QR Sync: Session successfully cached to secure storage.');
  }

  /// A robust method to get the current user's session information.
  /// It prioritizes the live, in-memory session from the Supabase client.
  /// If the app is offline or the live session is unavailable, it falls back
  /// to reading the securely cached session from local storage.
  @override
  Future<LocalSession?> getCurrentUserSession() async {
    // Priority 1: Get the live, active user from the Supabase client.
    final liveUser = _supabaseClient.auth.currentUser;
    final liveSession = _supabaseClient.auth.currentSession;

    if (liveUser != null && liveSession?.refreshToken != null) {
      print('AuthService: Found LIVE user session.');
      return LocalSession(
        userId: liveUser.id,
        email: liveUser.email!,
        refreshToken: liveSession!.refreshToken!,
      );
    }

    // Priority 2 (Fallback): If no live user, try to get from secure storage.
    // This covers the case where the app starts offline.
    final sessionJson = await _secureStorage.read(key: _localSessionKey);
    if (sessionJson != null) {
      try {
        print('AuthService: Found CACHED user session.');
        return LocalSession.fromRawJson(sessionJson);
      } catch (e) {
        // If parsing fails, the stored data is corrupt. Delete it.
        print(
            'AuthService: Failed to parse cached session, deleting it. Error: $e');
        await _secureStorage.delete(key: _localSessionKey);
        return null;
      }
    }

    // If no live or cached session is found, return null.
    print('AuthService: No live or cached session found.');
    return null;
  }

  @override
  Future<void> recoverSession() async {
    final sessionJson = await _secureStorage.read(key: _localSessionKey);
    if (sessionJson != null) {
      final localSession = LocalSession.fromRawJson(sessionJson);
      if (localSession.refreshToken.isNotEmpty) {
        try {
          // This tells the Supabase client to try and authenticate with the stored token.
          // If successful, it will emit a new event on the authStateChanges stream.
          await _supabaseClient.auth.setSession(localSession.refreshToken);
          print('Session recovered successfully from refresh token.');
        } catch (e) {
          print('Failed to recover session from refresh token: $e');
          // If recovery fails, the token is likely expired or invalid. Clear the bad session.
          await signOut();
        }
      }
    }
  }
}
