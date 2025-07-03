import 'package:flutter/material.dart';

import '../../models/question.dart';

/// Structured address input (street, city, etc.)
class AddressQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;

  const AddressQuestion({
    super.key,
    required this.question,
    required this.onResponse,
  });

  @override
  State<AddressQuestion> createState() => _AddressQuestionState();
}

class _AddressQuestionState extends State<AddressQuestion> {
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _countryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.question.headline['default'] ?? '', style: theme.textTheme.headlineMedium ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        if (widget.question.subheader['default']?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(widget.question.subheader['default'] ?? '', style: theme.textTheme.bodyMedium,),
          ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _streetController,
          decoration: InputDecoration(labelText: 'Street', border: OutlineInputBorder(), labelStyle: theme.textTheme.bodyMedium),
          onChanged: (value) => _updateResponse(),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _cityController,
          decoration: InputDecoration(labelText: 'City', border: OutlineInputBorder(), labelStyle: theme.textTheme.bodyMedium),
          onChanged: (value) => _updateResponse(),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _stateController,
          decoration: InputDecoration(labelText: 'State', border: OutlineInputBorder(), labelStyle: theme.textTheme.bodyMedium),
          onChanged: (value) => _updateResponse(),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _zipController,
          decoration: InputDecoration(labelText: 'ZIP Code', border: OutlineInputBorder(), labelStyle: theme.textTheme.bodyMedium),
          onChanged: (value) => _updateResponse(),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _countryController,
          decoration: InputDecoration(labelText: 'Country', border: OutlineInputBorder(), labelStyle: theme.textTheme.bodyMedium),
          onChanged: (value) => _updateResponse(),
        ),
      ],
    );
  }

  void _updateResponse() {
    widget.onResponse(widget.question.id, {
      'street': _streetController.text,
      'city': _cityController.text,
      'state': _stateController.text,
      'zip': _zipController.text,
      'country': _countryController.text,
    });
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    super.dispose();
  }
}