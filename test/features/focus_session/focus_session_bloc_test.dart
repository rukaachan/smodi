import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smodi/data/models/focus_session_model.dart';
import 'package:smodi/data/repositories/focus_session_repository.dart';
import 'package:smodi/features/focus_session/bloc/focus_session_bloc.dart';

// --- MOCKS & FAKES ---

// Create a mock class for the repository.
class MockFocusSessionRepository extends Mock
    implements FocusSessionRepository {}

// Create a Fake class for our model. This is used to register a fallback value.
// This is a standard pattern required by mocktail for using matchers like `any()`
// with custom types in a null-safe environment.
class FakeFocusSession extends Fake implements FocusSession {}

void main() {
  // This `setUpAll` block runs once before all tests in this file.
  setUpAll(() {
    // We register our FakeFocusSession as the fallback for the FocusSession type.
    // This resolves the error.
    registerFallbackValue(FakeFocusSession());
  });

  group('FocusSessionBloc', () {
    const int initialDuration = 60;
    late FocusSessionRepository mockFocusSessionRepository;

    setUp(() {
      mockFocusSessionRepository = MockFocusSessionRepository();
    });

    FocusSessionBloc buildBloc() {
      return FocusSessionBloc(
        initialDuration: initialDuration,
        focusSessionRepository: mockFocusSessionRepository,
      );
    }

    test('emits [TimerInitial] with a default session when created', () {
      final bloc = buildBloc();
      expect(bloc.state.duration, initialDuration);
      expect(bloc.state, isA<TimerInitial>());
    });

    blocTest<FocusSessionBloc, FocusSessionState>(
      'emits [TimerRunInProgress] when StartTimer is added',
      build: buildBloc,
      act: (bloc) => bloc.add(const StartTimer(duration: initialDuration)),
      expect: () => [
        isA<TimerRunInProgress>()
            .having((s) => s.duration, 'duration', initialDuration),
      ],
    );

    blocTest<FocusSessionBloc, FocusSessionState>(
      'emits [TimerRunPause] when PauseTimer is added while running',
      build: buildBloc,
      act: (bloc) {
        bloc.add(const StartTimer(duration: initialDuration));
        bloc.add(PauseTimer());
      },
      skip: 1,
      expect: () => [
        isA<TimerRunPause>()
            .having((s) => s.duration, 'duration', initialDuration),
      ],
    );

    blocTest<FocusSessionBloc, FocusSessionState>(
      'emits [TimerRunComplete] and saves session when timer reaches 0',
      setUp: () {
        // This `when` call will now work because we registered a fallback value.
        when(() => mockFocusSessionRepository.saveCompletedSession(any()))
            .thenAnswer((_) async {});
      },
      build: () => FocusSessionBloc(
        initialDuration: 1,
        focusSessionRepository: mockFocusSessionRepository,
      ),
      act: (bloc) => bloc.add(const StartTimer(duration: 1)),
      wait: const Duration(seconds: 1),
      expect: () => [
        isA<TimerRunInProgress>().having((s) => s.duration, 'duration', 1),
        isA<TimerRunComplete>().having((s) => s.duration, 'duration', 0),
      ],
      verify: (_) {
        verify(() => mockFocusSessionRepository.saveCompletedSession(any()))
            .called(1);
      },
    );

    blocTest<FocusSessionBloc, FocusSessionState>(
      'emits [TimerInitial] when ResetTimer is added',
      build: buildBloc,
      act: (bloc) {
        bloc.add(const StartTimer(duration: initialDuration));
        bloc.add(ResetTimer());
      },
      skip: 1,
      expect: () => [
        isA<TimerInitial>()
            .having((s) => s.duration, 'duration', initialDuration),
      ],
    );
  });
}
