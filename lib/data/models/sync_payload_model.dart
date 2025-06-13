import 'dart:convert';
import 'package:smodi/data/models/focus_event_model.dart';
import 'package:smodi/data/models/focus_session_model.dart';
import 'package:smodi/data/models/local_session_model.dart';

/// A container for all data to be synced between devices.
class SyncPayload {
  final LocalSession user;
  final List<FocusSession> sessions;
  final List<FocusEvent> events;
  // Add other data models here in the future (e.g., settings, voice motivators)

  SyncPayload({
    required this.user,
    required this.sessions,
    required this.events,
  });

  factory SyncPayload.fromJson(Map<String, dynamic> json) => SyncPayload(
        user: LocalSession.fromJson(json["user"]),
        sessions: List<FocusSession>.from(
            json["sessions"].map((x) => FocusSession.fromMap(x))),
        events: List<FocusEvent>.from(
            json["events"].map((x) => FocusEvent.fromMap(x))),
      );

  Map<String, dynamic> toJson() => {
        "user": user.toJson(),
        "sessions": List<dynamic>.from(sessions.map((x) => x.toMap())),
        "events": List<dynamic>.from(events.map((x) => x.toMap())),
      };

  // fromRawJson and toRawJson remain the same
  factory SyncPayload.fromRawJson(String str) =>
      SyncPayload.fromJson(json.decode(str));
  String toRawJson() => json.encode(toJson());
}
