

import 'package:flutter/material.dart';

import '../../../../formbricks_flutter.dart';

class SurveyCopyright extends StatelessWidget{
  const SurveyCopyright({super.key});


  @override
  Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 10.0),
      child: Text.rich(
        textAlign: TextAlign.center,
        TextSpan(
          text: AppLocalizations.of(context)!.powered_by,
          style: Theme.of(context).textTheme.bodySmall,
          children: [
            TextSpan(
              text: 'Formbricks',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}