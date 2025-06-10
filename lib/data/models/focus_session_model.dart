import 'package:equatable/equatable.dart';

/// Data model for a focus session.
///
/// This class is a direct Dart representation of the `focus_sessions` table
/// from the provided database design. Using `Equatable` allows for easy
/// value-based comparison, which is essential for state management with BLoC.
///
/// The fields are nullable to handle cases where a session might be in progress
/// or data is partially loaded.
class FocusSession extends Equatable {
  final String sessionId;
  final String userId;
  final String? presetId;
  final DateTime startTime;
  final DateTime? endTime;
  final String type; // e.g., 'POMODORO', 'CUSTOM'
  final int plannedFocusDurationSec;
  final int plannedBreakDurationSec;
  final String status; // e.g., 'active', 'paused', 'completed'
  final DateTime lastModifiedAt;

  const FocusSession({
    required this.sessionId,
    required this.userId,
    this.presetId,
    required this.startTime,
    this.endTime,
    required this.type,
    required this.plannedFocusDurationSec,
    required this.plannedBreakDurationSec,
    required this.status,
    required this.lastModifiedAt,
  });

  /// Creates an instance from a map (e.g., from a database query).
  /// This is a factory constructor for deserialization.
  factory FocusSession.fromMap(Map<String, dynamic> map) {
    return FocusSession(
      sessionId: map['session_id'] as String,
      userId: map['user_id'] as String,
      presetId: map['preset_id'] as String?,
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: map['end_time'] != null
          ? DateTime.parse(map['end_time'] as String)
          : null,
      type: map['type'] as String,
      plannedFocusDurationSec: map['planned_focus_duration_sec'] as int,
      plannedBreakDurationSec: map['planned_break_duration_sec'] as int,
      status: map['status'] as String,
      lastModifiedAt: DateTime.parse(map['last_modified_at'] as String),
    );
  }

  /// Converts the instance to a map for database insertion/updates.
  /// This is a method for serialization.
  Map<String, dynamic> toMap() {
    return {
      'session_id': sessionId,
      'user_id': userId,
      'preset_id': presetId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'type': type,
      'planned_focus_duration_sec': plannedFocusDurationSec,
      'planned_break_duration_sec': plannedBreakDurationSec,
      'status': status,
      'last_modified_at': lastModifiedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        sessionId,
        userId,
        presetId,
        startTime,
        endTime,
        type,
        plannedFocusDurationSec,
        plannedBreakDurationSec,
        status,
        lastModifiedAt,
      ];
}
