import 'dart:convert';

class LocalSession {
  final String userId;
  final String email;
  final String refreshToken;

  const LocalSession({
    required this.userId,
    required this.email,
    required this.refreshToken,
  });

  factory LocalSession.fromRawJson(String str) =>
      LocalSession.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LocalSession.fromJson(Map<String, dynamic> json) => LocalSession(
        userId: json["user_id"],
        email: json["email"],
        refreshToken: json["refresh_token"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "email": email,
        "refresh_token": refreshToken,
      };
}
