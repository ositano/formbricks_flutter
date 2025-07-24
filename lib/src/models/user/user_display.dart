class UserDisplay {
  final String surveyId;
  final String createdAt;

  UserDisplay({
    required this.surveyId,
    required this.createdAt,
  });

  factory UserDisplay.fromJson(Map<String, dynamic> json) {
    return UserDisplay(
      surveyId: json['surveyId'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'surveyId': surveyId,
      'createdAt': createdAt,
    };
  }

  @override
  String toString(){
    return "{surveyId: $surveyId, createdAt: $createdAt}";
  }
}