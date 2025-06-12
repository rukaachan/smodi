import 'package:equatable/equatable.dart';

abstract class CameraControlEvent extends Equatable {
  const CameraControlEvent();
  @override
  List<Object> get props => [];
}

class ConnectToSocketServer extends CameraControlEvent {
  final String serverUrl;
  const ConnectToSocketServer(this.serverUrl);
}

class SendCommandToDevice extends CameraControlEvent {
  final String command; // e.g., 'WAKE', 'SLEEP'
  const SendCommandToDevice(this.command);
}

class DisconnectFromSocketServer extends CameraControlEvent {}

class DeviceEventReceived extends CameraControlEvent {
  final Map<String, dynamic> eventData;
  const DeviceEventReceived(this.eventData);
}
