

import 'package:flutter/material.dart';
import '../../../../formbricks_flutter.dart';


class SurveyButtons extends StatelessWidget{
  final int currentStep;
  final String? nextLabel;
  final String? previousLabel;
  final Survey survey;
  final Function() previousStep;
  final Function() nextStep;

  const SurveyButtons({super.key,
    required this.currentStep,
    required this.nextStep,
    required this.previousStep,
    required this.nextLabel,
    required this.previousLabel,
    required this.survey,
  });


  @override
  Widget build(BuildContext context){
    print("current step: $currentStep");
    print("total: ${survey.questions.length}");
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: currentStep == survey.questions.length + 1 ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          if (currentStep > 1 && survey.isBackButtonHidden == false)
            OutlinedButton(
              onPressed: previousStep,
              child: Text(previousLabel ?? AppLocalizations.of(context)!.back),
            ),
          if (nextLabel != null)
            if (currentStep == 0 ||
                (currentStep > 0 &&
                    !['rating', 'nps'].contains(
                      survey.questions
                          .elementAtOrNull(currentStep - 1)
                          ?.type,
                    )))
              ElevatedButton(
                onPressed:
                currentStep == survey.questions.length + 1
                    ? () => Navigator.of(context).pop()
                    : nextStep,
                child: Text(nextLabel ?? AppLocalizations.of(context)!.next),
              ),
        ],
      ),
    );
  }
}