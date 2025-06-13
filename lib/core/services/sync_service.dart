import 'package:connectivity_plus/connectivity_plus.dart';
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
    print('SyncService: Performing sync on login...');
    try {
      if (await _isOffline()) return;
      if (_supabaseClient.auth.currentUser == null) return;

      // First, push any local data that might have been created offline.
      await pushOnlySync();

      // Then, pull all data from the cloud to ensure the local DB is up to date.
      await _pullAllRemoteData();

      await _prefs.setInt(
          _lastSyncTimestampKey, DateTime.now().millisecondsSinceEpoch);
      print('✅ SyncService: Sync on login completed successfully.');
    } catch (e) {
      print('❌ SyncService: An error occurred during login sync: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Pushes only local, unsynced changes to the cloud.
  Future<void> pushOnlySync() async {
    if (await _isOffline()) return;
    print('SyncService: Starting push-only sync...');
    try {
      final localChanges = await _repository.getLocalChanges();
      if (localChanges.sessions.isEmpty && localChanges.events.isEmpty) {
        print('SyncService: No local changes to push.');
        return;
      }
      print(
          'SyncService: Pushing ${localChanges.sessions.length} sessions and ${localChanges.events.length} events...');
      await _repository.pushChangesToSupabase(localChanges);
      await _repository.markAsSynced(localChanges);
      print('✅ Push-only sync completed.');
    } catch (e) {
      print('❌ SyncService: An error occurred during push-only sync: $e');
    }
  }

  /// Wipes the local DB and pulls all data for the current user from the cloud.
  Future<void> _pullAllRemoteData() async {
    print('SyncService: Performing full data pull from Supabase...');
    final remotePayload = await _repository.getFullRemotePayload();
    if (remotePayload.sessions.isNotEmpty || remotePayload.events.isNotEmpty) {
      await _repository.mergeRemotePayload(remotePayload);
      print(
          'SyncService: Merged ${remotePayload.sessions.length} sessions and ${remotePayload.events.length} events into local DB.');
    } else {
      print('SyncService: No remote data found for this user.');
    }
  }

  Future<bool> _isOffline() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    final isOffline = connectivityResult.contains(ConnectivityResult.none);
    if (isOffline) print('SyncService: Device is offline. Sync aborted.');
    return isOffline;
  }
}
