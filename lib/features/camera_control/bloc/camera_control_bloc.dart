import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smodi/data/repositories/focus_session_repository.dart';
import 'package:smodi/features/camera_control/bloc/camera_control_event.dart';
import 'package:smodi/features/camera_control/bloc/camera_control_state.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class CameraControlBloc extends Bloc<CameraControlEvent, CameraControlState> {
  WebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;

  final FocusSessionRepository _focusSessionRepository;

  CameraControlBloc({required FocusSessionRepository focusSessionRepository})
      : _focusSessionRepository = focusSessionRepository,
        super(const CameraControlInitial()) {
    on<ConnectToSocketServer>(_onConnect);
    on<SendCommandToDevice>(_onSendCommand);
    on<DeviceEventReceived>(_onDeviceEventReceived);
    on<DisconnectFromSocketServer>(_onDisconnect);
  }

  void _onConnect(
      ConnectToSocketServer event, Emitter<CameraControlState> emit) {
    try {
      final serverUrl = event.serverUrl.replaceFirst('http', 'ws');
      _channel = WebSocketChannel.connect(Uri.parse(serverUrl));
      print('WebSocket: Connecting to $serverUrl');

      if (event.serverUrl.isEmpty) {
        throw Exception('Socket server URL is empty.');
      }

      // Ensure the URL is valid and starts with http or https before replacing.
      String wsUrl;
      if (event.serverUrl.startsWith('https://')) {
        wsUrl = event.serverUrl.replaceFirst('https', 'wss');
      } else if (event.serverUrl.startsWith('http://')) {
        wsUrl = event.serverUrl.replaceFirst('http', 'ws');
      } else {
        throw Exception('Invalid socket server URL format.');
      }

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      print('WebSocket: Connecting to $wsUrl');

      _channel!.sink.add(jsonEncode({'event': 'register_flutter_app'}));
      emit(state.copyWith(isConnected: true));

      _channelSubscription = _channel!.stream.listen(
        (message) {
          print('WebSocket: Message received: $message');
          try {
            final data = jsonDecode(message) as Map<String, dynamic>;
            add(DeviceEventReceived(data));
          } catch (e) {
            print('WebSocket: Could not parse message json. Error: $e');
          }
        },
        onDone: () {
          print('WebSocket: Channel closed.');
          add(DisconnectFromSocketServer()); // Use an event to handle state change
        },
        onError: (error) {
          print('WebSocket: Channel error: $error');
          emit(const CameraControlError('Connection lost.'));
        },
      );
    } catch (e) {
      print('WebSocket connection error: $e');
      emit(const CameraControlError('Failed to connect to the server.'));
    }
  }

  void _onSendCommand(
      SendCommandToDevice event, Emitter<CameraControlState> emit) {
    if (_channel != null) {
      final commandPayload = jsonEncode({
        'event': 'command_to_iot',
        'data': {'command': event.command}
      });
      _channel!.sink.add(commandPayload);
    }
  }

  void _onDeviceEventReceived(
      DeviceEventReceived event, Emitter<CameraControlState> emit) {
    _focusSessionRepository.saveFocusEvent(event.eventData, null);
    emit(state.copyWith(
      lastEvent: event.eventData,
      isDeviceAwake: event.eventData['isAwake'] ?? state.isDeviceAwake,
    ));
  }

  void _onDisconnect(
      DisconnectFromSocketServer event, Emitter<CameraControlState> emit) {
    _channelSubscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    _channelSubscription = null;
    emit(const CameraControlInitial());
  }

  @override
  Future<void> close() {
    // --- THIS IS THE FIX ---
    // The close method should only clean up resources. It should not emit states.
    // We call the _onDisconnect handler via an event if needed, but cleanup is primary.
    _channelSubscription?.cancel();
    _channel?.sink.close();
    return super.close();
  }
}
