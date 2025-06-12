import 'package:equatable/equatable.dart';
import 'dart:convert';

/// Data model for a focus event, representing a single AI detection.
///
/// This class is a direct Dart representation of the `focus_events` table.
class FocusEvent extends Equatable {
  final String eventId;
  final String?
      sessionId; // Can be null if event occurs outside a formal session
  final String eventType; // e.g., 'distraction', 'posture', 'activity'
  final DateTime timestamp;
  final int? durationSec;
  final Map<String, dynamic> details; // Stores the JSON details

  const FocusEvent({
    required this.eventId,
    this.sessionId,
    required this.eventType,
    required this.timestamp,
    this.durationSec,
    required this.details,
  });

  /// Converts the instance to a map for database insertion.
  Map<String, dynamic> toMap() {
    return {
      'event_id': eventId,
      'session_id': sessionId,
      'event_type': eventType,
      'timestamp': timestamp.toIso8601String(),
      'duration_sec': durationSec,
      // We store the details map as a JSON encoded string in the TEXT column.
      'details': jsonEncode(details),
    };
  }

  factory FocusEvent.fromMap(Map<String, dynamic> map) {
    return FocusEvent(
      eventId: map['event_id'] as String,
      sessionId: map['session_id'] as String?,
      eventType: map['event_type'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      durationSec: map['duration_sec'] as int?,
      // Decode the JSON string from the database back into a map.
      details: jsonDecode(map['details'] as String? ?? '{}'),
    );
  }

  @override
  List<Object?> get props =>
      [eventId, sessionId, eventType, timestamp, durationSec, details];
}
