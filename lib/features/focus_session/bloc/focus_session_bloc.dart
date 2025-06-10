import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smodi/data/models/focus_session_model.dart';
import 'package:smodi/data/repositories/focus_session_repository.dart';
import 'package:uuid/uuid.dart'; // Add uuid package to pubspec.yaml

// --- EVENTS ---
// (No changes to events)
abstract class FocusSessionEvent extends Equatable {
  const FocusSessionEvent();
  @override
  List<Object> get props => [];
}

class StartTimer extends FocusSessionEvent {
  final int duration;
  const StartTimer({required this.duration});
}

class PauseTimer extends FocusSessionEvent {}

class ResetTimer extends FocusSessionEvent {}

class _TimerTicked extends FocusSessionEvent {
  final int duration;
  const _TimerTicked({required this.duration});
}

// --- STATES ---
// Add a session object to the state to track the current session
abstract class FocusSessionState extends Equatable {
  final int duration;
  final FocusSession session;

  const FocusSessionState(this.duration, this.session);

  @override
  List<Object> get props => [duration, session];
}

class TimerInitial extends FocusSessionState {
  const TimerInitial(int duration, FocusSession session)
      : super(duration, session);
}

class TimerRunInProgress extends FocusSessionState {
  const TimerRunInProgress(int duration, FocusSession session)
      : super(duration, session);
}

class TimerRunPause extends FocusSessionState {
  const TimerRunPause(int duration, FocusSession session)
      : super(duration, session);
}

class TimerRunComplete extends FocusSessionState {
  const TimerRunComplete(FocusSession session) : super(0, session);
}

// --- BLOC ---
class FocusSessionBloc extends Bloc<FocusSessionEvent, FocusSessionState> {
  Timer? _timer;
  final int _initialDuration;
  final FocusSessionRepository _focusSessionRepository;
  final Uuid _uuid = const Uuid(); // For generating unique IDs

  FocusSessionBloc({
    required int initialDuration,
    required FocusSessionRepository focusSessionRepository,
  })  : _initialDuration = initialDuration,
        _focusSessionRepository = focusSessionRepository,
        super(
          TimerInitial(
            initialDuration,
            // Create a dummy initial session
            FocusSession(
              sessionId: '',
              userId: 'guest', // Placeholder user ID
              startTime: DateTime.now(),
              type: 'POMODORO',
              plannedFocusDurationSec: initialDuration,
              plannedBreakDurationSec: 5 * 60,
              status: 'initial',
              lastModifiedAt: DateTime.now(),
            ),
          ),
        ) {
    on<StartTimer>(_onStarted);
    on<PauseTimer>(_onPaused);
    on<ResetTimer>(_onReset);
    on<_TimerTicked>(_onTicked);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  void _onStarted(StartTimer event, Emitter<FocusSessionState> emit) {
    // Create a new session when the timer starts for the first time
    final newSession = state.session.sessionId.isEmpty
        ? FocusSession(
            sessionId: _uuid.v4(),
            userId: 'guest',
            startTime: DateTime.now(),
            type: 'POMODORO',
            plannedFocusDurationSec: _initialDuration,
            plannedBreakDurationSec: 5 * 60,
            status: 'active',
            lastModifiedAt: DateTime.now(),
          )
        : state.session.copyWith(status: 'active');

    emit(TimerRunInProgress(event.duration, newSession));
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(_TimerTicked(duration: state.duration - 1));
    });
  }

  void _onPaused(PauseTimer event, Emitter<FocusSessionState> emit) {
    if (state is TimerRunInProgress) {
      _timer?.cancel();
      emit(TimerRunPause(
          state.duration, state.session.copyWith(status: 'paused')));
    }
  }

  void _onReset(ResetTimer event, Emitter<FocusSessionState> emit) {
    _timer?.cancel();
    // Create a new dummy session for the next run
    final newSession = FocusSession(
      sessionId: '',
      userId: 'guest',
      startTime: DateTime.now(),
      type: 'POMODORO',
      plannedFocusDurationSec: _initialDuration,
      plannedBreakDurationSec: 5 * 60,
      status: 'initial',
      lastModifiedAt: DateTime.now(),
    );
    emit(TimerInitial(_initialDuration, newSession));
  }

  void _onTicked(_TimerTicked event, Emitter<FocusSessionState> emit) {
    if (event.duration > 0) {
      emit(TimerRunInProgress(event.duration, state.session));
    } else {
      _timer?.cancel();
      // When the timer completes, save the session to the database.
      _focusSessionRepository.saveCompletedSession(state.session);
      emit(TimerRunComplete(state.session.copyWith(status: 'completed')));
    }
  }
}
