import 'package:equatable/equatable.dart';

class VoiceMotivator extends Equatable {
  final String voiceId;
  final String name;
  final String filePath;
  final bool isDefault;
  final String? userId;
  final DateTime lastModifiedAt;

  const VoiceMotivator({
    required this.voiceId,
    required this.name,
    required this.filePath,
    required this.isDefault,
    this.userId,
    required this.lastModifiedAt,
  });

  @override
  List<Object?> get props =>
      [voiceId, name, filePath, isDefault, userId, lastModifiedAt];
}
