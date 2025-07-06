

import 'package:flutter/material.dart';

class SurveyProgress extends StatelessWidget{
  final double progress;

  const SurveyProgress({super.key, required this.progress});

  @override
  Widget build(BuildContext context){
    return LinearProgressIndicator(
      value: progress,
      backgroundColor: Colors.grey[300],
      valueColor: AlwaysStoppedAnimation<Color>(
        Theme.of(context).primaryColor,
      ),
      minHeight: 5,
    );
  }
}