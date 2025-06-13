import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smodi/features/camera_control/bloc/camera_control_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smodi/features/camera_control/bloc/camera_control_event.dart';
import 'package:smodi/features/camera_control/bloc/camera_control_state.dart';
import 'package:smodi/core/di/injection_container.dart';
import 'package:smodi/data/repositories/focus_session_repository.dart';

class CameraControlScreen extends StatelessWidget {
  const CameraControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final socketServerUrl = dotenv.env['SOCKET_SERVER_URL']!;

    return BlocProvider(
      create: (context) => CameraControlBloc(
        focusSessionRepository:
            sl<FocusSessionRepository>(), // Inject repository
      )..add(ConnectToSocketServer(socketServerUrl)),
      child: const _CameraControlView(),
    );
  }
}

class _CameraControlView extends StatelessWidget {
  const _CameraControlView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Eye Dashboard')),
      body: BlocBuilder<CameraControlBloc, CameraControlState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildStatusIndicator(context, state),
                const SizedBox(height: 24),
                // This is the new Live Status Panel, replacing the video player.
                _buildLiveStatusPanel(context, state),
                const Spacer(),
                _buildControlButtons(context, state),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  // ... inside _CameraControlView class ...

  Widget _buildLiveStatusPanel(BuildContext context, CameraControlState state) {
    final theme = Theme.of(context);
    final event = state.lastEvent;

    // --- UI Polish: Parse the event into a human-readable message ---
    final (icon, title, subtitle) = _parseEvent(event);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge,
                ).animate(key: ValueKey(title)).fadeIn(duration: 300.ms),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.textTheme.bodySmall?.color),
                ).animate(key: ValueKey(subtitle)).fadeIn(duration: 300.ms),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, duration: 400.ms);
  }

  /// A helper function to parse the raw event map into displayable content.
  (IconData, String, String) _parseEvent(Map<String, dynamic> event) {
    final eventType = event['event']?.toString() ?? 'unknown';
    final details = event['details'] as Map<String, dynamic>? ?? {};

    switch (eventType) {
      case 'distraction':
        final type = details['type'] ?? 'Unknown';
        return (
          CupertinoIcons.device_phone_portrait,
          'Distraction Detected',
          'Source: $type'
        );
      case 'activity':
        final present = details['userPresent'] ?? false;
        return present
            ? (
                CupertinoIcons.person_fill,
                'User Present',
                'Monitoring is active.'
              )
            : (Icons.person_off_outlined, 'User Away', 'Monitoring is paused.');
      case 'posture':
        final state = details['state'] ?? 'Good';
        return (
          Icons.accessibility_new,
          'Posture Alert',
          'Current state: $state'
        );
      case 'status':
        final isAwake = event['isAwake'] ?? false;
        return (
          CupertinoIcons.power,
          'Device Status',
          isAwake ? 'Awake' : 'Asleep'
        );
      case 'Initializing...':
        return (
          CupertinoIcons.time,
          'Initializing...',
          'Waiting for device connection.'
        );
      default:
        return (
          CupertinoIcons.question_circle,
          'Unknown Event',
          event.toString()
        );
    }
  }

  Widget _buildStatusIndicator(BuildContext context, CameraControlState state) {
    final color = state.isConnected ? Colors.green : Colors.red;
    final text = state.isConnected ? 'Connected to Server' : 'Disconnected';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.circle, color: color, size: 12),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  Widget _buildControlButtons(BuildContext context, CameraControlState state) {
    final bloc = context.read<CameraControlBloc>();
    final isAwake = state.isDeviceAwake;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: !state.isConnected
              ? null
              : () => bloc.add(const SendCommandToDevice('WAKE')),
          icon: const Icon(CupertinoIcons.sunrise_fill),
          label: const Text('Wake'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isAwake
                ? Colors.grey.shade700
                : Theme.of(context).colorScheme.primary,
          ),
        ),
        ElevatedButton.icon(
          onPressed: !state.isConnected
              ? null
              : () => bloc.add(const SendCommandToDevice('SLEEP')),
          icon: const Icon(CupertinoIcons.moon_fill),
          label: const Text('Sleep'),
          style: ElevatedButton.styleFrom(
            backgroundColor: !isAwake
                ? Colors.grey.shade700
                : Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
