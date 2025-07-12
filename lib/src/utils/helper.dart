import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:formbricks_flutter/src/utils/extensions.dart';

import '../models/question.dart';

/// Signature definition for question widget builders.
/// - [key] is the unique widget key.
/// - [question] is the question model to render.
/// - [onResponse] is the callback function to handle the user response.
/// - [response] is the current response value, if any.
/// - [requiredAnswerByLogicCondition] indicates whether the answer is required due to logic conditions.
typedef QuestionWidgetBuilder = Widget Function(
    Key? key,
    Question question,
    Function(String, dynamic) onResponse,
    dynamic response,
    bool requiredAnswerByLogicCondition,
    );

/// Helper function to translate a map of localized strings
/// based on the current context's locale.
/// Returns the localized string or `null` if not found.
String? translate(Map<String, dynamic>? map, BuildContext context) {
  return (map)?.tr(context);
}

/// Opens a full-screen modal to show a zoomed-in version of an image from the given [imageUrl].
/// 
/// Uses [CachedNetworkImage] for efficient loading, with loading and error states handled.
void showFullScreenImage(BuildContext context, String imageUrl) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Centered image display
            Center(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                const Center(child: Icon(Icons.error)),
              ),
            ),
            // Back button positioned at the top-left
            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
