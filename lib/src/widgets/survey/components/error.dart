

import 'package:flutter/material.dart';

class SurveyError extends StatelessWidget{

  final double? width;
  final double? height;
  final String errorMessage;
  const SurveyError({super.key, required this.errorMessage, this.width, this.height});


  @override
  Widget build(BuildContext context){
    final containerWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: width ?? containerWidth,
      width: height ?? screenHeight,
      child: Center(child: Text('Error: $errorMessage')),
    );
  }
}