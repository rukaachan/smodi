import 'package:equatable/equatable.dart';
import 'package:smodi/data/models/focus_event_model.dart';

enum InsightsStatus { initial, loading, success, failure }

class InsightsState extends Equatable {
  final InsightsStatus status;
  final List<FocusEvent> events;
  final Map<int, int> dailyDistractionCounts;
  final String errorMessage;

  const InsightsState({
    this.status = InsightsStatus.initial,
    this.events = const [],
    this.dailyDistractionCounts = const {},
    this.errorMessage = '',
  });

  InsightsState copyWith({
    InsightsStatus? status,
    List<FocusEvent>? events,
    Map<int, int>? dailyDistractionCounts,
    String? errorMessage,
  }) {
    return InsightsState(
      status: status ?? this.status,
      events: events ?? this.events,
      dailyDistractionCounts:
          dailyDistractionCounts ?? this.dailyDistractionCounts,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props =>
      [status, events, dailyDistractionCounts, errorMessage];
}
