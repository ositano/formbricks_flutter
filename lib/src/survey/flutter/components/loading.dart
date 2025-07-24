import 'package:flutter/material.dart';

class SurveyLoading extends StatelessWidget {
  final double? width;
  final double? height;
  const SurveyLoading({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    final containerWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: width ?? containerWidth,
      width: height ?? screenHeight,
      child: Center(
        child: SizedBox(
          width: 50,
          height: 50,
          child: const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
