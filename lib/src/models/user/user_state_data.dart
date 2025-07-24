

import 'user_display.dart';

class UserStateData {
  String? userId;
  String? contactId;
  String? lastDisplayAt;
  String? language;
  final List<String>? segments;
  final List<UserDisplay>? displays;
  final List<String>? responses;

  UserStateData({
    this.userId,
    this.contactId,
    this.lastDisplayAt,
    this.language,
    this.segments,
    this.displays,
    this.responses,
  });

  factory UserStateData.fromJson(Map<String, dynamic> json) {
    return UserStateData(
      userId: json['userId'],
      contactId: json['contactId'],
      lastDisplayAt: json['lastDisplayAt'],
      language: json['language'],
      segments: json['segments'] != null
          ? (json['segments'] as List).map((q) => q.toString()).toList()
          : [],
      displays: json['displays'] != null
          ? (json['displays'] as List).map((q) => UserDisplay.fromJson(q)).toList()
          : [],
      responses: json['responses'] != null
          ? (json['responses'] as List).map((q) => q.toString()).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'userId': userId,
      'contactId': contactId,
      'lastDisplayAt': lastDisplayAt,
      'language': language,
      'segments': segments,
      'displays': displays,
      'responses': responses
    };
  }
}