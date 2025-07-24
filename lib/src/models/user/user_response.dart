import 'user_response_data.dart';

class UserResponse {
  final UserResponseData data;

  UserResponse({
    required this.data
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      data: UserResponseData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'data': data.toJson(),
    };
  }
}