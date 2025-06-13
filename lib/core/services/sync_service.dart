import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:smodi/core/services/logging_service.dart';
import 'package:smodi/data/repositories/focus_session_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SyncService {
  final FocusSessionRepository _repository;
  final Connectivity _connectivity;
  final SupabaseClient _supabaseClient;
  final SharedPreferences _prefs;
  bool _isSyncing = false;

  static const _lastSyncTimestampKey = 'last_sync_timestamp';

  SyncService({
    required FocusSessionRepository repository,
    required Connectivity connectivity,
    required SupabaseClient supabaseClient,
    required SharedPreferences prefs,
  })  : _repository = repository,
        _connectivity = connectivity,
        _supabaseClient = supabaseClient,
        _prefs = prefs;

  /// The main sync method called after a user logs in.
  Future<void> syncOnLogin() async {
    if (_isSyncing) return;
    _isSyncing = true;
    LoggingService.debug('Performing sync on login...');
    try {
      if (await _isOffline()) return;
      if (_supabaseClient.auth.currentUser == null) return;

      // First, push any local data that might have been created offline.
      await pushOnlySync();

      // Then, pull all data from the cloud to ensure the local DB is up to date.
      await _pullAllRemoteData();

      await _prefs.setInt(
          _lastSyncTimestampKey, DateTime.now().millisecondsSinceEpoch);
      LoggingService.info('Sync on login completed successfully');
    } catch (e) {
      LoggingService.error('Login sync error', e);
    } finally {
      _isSyncing = false;
    }
  }

  /// Pushes only local, unsynced changes to the cloud.
  Future<void> pushOnlySync() async {
    if (await _isOffline()) return;
    LoggingService.debug('Starting push-only sync');
    try {
      final localChanges = await _repository.getLocalChanges();
      if (localChanges.sessions.isEmpty && localChanges.events.isEmpty) {
        LoggingService.debug('No local changes to push');
        return;
      }
      LoggingService.debug(
          'Pushing ${localChanges.sessions.length} sessions and ${localChanges.events.length} events');
      await _repository.pushChangesToSupabase(localChanges);
      await _repository.markAsSynced(localChanges);
      LoggingService.info('Push-only sync completed');
    } catch (e) {
      LoggingService.error('Push-only sync error', e);
    }
  }

  /// Wipes the local DB and pulls all data for the current user from the cloud.
  Future<void> _pullAllRemoteData() async {
    LoggingService.debug('Performing full data pull from Supabase');
    final remotePayload = await _repository.getFullRemotePayload();
    if (remotePayload.sessions.isNotEmpty || remotePayload.events.isNotEmpty) {
      await _repository.mergeRemotePayload(remotePayload);
      LoggingService.info(
          'Merged ${remotePayload.sessions.length} sessions and ${remotePayload.events.length} events');
    } else {
      LoggingService.debug('No remote data found for this user');
    }
  }

  Future<bool> _isOffline() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    final isOffline = connectivityResult.contains(ConnectivityResult.none);
    if (isOffline) LoggingService.warning('Device is offline. Sync aborted');
    return isOffline;
  }
}
