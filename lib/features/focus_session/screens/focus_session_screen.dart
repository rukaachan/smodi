import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:smodi/features/focus_session/bloc/focus_session_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// The main screen for the Focus Session feature (F1 in the sitemap).
///
/// This screen allows users to start, pause, and manage their focus timers.
/// It's built reactively using a BLoC for state management.
class FocusSessionScreen extends StatelessWidget {
  const FocusSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the FocusSessionBloc to this widget subtree.
    // We use GetIt (sl) to retrieve the factory-registered BLoC instance.
    return BlocProvider(
      create: (context) => GetIt.instance<FocusSessionBloc>(),
      child: const _FocusSessionView(),
    );
  }
}

class _FocusSessionView extends StatelessWidget {
  const _FocusSessionView();

  /// Formats a duration in seconds into a MM:SS string.
  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bloc = context.watch<FocusSessionBloc>();
    final state = bloc.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Session'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        // This entire view fades in for a smooth entry animation.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            // The main timer display.
            // It listens to the BLoC state and rebuilds whenever the duration changes.
            BlocBuilder<FocusSessionBloc, FocusSessionState>(
              builder: (context, state) {
                return Text(
                  _formatDuration(state.duration),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 80,
                  ),
                )
                    .animate(key: ValueKey(state.duration))
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.1, end: 0);
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Pomodoro Technique', // Placeholder for timer type
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const Spacer(flex: 2),
            // The timer control buttons.
            // The buttons shown will change based on the timer's state.
            _buildControlButtons(context, state),
            const Spacer(),
          ],
        ).animate().fadeIn(duration: 500.ms),
      ),
    );
  }

  /// Builds the control buttons based on the current timer state.
  /// This provides clear, stateful user feedback as requested by HIG.
  Widget _buildControlButtons(BuildContext context, FocusSessionState state) {
    final bloc = context.read<FocusSessionBloc>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Reset Button - always visible
        IconButton(
          icon: const Icon(CupertinoIcons.arrow_counterclockwise),
          iconSize: 32,
          onPressed: () => bloc.add(ResetTimer()),
        ).animate().scale(),

        // This is the primary action button which animates its change.
        // It swaps between a "Start" and "Pause" button.
        if (state is TimerInitial || state is TimerRunPause)
          _buildActionButton(
            context: context,
            icon: CupertinoIcons.play_arrow_solid,
            onPressed: () => bloc.add(StartTimer(duration: state.duration)),
          ).animate(key: const ValueKey('start')).swap(
                duration: 300.ms,
                builder: (_, __) => _buildActionButton(
                  context: context,
                  icon: CupertinoIcons.pause_solid,
                  onPressed: () => bloc.add(PauseTimer()),
                ),
              ),
        if (state is TimerRunInProgress)
          _buildActionButton(
            context: context,
            icon: CupertinoIcons.pause_solid,
            onPressed: () => bloc.add(PauseTimer()),
          ).animate(key: const ValueKey('pause')).fadeIn(),

        if (state is TimerRunComplete)
          _buildActionButton(
            context: context,
            icon: CupertinoIcons.play_arrow_solid,
            onPressed: () => bloc.add(ResetTimer()), // Reset on complete
          ).animate(key: const ValueKey('complete')).fadeIn(),

        // Placeholder for a settings/configuration button
        IconButton(
          icon: const Icon(CupertinoIcons.slider_horizontal_3),
          iconSize: 32,
          onPressed: () {},
        ).animate().scale(),
      ],
    );
  }

  /// A helper to build the main circular action button.
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(24),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.black,
      ),
      child: Icon(icon, size: 48),
    );
  }
}
