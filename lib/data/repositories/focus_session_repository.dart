import 'package:smodi/core/services/database_service.dart';
import 'package:smodi/data/models/focus_session_model.dart';

/// Repository for managing focus session data.
///
/// This class acts as a mediator between the business logic (BLoCs) and the
/// data layer (DatabaseService). It provides a clean API for feature-related
/// data operations, abstracting away the underlying data source details.
class FocusSessionRepository {
  final DatabaseService _databaseService;

  FocusSessionRepository(this._databaseService);

  /// Saves a completed focus session to the local database.
  ///
  /// In a real-world scenario, this would also handle creating related
  /// focus events, like 'session_started' or 'session_completed'.
  Future<void> saveCompletedSession(FocusSession session) async {
    // Here, we ensure the session is marked as completed before saving.
    final completedSession = session.copyWith(
      status: 'completed',
      endTime: DateTime.now(),
    );
    await _databaseService.saveFocusSession(completedSession);

    // TODO: Create and save a 'session_completed' FocusEvent.
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
