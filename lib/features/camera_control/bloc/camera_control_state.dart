import 'package:equatable/equatable.dart';

class CameraControlState extends Equatable {
  final bool isConnected;
  final bool isDeviceAwake;
  // This map will hold the latest AI event data from the device.
  final Map<String, dynamic> lastEvent;

  const CameraControlState({
    this.isConnected = false,
    this.isDeviceAwake = false,
    this.lastEvent = const {},
  });

  // copyWith for easy, immutable state updates.
  CameraControlState copyWith({
    bool? isConnected,
    bool? isDeviceAwake,
    Map<String, dynamic>? lastEvent,
  }) {
    return CameraControlState(
      isConnected: isConnected ?? this.isConnected,
      isDeviceAwake: isDeviceAwake ?? this.isDeviceAwake,
      lastEvent: lastEvent ?? this.lastEvent,
    );
  }

  @override
  List<Object> get props => [isConnected, isDeviceAwake, lastEvent];
}

class CameraControlInitial extends CameraControlState {
  const CameraControlInitial()
      : super(
          isConnected: false,
          isDeviceAwake: false,
          lastEvent: const {'event': 'Initializing...'},
        );
}

class CameraControlError extends CameraControlState {
  final String message;
  const CameraControlError(this.message);
  @override
  List<Object> get props => [message];
}
