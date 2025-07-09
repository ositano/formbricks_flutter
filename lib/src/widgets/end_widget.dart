import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../formbricks_flutter.dart';
import '../utils/helper.dart';

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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          translate(ending?['headline'], context) ?? "",
          style:
          theme.textTheme.headlineMedium ??
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (translate(ending?['subheader'], context)?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              translate(ending?['subheader'], context) ?? '',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}