import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../formbricks_flutter.dart';
import '../../../models/environment/question.dart';
import '../../../utils/helper.dart';
import '../components/formbricks_video_player.dart';

class CTAQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;
  final bool requiredAnswerByLogicCondition;

  const CTAQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
    required this.requiredAnswerByLogicCondition,
  });

  @override
  State<CTAQuestion> createState() => _CTAQuestionState();
}

class _CTAQuestionState extends State<CTAQuestion> {
  bool performedAction = false;

  @override
  void initState() {
    super.initState();
    performedAction = (widget.response as String?) == "clicked" ? true : false;
  }

  Future<void> _openLink() async {
    final url = widget.question.buttonUrl!;
    if (await canLaunch(url)) {
      await launch(url);
      setState(() {
        performedAction = true;
        widget.onResponse(widget.question.id, performedAction ? "clicked" : "dismissed");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRequired = widget.question.required ?? false;

    return FormField<bool>(
      validator: (value) => widget.requiredAnswerByLogicCondition
          ? AppLocalizations.of(context)!.response_required
          : (isRequired && value != true
                ? AppLocalizations.of(context)!.please_take_action
                : null),
      builder: (FormFieldState<bool> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.question.imageUrl?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: GestureDetector(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: CachedNetworkImage(
                      imageUrl: widget.question.imageUrl!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                  onTap: () =>
                      showFullScreenImage(context, widget.question.imageUrl!),
                ),
              )
            else if (widget.question.videoUrl?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    theme.extension<MyCustomTheme>()!.styleRoundness!,
                  ),
                  child: FormbricksVideoPlayer(videoUrl: widget.question.videoUrl!,),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(
                  translate(widget.question.headline, context) ?? '',
                  style: theme.textTheme.headlineMedium ??
                      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ),
                widget.question.required == true || widget.requiredAnswerByLogicCondition == true ? const SizedBox.shrink() :
                Text(
                  AppLocalizations.of(context)!.optional,
                  textAlign: TextAlign.end,
                  style: theme.textTheme.headlineSmall ??
                      const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                ),
              ],
            ),
            if (translate(widget.question.html, context)?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: HtmlWidget(
                  translate(widget.question.html, context) ?? '',
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _openLink();
                    field.didChange(true); // Validate
                  },
                  child: Text(
                    translate(widget.question.buttonLabel, context) ??
                        AppLocalizations.of(context)!.action,
                  ),
                ),
                if (widget.question.dismissButtonLabel?['default'] != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        performedAction = true;
                        widget.onResponse(widget.question.id, performedAction ? "clicked" : "dismissed");
                      });
                      field.didChange(true);
                      //Navigator.of(context).pop(); // Skip and close
                    },
                    child: Text(
                      translate(widget.question.dismissButtonLabel, context) ??
                          AppLocalizations.of(context)!.skip,
                    ),
                  ),
              ],
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  field.errorText!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
          ],
        );
      },
    );
  }
}
