import 'package:flutter/material.dart';

import '../../models/question.dart';

class AddressQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;

  const AddressQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
  });

  @override
  State<AddressQuestion> createState() => _AddressQuestionState();
}

class _AddressQuestionState extends State<AddressQuestion> {
  late var _streetController = TextEditingController();
  late var _cityController = TextEditingController();
  late var _stateController = TextEditingController();
  late var _zipController = TextEditingController();
  late var _countryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    final response = widget.response as Map<String, dynamic>? ?? {};
    _streetController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _countryController = TextEditingController();
    _zipController = TextEditingController();
    _isInitialized = true;
    _updateControllerText(response);
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

  @override
  void didUpdateWidget(covariant AddressQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.response != oldWidget.response) {
      final response = widget.response as Map<String, dynamic>? ?? {};
      _updateControllerText(response);
    }
  }

  void _updateControllerText(Map<String, dynamic> response) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _streetController.text = response['street']?.toString() ?? '';
      _cityController.text = response['city']?.toString() ?? '';
      _stateController.text = response['state']?.toString() ?? '';
      _countryController.text = response['country']?.toString() ?? '';
      _zipController.text = response['zip']?.toString() ?? '';
    });
  }

  void _updateResponse() {
    if (_isInitialized) {
      final response = {
        'street': _streetController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'zip': _zipController.text,
        'country': _countryController.text,
      };
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onResponse(widget.question.id, response);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRequired = widget.question.required ?? false;

    return FormField<bool>(
      key: _formKey,
      validator: (value) {
        if (isRequired &&
            (_streetController.text.isEmpty ||
                _cityController.text.isEmpty ||
                _stateController.text.isEmpty ||
                _countryController.text.isEmpty ||
                _zipController.text.isEmpty)) {
          return 'All fields are required';
        }
        return null;
      },
      builder: (FormFieldState<bool> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.question.headline['default'] ?? '',
              style: theme.textTheme.headlineMedium ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (widget.question.subheader?['default']?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  widget.question.subheader?['default'] ?? '',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _streetController,
              decoration: InputDecoration(
                labelText: 'Street',
                border: OutlineInputBorder(),
                labelStyle: theme.textTheme.bodyMedium,
                errorText: field.hasError ? field.errorText : null,
              ),
              onChanged: (value) => _updateResponse(),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(),
                labelStyle: theme.textTheme.bodyMedium,
                errorText: field.hasError ? field.errorText : null,
              ),
              onChanged: (value) => _updateResponse(),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _stateController,
              decoration: InputDecoration(
                labelText: 'State',
                border: OutlineInputBorder(),
                labelStyle: theme.textTheme.bodyMedium,
                errorText: field.hasError ? field.errorText : null,
              ),
              onChanged: (value) => _updateResponse(),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _zipController,
              decoration: InputDecoration(
                labelText: 'ZIP Code',
                border: OutlineInputBorder(),
                labelStyle: theme.textTheme.bodyMedium,
                errorText: field.hasError ? field.errorText : null,
              ),
              onChanged: (value) => _updateResponse(),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _countryController,
              decoration: InputDecoration(
                labelText: 'Country',
                border: OutlineInputBorder(),
                labelStyle: theme.textTheme.bodyMedium,
                errorText: field.hasError ? field.errorText : null,
              ),
              onChanged: (value) => _updateResponse(),
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