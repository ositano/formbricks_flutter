import 'package:flutter/material.dart';
import '../../formbricks_flutter.dart';

class EndWidget extends StatelessWidget {
  final Survey survey;

  const EndWidget({
    super.key,
    required this.survey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ending = survey.endings?.firstWhere(
          (e) => e['type'] == 'endScreen',
      orElse: () => survey.endings!.first,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          ending?['headline']['default'] ?? "",
          style:
          theme.textTheme.headlineMedium ??
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (ending?['subheader']['default']?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              ending?['subheader']['default'] ?? '',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}