import 'user_state.dart';

class UserResponseData {
  final UserState state;

  UserResponseData({
    required this.state
  });

  factory UserResponseData.fromJson(Map<String, dynamic> json) {
    return UserResponseData(
      state: UserState.fromJson(json['state']),
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'state': state.toJson(),
    };
  }
}