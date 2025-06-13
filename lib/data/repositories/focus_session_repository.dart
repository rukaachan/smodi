import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:smodi/core/services/database_service.dart';
import 'package:smodi/data/models/focus_session_model.dart';
import 'package:smodi/data/models/local_session_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smodi/data/models/focus_event_model.dart';
import 'package:uuid/uuid.dart';
import 'package:smodi/data/models/sync_payload_model.dart';

/// Repository for managing focus session data.
///
/// This class now handles the logic for saving data to both the local
/// database and the remote Supabase database, ensuring data can be synced.
class FocusSessionRepository {
  final DatabaseService _localDatabase;
  final SupabaseClient _supabaseClient;
  final Connectivity _connectivity;

  FocusSessionRepository({
    required DatabaseService databaseService,
    required SupabaseClient supabaseClient,
    required Connectivity connectivity,
  })  : _localDatabase = databaseService,
        _supabaseClient = supabaseClient,
        _connectivity = connectivity;

  /// Saves a completed focus session to the local DB and, if online, to Supabase.
  Future<void> saveCompletedSession(FocusSession session) async {
    // Ensure the session has the correct final state before saving.
    final completedSession = session.copyWith(
      status: 'completed',
      endTime: DateTime.now(),
      // Ensure the user ID is correctly associated from the current user.
      userId: _supabaseClient.auth.currentUser?.id,
    );

    // 1. Always save to the local database first for speed and offline support.
    print('Attempting to save session to local DB...');
    await _localDatabase.saveFocusSession(completedSession);

    // 2. Check for an internet connection.
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      print('Device is offline. Skipping cloud sync.');
      return; // Exit if offline
    }

    // 3. If online, also save to the Supabase cloud database.
    try {
      print('Device is online. Attempting to save session to Supabase...');
      await _supabaseClient
          .from('focus_sessions')
          .upsert(completedSession.toMap());
      print('✅ Session ${completedSession.sessionId} synced to Supabase.');
    } catch (e) {
      // Log errors if the cloud sync fails for any reason (e.g., policy error).
      print('❌ Supabase sync failed: $e');
    }
  }

  Future<void> saveFocusEvent(
      Map<String, dynamic> eventData, String? currentSessionId) async {
    // Validate required fields
    if (!eventData.containsKey('event')) {
      throw ArgumentError('Event data must contain "event" field');
    }

    final event = FocusEvent(
      eventId: const Uuid().v4(),
      sessionId: currentSessionId,
      eventType: eventData['event']?.toString() ?? 'unknown',
      timestamp: DateTime.now(),
      details: eventData['details'] as Map<String, dynamic>? ?? {},
    );
    await _localDatabase.saveFocusEvent(event);
  }

  Future<List<FocusEvent>> getAllFocusEvents() async {
    return await _localDatabase.getAllFocusEvents();
  }

  Future<List<FocusSession>> getAllFocusSessions() async {
    return await _localDatabase.getAllFocusSessions();
  }

  Future<SyncPayload> getFullSyncPayload() async {
    final sessions = await _localDatabase.getAllFocusSessions();
    final events = await _localDatabase.getAllFocusEvents();

    // The `user` object is no longer created here. It will be added
    // in the UI layer (`generate_qr_screen.dart`) which has access to the AuthService.
    // We pass a placeholder user object which will be replaced.
    return SyncPayload(
      user: const LocalSession(userId: '', email: '', refreshToken: ''),
      sessions: sessions,
      events: events,
    );
  }

  Future<void> mergeSyncPayload(SyncPayload payload) async {
    await _localDatabase.mergeSyncPayload(payload);
  }
}

// Add copyWith to the model for easier state updates
extension FocusSessionCopyWith on FocusSession {
  FocusSession copyWith({
    String? sessionId,
    String? userId,
    String? presetId,
    DateTime? startTime,
    DateTime? endTime,
    String? type,
    int? plannedFocusDurationSec,
    int? plannedBreakDurationSec,
    String? status,
    DateTime? lastModifiedAt,
  }) {
    return FocusSession(
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      presetId: presetId ?? this.presetId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      plannedFocusDurationSec:
          plannedFocusDurationSec ?? this.plannedFocusDurationSec,
      plannedBreakDurationSec:
          plannedBreakDurationSec ?? this.plannedBreakDurationSec,
      status: status ?? this.status,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
    );
  }
}
