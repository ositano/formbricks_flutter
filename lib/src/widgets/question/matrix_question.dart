import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math';

import '../../../l10n/app_localizations.dart';
import '../../models/question.dart';
import '../../utils/helper.dart';

class MatrixQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;
  final bool requiredAnswerByLogicCondition;

  const MatrixQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
    required this.requiredAnswerByLogicCondition
  });

  @override
  State<MatrixQuestion> createState() => _MatrixQuestionState();
}

class _MatrixQuestionState extends State<MatrixQuestion> {
  late Map<String, String> selections;
  late List<Map<String, String>> shuffledRows;
  final Random _random = Random();
  String? _questionId;

  @override
  void initState() {
    super.initState();
    _questionId = widget.question.id;
    shuffledRows = _shuffleRows(widget.question.rows ?? []);
    _updateSelections();
  }

  @override
  void didUpdateWidget(covariant MatrixQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.question.id != _questionId) {
      shuffledRows = _shuffleRows(widget.question.rows ?? []);
      _updateSelections();
      _questionId = widget.question.id;
    } else if (widget.response != oldWidget.response) {
      _updateSelections(); // just update selections, no reshuffle
    }
  }


  void _updateSelections() {
    final responseMap = widget.response is Map<String, dynamic> ? widget.response as Map<String, dynamic> : {};
    final questionResponse = responseMap[widget.question.id];
    selections = questionResponse is Map<String, String>
        ? Map<String, String>.from(questionResponse)
        : {};
  }

  List<Map<String, String>> _shuffleRows(List<Map<String, String>> rows) {
    final shuffleOption = widget.question.shuffleOption ?? 'none';
    if (shuffleOption == 'none' || rows.isEmpty) return List<Map<String, String>>.from(rows);

    final List<Map<String, String>> localRows = List<Map<String, String>>.from(rows);

    if (shuffleOption == 'all') {
      localRows.shuffle(_random);
    } else if (shuffleOption == 'exceptLast' && localRows.length > 1) {
      final last = localRows.removeLast();
      localRows.shuffle(_random);
      localRows.add(last);
    }

    return localRows;
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final columns = widget.question.columns ?? [];
    final isRequired = widget.question.required ?? false;

    return FormField<bool>(
      key: ValueKey(widget.question.id),
      validator: (_) {
        if(widget.requiredAnswerByLogicCondition) {
          return AppLocalizations.of(context)!.response_required;
        }

        if (isRequired && selections.length != shuffledRows.length) {
          return AppLocalizations.of(context)!.please_rate_all;
        }
        return null;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              //widget.question.headline['default'] ?? '',
              translate(widget.question.headline, context) ?? '',
              style: theme.textTheme.headlineMedium ??
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            //if (widget.question.subheader?['default']?.isNotEmpty ?? false)
            if (translate(widget.question.subheader, context)?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  //widget.question.subheader!['default']!,
                  translate(widget.question.subheader, context) ?? "",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 16),
            Table(
              border: TableBorder.all(color: Colors.grey[300]!, style: BorderStyle.none),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: {
                0: const FlexColumnWidth(2), // Row labels wider
              },
              children: [
                TableRow(
                  children: [
                    const SizedBox.shrink(),
                    ...columns.map(
                          (col) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            //col['default'] ?? '',
                            translate(col, context) ?? '',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ...shuffledRows.asMap().entries.map((entry) {
                  final index = entry.key;
                  final row = entry.value;
                  final rowLabel = translate(row, context) ?? '';

                  final bgColor = index.isEven ? theme.inputDecorationTheme.fillColor: Colors.transparent;
                  return TableRow(
                    key: ValueKey(rowLabel),
                    decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          rowLabel,
                          style: theme.textTheme.headlineMedium?.copyWith(fontSize: 14),
                        ),
                      ),
                      ...columns.map((col) {
                        final colValue = translate(col, context) ?? '';
                        return Center(
                          child: Radio<String>(
                            value: colValue,
                            groupValue: selections[rowLabel],
                            fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                              if (states.contains(MaterialState.selected)) {
                                return theme.primaryColor; // Selected = primary color
                              }
                              return theme.primaryColor; // Unselected = white fill
                            }),
                            overlayColor: WidgetStateProperty.all(Colors.white), // Optional: removes ripple effect
                            onChanged: (value) {
                              setState(() {
                                selections[rowLabel] = value!;
                                final updatedResponse = {
                                  widget.question.id: Map<String, String>.from(selections),
                                };
                                widget.onResponse(widget.question.id, updatedResponse);
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  field.didChange(true);
                                });
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  );
                }),


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
