import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smodi/data/repositories/focus_session_repository.dart';
import 'package:smodi/features/camera_control/bloc/camera_control_event.dart';
import 'package:smodi/features/camera_control/bloc/camera_control_state.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class CameraControlBloc extends Bloc<CameraControlEvent, CameraControlState> {
  late IO.Socket _socket;
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
      _socket = IO.io(event.serverUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      });

      _socket.onConnect((_) {
        print('Socket connected');
        _socket.emit('register_flutter_app');
        emit(state.copyWith(isConnected: true));
      });

      _socket.on('iot_status_update', (data) {
        print('Received event from server: $data');
        if (data is Map<String, dynamic>) {
          // --- THIS IS THE FIX ---
          // Add the new public event.
          add(DeviceEventReceived(data));
        }
      });

      _socket.onDisconnect((_) {
        print('Socket disconnected');
        emit(state.copyWith(
            isConnected: false,
            isDeviceAwake: false,
            lastEvent: {'event': 'Disconnected'}));
      });
    } catch (e) {
      print('Socket connection error: $e');
      emit(const CameraControlError('Failed to connect to the server.'));
    }
  }

  void _onSendCommand(
      SendCommandToDevice event, Emitter<CameraControlState> emit) {
    if (_socket.connected) {
      _socket.emit('command_to_iot', {'command': event.command});
    }
  }

  // --- THIS IS THE FIX ---
  // Renamed the handler method for clarity and to match the new event.
  void _onDeviceEventReceived(
      DeviceEventReceived event, Emitter<CameraControlState> emit) {
    // First, save the event to the database via the repository.
    // We need to know the active session ID, which we can get from the FocusSessionBloc later.
    // For now, we'll pass null.
    _focusSessionRepository.saveFocusEvent(event.eventData, null);

    // Then, update the UI state as before.
    emit(state.copyWith(
      lastEvent: event.eventData,
      isDeviceAwake: event.eventData['isAwake'] ?? state.isDeviceAwake,
    ));
  }

  void _onDisconnect(
      DisconnectFromSocketServer event, Emitter<CameraControlState> emit) {
    _socket.dispose();
    emit(const CameraControlInitial());
  }

  @override
  Future<void> close() {
    _socket.dispose();
    return super.close();
  }
}
