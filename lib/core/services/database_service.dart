import 'package:smodi/data/models/focus_event_model.dart';
import 'package:smodi/data/models/focus_session_model.dart';

/// Abstract interface for the database service.
///
/// Defining an abstract class allows us to decouple our application logic
/// from the specific database implementation (e.g., sqflite). This makes
/// the system more modular and easier to test, as we can provide a mock
/// implementation of this service in our tests.
abstract class DatabaseService {
  /// Initializes the database, creating tables if they don't exist.
  Future<void> init();

  /// Saves a focus session to the database.
  Future<void> saveFocusSession(FocusSession session);

  Future<void> saveFocusEvent(FocusEvent event);

  Future<List<FocusEvent>> getAllFocusEvents();
}
