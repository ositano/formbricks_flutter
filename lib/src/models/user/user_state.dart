import 'user_state_data.dart';

class UserState {
  final UserStateData data;
  String? expiresAt;

  UserState({
    required this.data,
    this.expiresAt,
  });

  factory UserState.fromJson(Map<String, dynamic> json) {
    return UserState(
      data: UserStateData.fromJson(json['data']),
      expiresAt: json['expiresAt'],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'data': data.toJson(),
      'expiresAt': expiresAt,
    };
  }
}