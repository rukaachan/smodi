import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smodi/data/models/focus_event_model.dart';
import 'package:smodi/data/repositories/focus_session_repository.dart';
import 'package:smodi/features/insights/bloc/insights_event.dart';
import 'package:smodi/features/insights/bloc/insights_state.dart';

// ... imports ...

class InsightsBloc extends Bloc<InsightsEvent, InsightsState> {
  final FocusSessionRepository _focusSessionRepository;

  InsightsBloc({required FocusSessionRepository focusSessionRepository})
      : _focusSessionRepository = focusSessionRepository,
        super(const InsightsState()) {
    on<LoadInsightsData>(_onLoadInsightsData);
  }

  Future<void> _onLoadInsightsData(
    LoadInsightsData event,
    Emitter<InsightsState> emit,
  ) async {
    emit(state.copyWith(status: InsightsStatus.loading));
    try {
      final events = await _focusSessionRepository.getAllFocusEvents();

      // --- NEW: Data Processing Logic ---
      final chartData = _processEventsForChart(events);

      emit(state.copyWith(
        status: InsightsStatus.success,
        events: events,
        dailyDistractionCounts:
            chartData, // Pass the processed data to the state
      ));
    } catch (e) {
      emit(state.copyWith(
        status: InsightsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Aggregates a list of events into a map of daily distraction counts for the last 7 days.
  Map<int, int> _processEventsForChart(List<FocusEvent> events) {
    // Initialize a map for the last 7 days (0=Mon, 1=Tue, ..., 6=Sun) with 0 counts.
    final Map<int, int> dailyCounts = {for (var i = 0; i < 7; i++) i: 0};
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    // Filter for distraction events within the last week.
    final recentDistractions = events.where((event) =>
        event.eventType == 'distraction' &&
        event.timestamp.isAfter(sevenDaysAgo));

    // Count the events for each day of the week.
    for (final event in recentDistractions) {
      // DateTime.weekday returns 1 for Monday, 7 for Sunday. We adjust it to be 0-indexed.
      final dayOfWeek = event.timestamp.weekday - 1;
      dailyCounts[dayOfWeek] = (dailyCounts[dayOfWeek] ?? 0) + 1;
    }

    return dailyCounts;
  }
}
