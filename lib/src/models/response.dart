/// Defines the response model for survey submissions.
class SurveyResponse {
  final String surveyId;
  final String userId;
  final Map<String, dynamic> data;
  final bool finished;

  SurveyResponse({
    required this.surveyId,
    required this.userId,
    required this.data,
    this.finished = true,
  });

  Map<String, dynamic> toJson() => {
    'surveyId': surveyId,
    'userId': userId,
    'data': data,
    'finished': finished,
  };
}