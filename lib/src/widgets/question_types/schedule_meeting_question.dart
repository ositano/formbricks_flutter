import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/question.dart';

/// Calendar/time slot selection (e.g., Calendly integration)
class ScheduleMeetingQuestion extends StatelessWidget {
  final Question question;
  final Function(String, dynamic) onResponse;

  const ScheduleMeetingQuestion({
    super.key,
    required this.question,
    required this.onResponse,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final calendarUrl = question.inputConfig?['calendarUrl'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question.headline, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        if (question.subheader.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(question.subheader),
          ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            if (await canLaunchUrl(Uri.parse(calendarUrl))) {
              await launchUrl(Uri.parse(calendarUrl));
              onResponse(question.id, true);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not open calendar')),
              );
            }
          },
          child: const Text('Schedule Meeting'),
        ),
      ],
    );
  }
}