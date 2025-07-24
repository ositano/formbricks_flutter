import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../formbricks_flutter.dart';
import '../../../models/environment/question.dart';
import '../../../utils/helper.dart';
import '../components/formbricks_video_player.dart';

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

  Widget _buildField({
    required bool show,
    required bool required,
    required String label,
    required TextEditingController controller,
    required void Function() revalidate,
    required TextInputType? keyboardType
  }) {
    if (!show) return const SizedBox.shrink();
    return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              required ? '$label *' : label,
            ),
            SizedBox(height: 4.0,),
            TextFormField(
              controller: controller,
              onChanged: (_) {
                _updateResponse();
                revalidate();
              },
              textInputAction: TextInputAction.next,
              keyboardType: keyboardType ?? TextInputType.text,
            ),
          ],
        )
    );
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

    final firstName = question.firstName ?? {};
    final lastName = question.lastName ?? {};
    final email = question.email ?? {};
    final phone = question.phone ?? {};
    final company = question.company ?? {};

    return FormField<bool>(
      validator: (_) {
        if(widget.requiredAnswerByLogicCondition) {
          return AppLocalizations.of(context)!.response_required;
        }

        if (!(question.required ?? false)) return null;

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
            if (widget.question.imageUrl?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: GestureDetector(child: ClipRRect(
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
                            child: CircularProgressIndicator())),
                    errorWidget: (context, url, error) =>
                    const Icon(Icons.error),
                  ),
                ),
                  onTap: () => showFullScreenImage(context, widget.question.imageUrl!),
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
            if (translate(question.subheader, context)?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  translate(question.subheader, context) ?? '',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 16),

            _buildField(
              show: firstName['show'] ?? false,
              required: firstName['required'] ?? false,
              label: translate(firstName['placeholder'], context) ?? AppLocalizations.of(context)!.first_name,
              controller: _firstNameController,
              revalidate: () => field.didChange,
              keyboardType: TextInputType.text
            ),
            _buildField(
              show: lastName['show'] ?? false,
              required: lastName['required'] ?? false,
              label: translate(lastName['placeholder'], context) ?? AppLocalizations.of(context)!.last_name,
              controller: _lastNameController,
              revalidate: () =>  field.didChange,
                keyboardType: TextInputType.text
            ),
            _buildField(
              show: email['show'] ?? false,
              required: email['required'] ?? false,
              label: translate(email['placeholder'], context) ?? AppLocalizations.of(context)!.email,
              controller: _emailController,
              revalidate: () => field.didChange,
                keyboardType: TextInputType.emailAddress
            ),
            _buildField(
              show: phone['show'] ?? false,
              required: phone['required'] ?? false,
              label: translate(phone['placeholder'], context) ?? AppLocalizations.of(context)!.phone,
              controller: _phoneController,
              revalidate: () => field.didChange,
                keyboardType: TextInputType.phone
            ),
            _buildField(
              show: company['show'] ?? false,
              required: company['required'] ?? false,
              label: translate(company['placeholder'], context) ?? AppLocalizations.of(context)!.company,
              controller: _companyController,
              revalidate: () => field.didChange,
                keyboardType: TextInputType.text
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
