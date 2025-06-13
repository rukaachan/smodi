import 'package:smodi/data/models/focus_event_model.dart';
import 'package:smodi/data/models/focus_session_model.dart';
import 'package:smodi/data/models/sync_payload_model.dart';

/// Abstract interface for the database service.
///
/// Defining an abstract class allows us to decouple our application logic
/// from the specific database implementation (e.g., sqflite). This makes
/// the system more modular and easier to test, as we can provide a mock
/// implementation of this service in our tests.
// ... imports ...

abstract class DatabaseService {
  Future<void> init();
  Future<void> saveFocusSession(FocusSession session);
  Future<void> saveFocusEvent(FocusEvent event);
  Future<List<FocusEvent>> getAllFocusEvents();

  Future<List<FocusSession>> getAllFocusSessions();

  Future<void> mergeSyncPayload(SyncPayload payload);
}
