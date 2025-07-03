import 'package:flutter/material.dart';

import '../../models/question.dart';

/// Fields for name, email, phone, etc.
class ContactInfoQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;

  const ContactInfoQuestion({
    super.key,
    required this.question,
    required this.onResponse,
  });


  @override
  State<ContactInfoQuestion> createState() => _ContactInfoQuestionState();
}

class _ContactInfoQuestionState extends State<ContactInfoQuestion> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

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
          controller: _nameController,
          decoration: InputDecoration(labelText: 'Name', border: OutlineInputBorder(), labelStyle: theme.textTheme.bodyMedium),
          onChanged: (value) => _updateResponse(),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder(), labelStyle: theme.textTheme.bodyMedium),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) => _updateResponse(),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(labelText: 'Phone', border: OutlineInputBorder(), labelStyle: theme.textTheme.bodyMedium),
          keyboardType: TextInputType.phone,
          onChanged: (value) => _updateResponse(),
        ),
      ],
    );
  }

  void _updateResponse() {
    widget.onResponse(widget.question.id, {
      'name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}