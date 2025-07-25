
import 'package:flutter/material.dart';
import '../../../../formbricks_flutter.dart';
import '../../../utils/helper.dart';
import '../components/custom_heading.dart';
import '../components/custom_text_field.dart';

class ContactInfoQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;
  final bool requiredAnswerByLogicCondition;

  const ContactInfoQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
    required this.requiredAnswerByLogicCondition
  });

  @override
  State<ContactInfoQuestion> createState() => _ContactInfoQuestionState();
}

class _ContactInfoQuestionState extends State<ContactInfoQuestion> {
  late final _firstNameController = TextEditingController();
  late final _lastNameController = TextEditingController();
  late final _emailController = TextEditingController();
  late final _phoneController = TextEditingController();
  late final _companyController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _populateFields(widget.response as Map<String, dynamic>? ?? {});
  }

  @override
  void didUpdateWidget(covariant ContactInfoQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.response != oldWidget.response) {
      _populateFields(widget.response as Map<String, dynamic>? ?? {});
    }
  }

  void _populateFields(Map<String, dynamic> response) {
    _firstNameController.text = response['firstName'] ?? '';
    _lastNameController.text = response['lastName'] ?? '';
    _emailController.text = response['email'] ?? '';
    _phoneController.text = response['phone'] ?? '';
    _companyController.text = response['company'] ?? '';
  }

  void _updateResponse() {
    final data = {
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'company': _companyController.text,
    };
    widget.onResponse(widget.question.id, data);
  }


  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final question = widget.question;
    bool isRequired = question.required ?? false;
    if(widget.requiredAnswerByLogicCondition){
      isRequired = widget.requiredAnswerByLogicCondition;
    }

    final firstName = question.firstName ?? {};
    final lastName = question.lastName ?? {};
    final email = question.email ?? {};
    final phone = question.phone ?? {};
    final company = question.company ?? {};

    return FormField<bool>(
      key: ValueKey(widget.question.id),
      validator: (_) {
        if (!isRequired) return null;

        if (firstName['show'] == true &&
            firstName['required'] == true &&
            _firstNameController.text.trim().isEmpty) {
          return AppLocalizations.of(context)!.first_name_required;
        }
        if (lastName['show'] == true &&
            lastName['required'] == true &&
            _lastNameController.text.trim().isEmpty) {
          return AppLocalizations.of(context)!.last_name_required;
        }
        if (email['show'] == true &&
            email['required'] == true &&
            _emailController.text.trim().isEmpty) {
          return AppLocalizations.of(context)!.email_required;
        }
        if(_emailController.text.isNotEmpty) {
          final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegex.hasMatch(_emailController.text)) {
            return AppLocalizations.of(context)!.please_enter_valid_email;
          }
        }
        if (phone['show'] == true &&
            phone['required'] == true &&
            _phoneController.text.trim().isEmpty) {
          return AppLocalizations.of(context)!.phone_is_required;
        }
        if (company['show'] == true &&
            company['required'] == true &&
            _companyController.text.trim().isEmpty) {
          return AppLocalizations.of(context)!.company_required;
        }

        return null;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomHeading(question: widget.question, required: isRequired),
            CustomTextField(
              show: firstName['show'] ?? false,
              required: firstName['required'] ?? false,
              label: translate(firstName['placeholder'], context) ?? AppLocalizations.of(context)!.first_name,
              controller: _firstNameController,
              revalidate: () => field.didChange,
              keyboardType: TextInputType.text,
              updateResponse: () => _updateResponse(),
            ),
            CustomTextField(
              show: lastName['show'] ?? false,
              required: lastName['required'] ?? false,
              label: translate(lastName['placeholder'], context) ?? AppLocalizations.of(context)!.last_name,
              controller: _lastNameController,
              revalidate: () =>  field.didChange,
              keyboardType: TextInputType.text,
              updateResponse: () => _updateResponse(),
            ),
            CustomTextField(
              show: email['show'] ?? false,
              required: email['required'] ?? false,
              label: translate(email['placeholder'], context) ?? AppLocalizations.of(context)!.email,
              controller: _emailController,
              revalidate: () => field.didChange,
              keyboardType: TextInputType.emailAddress,
              updateResponse: () => _updateResponse(),
            ),
            CustomTextField(
              show: phone['show'] ?? false,
              required: phone['required'] ?? false,
              label: translate(phone['placeholder'], context) ?? AppLocalizations.of(context)!.phone,
              controller: _phoneController,
              revalidate: () => field.didChange,
              keyboardType: TextInputType.phone,
              updateResponse: () => _updateResponse(),
            ),
            CustomTextField(
              show: company['show'] ?? false,
              required: company['required'] ?? false,
              label: translate(company['placeholder'], context) ?? AppLocalizations.of(context)!.company,
              controller: _companyController,
              revalidate: () => field.didChange,
              keyboardType: TextInputType.text,
              updateResponse: () => _updateResponse(),
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
