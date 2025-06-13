import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smodi/core/services/auth_service.dart';
import 'package:smodi/core/services/database_service.dart';
import 'package:smodi/core/services/logging_service.dart';
import 'package:smodi/core/services/sync_service.dart';
import 'package:smodi/data/models/local_session_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService implements AuthService {
  final SupabaseClient _supabaseClient;
  final FlutterSecureStorage _secureStorage;
  final DatabaseService _databaseService;
  final SharedPreferences _prefs;
  final SyncService _syncService;

  static const _localSessionKey = 'local_session';
  static const _lastActiveUserKey = 'last_active_user_id';

  SupabaseAuthService(this._supabaseClient, this._secureStorage,
      this._databaseService, this._prefs, this._syncService);

  @override
  Stream<AuthState> get authStateChanges =>
      _supabaseClient.auth.onAuthStateChange;

  @override
  User? get currentUser => _supabaseClient.auth.currentUser;

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      final lastUserId = _prefs.getString(_lastActiveUserKey);
      final response = await _supabaseClient.auth
          .signInWithPassword(email: email, password: password);
      final newUserId = response.user?.id;
      if (newUserId == null) throw Exception('Sign in failed.');

      if (lastUserId != null && lastUserId != newUserId) {
        LoggingService.info(
            'Account switch detected! Syncing old user data before wiping.');
        await _syncService.pushOnlySync();
        await _databaseService.wipeDatabase();
      }

      await cacheCurrentSession();
      await _prefs.setString(_lastActiveUserKey, newUserId);
    } on AuthException {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
    await _secureStorage.delete(key: _localSessionKey);
    LoggingService.info(
        'Sign out complete: Session cleared. Local data preserved for next sync.');
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
          key: _localSessionKey, value: localSession.toRawJson());
    }
  }

  @override
  Future<void> cacheSession(LocalSession session) async {
    await _secureStorage.write(
        key: _localSessionKey, value: session.toRawJson());
  }

  @override
  Future<LocalSession?> getCurrentUserSession() async {
    final liveUser = _supabaseClient.auth.currentUser;
    final liveSession = _supabaseClient.auth.currentSession;
    if (liveUser != null && liveSession?.refreshToken != null) {
      return LocalSession(
        userId: liveUser.id,
        email: liveUser.email!,
        refreshToken: liveSession!.refreshToken!,
      );
    }
    final sessionJson = await _secureStorage.read(key: _localSessionKey);
    if (sessionJson != null) {
      try {
        return LocalSession.fromRawJson(sessionJson);
      } catch (e) {
        await _secureStorage.delete(key: _localSessionKey);
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> recoverSession() async {
    final sessionJson = await _secureStorage.read(key: _localSessionKey);
    if (sessionJson != null) {
      final localSession = LocalSession.fromRawJson(sessionJson);

      // Check if we have a refresh token to use.
      if (localSession.refreshToken.isNotEmpty) {
        try {
          // This is the key step: tell the Supabase client to try and
          // re-authenticate using the stored refresh token.
          final response =
              await _supabaseClient.auth.setSession(localSession.refreshToken);

          if (response.user != null) {
            LoggingService.info(
                '✅ Session successfully recovered from secure storage.');
            // After recovery, it's good practice to re-cache the session
            // in case a new refresh token was issued.
            await cacheCurrentSession();
          } else {
            // If setSession results in no user, the token was invalid.
            await signOut(); // Sign out completely to clear bad data.
          }
        } catch (e) {
          LoggingService.error(
              '❌ Failed to recover session, token might be expired or invalid: $e');
          // The token is bad, so sign out to clear everything.
          await signOut();
        }
      }
    }
  }
}
