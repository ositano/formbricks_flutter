
class UserBody {
  final String userId;
  final Map<String, dynamic>? attributes;

  UserBody({
    required this.userId,
    this.attributes
  });

  factory UserBody.fromJson(Map<String, dynamic> json) {
    return UserBody(
      userId: json['userId'],
      attributes: json['attributes'],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'userId': userId,
      'attributes': attributes,
    };
  }
}