import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class CloseWidget extends StatelessWidget {
  final VoidCallback? onComplete;

  const CloseWidget({
    super.key,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Colors.green,
            ),
          ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: ElevatedButton(
            onPressed: () {
              onComplete
                  ?.call(); // notify TriggerManager to show next
              Navigator.of(context).maybePop();
            },
            child: Text(
              AppLocalizations.of(context)!.close,
            ),
          ),
        )
      ],
    );
  }
}
