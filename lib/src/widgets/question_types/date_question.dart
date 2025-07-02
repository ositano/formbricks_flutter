import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/question.dart';

/// Date picker input
class DateQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;

  const DateQuestion({
    super.key,
    required this.question,
    required this.onResponse,
  });

  @override
  State<DateQuestion> createState() => _DateQuestionState();
}

class _DateQuestionState extends State<DateQuestion> {
  DateTime? selectedDate;

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        widget.onResponse(widget.question.id, DateFormat('yyyy-MM-dd').format(picked));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.question.headline, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        if (widget.question.subheader.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(widget.question.subheader),
          ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _pickDate(context),
          child: Text(selectedDate == null
              ? 'Select Date'
              : DateFormat('yyyy-MM-dd').format(selectedDate!)),
        ),
      ],
    );
  }
}