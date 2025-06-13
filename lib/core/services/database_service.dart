import 'package:smodi/data/models/focus_event_model.dart';
import 'package:smodi/data/models/focus_session_model.dart';
import 'package:smodi/data/models/sync_payload_model.dart';

/// Abstract interface for the database service.
///
/// This defines the contract for all database operations in the app,
/// allowing for a clean separation between business logic and the
/// specific database implementation (e.g., sqflite).
abstract class DatabaseService {
  /// Initializes the database connection and creates tables if they don't exist.
  Future<void> init();

  /// Saves or updates a focus session in the local database.
  Future<void> saveFocusSession(FocusSession session);

  /// Saves a single focus event (e.g., from the AI) to the local database.
  Future<void> saveFocusEvent(FocusEvent event);

  /// Retrieves all focus events from the local database, ordered by most recent.
  Future<List<FocusEvent>> getAllFocusEvents();

  /// Retrieves all focus sessions from the local database.
  Future<List<FocusSession>> getAllFocusSessions();

  /// Merges a payload of data (from a QR code sync or cloud pull) into the local database.
  Future<void> mergeSyncPayload(SyncPayload payload);

  /// Deletes the entire local database file from the device.
  /// This is a critical step for ensuring user data privacy upon logout.
  Future<void> wipeDatabase();

  /// A utility function for development that prints the contents of key tables
  /// to the debug console for verification.
  Future<void> debugPrintAllData();

  /// Gets only the records that have been created or modified locally and not yet synced.
  Future<SyncPayload> getLocalChanges();

  /// Updates local records to mark them as synced after a successful push to the cloud.
  Future<void> markAsSynced(SyncPayload payload);
}
