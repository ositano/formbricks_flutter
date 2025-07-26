import 'package:flutter/material.dart';

class SurveyProgress extends StatelessWidget {
  final double progress;
  final int? inactivitySecs;

  const SurveyProgress({
    super.key,
    required this.progress,
    this.inactivitySecs,
  });

  @override
  Widget build(BuildContext context) {
    return inactivitySecs != null
        ? TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: progress, end: 0.0),
            duration: Duration(seconds: inactivitySecs!),
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
                minHeight: 5,
              );
            },
          )
        : LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
            minHeight: 5,
          );
  }
}
