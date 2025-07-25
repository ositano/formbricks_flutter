import 'package:flutter/material.dart';
import '../../../../formbricks_flutter.dart';
import '../../../utils/helper.dart';
import '../components/custom_heading.dart';
import '../components/custom_text_field.dart';

class AddressQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;
  final bool requiredAnswerByLogicCondition;

  const AddressQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
    required this.requiredAnswerByLogicCondition
  });

  @override
  State<AddressQuestion> createState() => _AddressQuestionState();
}

class _AddressQuestionState extends State<AddressQuestion> {
  late final _addressLine1Controller = TextEditingController();
  late final _addressLine2Controller = TextEditingController();
  late final _cityController = TextEditingController();
  late final _stateController = TextEditingController();
  late final _zipController = TextEditingController();
  late final _countryController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _populateFields(widget.response as Map<String, dynamic>? ?? {});
  }

  @override
  void didUpdateWidget(covariant AddressQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.response != oldWidget.response) {
      _populateFields(widget.response as Map<String, dynamic>? ?? {});
    }
  }

  void _populateFields(Map<String, dynamic> response) {
    _addressLine1Controller.text = response['addressLine1'] ?? '';
    _addressLine2Controller.text = response['addressLine2'] ?? '';
    _cityController.text = response['city'] ?? '';
    _stateController.text = response['state'] ?? '';
    _zipController.text = response['zipCode'] ?? '';
    _countryController.text = response['country'] ?? '';
  }

  void _updateResponse() {
    final data = {
      'addressLine1': _addressLine1Controller.text,
      'addressLine2': _addressLine2Controller.text,
      'city': _cityController.text,
      'state': _stateController.text,
      'zipCode': _zipController.text,
      'country': _countryController.text,
    };
    widget.onResponse(widget.question.id, data);
  }

  @override
  void dispose() {
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
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

    final addressLine1 = question.addressLine1 ?? {};
    final addressLine2 = question.addressLine2 ?? {};
    final city = question.city ?? {};
    final state = question.state ?? {};
    final zip = question.zip ?? {};
    final country = question.country ?? {};

    return FormField<bool>(
      key: ValueKey(question.id),
      validator: (_) {
        if (!(isRequired)) return null;

        if (addressLine1['show'] == true &&
            addressLine1['required'] == true &&
            _addressLine1Controller.text.trim().isEmpty) {
          return AppLocalizations.of(context)!.address1_required;
        }
        if (addressLine2['show'] == true &&
            addressLine2['required'] == true &&
            _addressLine2Controller.text.trim().isEmpty) {
          return AppLocalizations.of(context)!.address2_required;
        }
        if (city['show'] == true &&
            city['required'] == true &&
            _cityController.text.trim().isEmpty) {
          return AppLocalizations.of(context)!.city_required;
        }
        if (state['show'] == true &&
            state['required'] == true &&
            _stateController.text.trim().isEmpty) {
          return AppLocalizations.of(context)!.state_required;
        }
        if (zip['show'] == true &&
            zip['required'] == true &&
            _zipController.text.trim().isEmpty) {
          return AppLocalizations.of(context)!.zip_required;
        }
        if (country['show'] == true &&
            country['required'] == true &&
            _countryController.text.trim().isEmpty) {
          return AppLocalizations.of(context)!.country_required;
        }

        return null;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomHeading(question: question, required: isRequired),
            CustomTextField(
              show: addressLine1['show'] ?? false,
              required: addressLine1['required'] ?? false,
              label: translate(addressLine1['placeholder'], context) ?? AppLocalizations.of(context)!.address_line_1,
              controller: _addressLine1Controller,
              revalidate: () => field.didChange,
              keyboardType: TextInputType.text,
              updateResponse: () => _updateResponse(),
            ),
            CustomTextField(
              show: addressLine2['show'] ?? false,
              required: addressLine2['required'] ?? false,
              label: translate(addressLine2['placeholder'], context) ?? AppLocalizations.of(context)!.address_line_2,
              controller: _addressLine2Controller,
              revalidate: () =>  field.didChange,
              keyboardType: TextInputType.text,
              updateResponse: () => _updateResponse(),
            ),
            CustomTextField(
              show: city['show'] ?? false,
              required: city['required'] ?? false,
              label: translate(city['placeholder'], context) ?? AppLocalizations.of(context)!.city,
              controller: _cityController,
              revalidate: () => field.didChange,
              keyboardType: TextInputType.text,
              updateResponse: () => _updateResponse(),
            ),
            CustomTextField(
              show: state['show'] ?? false,
              required: state['required'] ?? false,
              label: translate(state['placeholder'], context) ?? AppLocalizations.of(context)!.state,
              controller: _stateController,
              revalidate: () => field.didChange,
              keyboardType: TextInputType.text,
              updateResponse: () => _updateResponse(),
            ),
            CustomTextField(
              show: zip['show'] ?? false,
              required: zip['required'] ?? false,
              label: translate(zip['placeholder'], context) ?? AppLocalizations.of(context)!.zip,
              controller: _zipController,
              revalidate: () => field.didChange,
              keyboardType: TextInputType.text,
              updateResponse: () => _updateResponse(),
            ),
            CustomTextField(
              show: country['show'] ?? false,
              required: country['required'] ?? false,
              label: translate(country['placeholder'], context) ?? AppLocalizations.of(context)!.country,
              controller: _countryController,
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
