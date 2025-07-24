import 'dart:convert';
import 'environment_response_data.dart';

class EnvironmentDataHolder {
  final EnvironmentResponseData? data;
  final Map<String, dynamic> originalResponseMap;

  EnvironmentDataHolder({
    required this.data,
    required this.originalResponseMap,
  });

  factory EnvironmentDataHolder.fromJson(Map<String, dynamic> json) {
    return EnvironmentDataHolder(
      data: EnvironmentResponseData.fromJson(json['data']),
      originalResponseMap: json['originalResponseMap'],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'data': data?.toJson(),
      'originalResponseMap': originalResponseMap
    };
  }

  dynamic getSurveyJson(String surveyId) {
    try {
      final responseMap = originalResponseMap['data'] as Map<String, dynamic>?;
      final dataMap = responseMap?['data'] as Map<String, dynamic>?;
      final surveyArray = dataMap?['surveys'] as List<dynamic>?;

      final firstSurvey = surveyArray?.firstWhere(
            (survey) => survey['id'] == surveyId,
        orElse: () => null,
      );

      return firstSurvey != null ? jsonDecode(jsonEncode(firstSurvey)) : null;
    } catch (e) {
      return null;
    }
  }

  dynamic getStyling(String surveyId) {
    try {
      final responseMap = originalResponseMap['data'] as Map<String, dynamic>?;
      final dataMap = responseMap?['data'] as Map<String, dynamic>?;
      final surveyArray = dataMap?['surveys'] as List<dynamic>?;

      final firstSurvey = surveyArray?.firstWhere(
            (survey) => survey['id'] == surveyId,
        orElse: () => null,
      );

      final styling = firstSurvey?['styling'];
      return styling != null ? jsonDecode(jsonEncode(styling)) : null;
    } catch (e) {
      return null;
    }
  }

  dynamic getProjectStylingJson() {
    try {
      final responseMap = originalResponseMap['data'] as Map<String, dynamic>?;
      final dataMap = responseMap?['data'] as Map<String, dynamic>?;
      final projectMap = dataMap?['project'] as Map<String, dynamic>?;
      final stylingMap = projectMap?['styling'];

      return stylingMap != null ? jsonDecode(jsonEncode(stylingMap)) : null;
    } catch (e) {
      return null;
    }
  }
}
