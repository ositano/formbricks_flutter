import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../l10n/app_localizations.dart';
import '../../models/question.dart';
import '../../utils/helper.dart';

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
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _populateFields(widget.response as Map<String, dynamic>? ?? {});
    _initializeVideo();
  }

  @override
  void didUpdateWidget(covariant AddressQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.response != oldWidget.response) {
      _populateFields(widget.response as Map<String, dynamic>? ?? {});
    }

    if (widget.question.videoUrl != oldWidget.question.videoUrl) {
      _initializeVideo();
    }
  }

  void _initializeVideo() {
    _videoController?.dispose();
    _chewieController?.dispose();
    _chewieController = null;

    final videoUrl = widget.question.videoUrl;
    if (videoUrl != null && videoUrl.isNotEmpty) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
        ..initialize()
            .then((_) {
          if (!mounted) return;
          if (_videoController!.value.isInitialized) {
            _chewieController = ChewieController(
              videoPlayerController: _videoController!,
              autoPlay: false,
              looping: false,
            );
            setState(() {});
          }
        })
            .catchError((error) {
          debugPrint('Video initialization error: $error');
        });
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
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final question = widget.question;

    final addressLine1 = question.addressLine1 ?? {};
    final addressLine2 = question.addressLine2 ?? {};
    final city = question.city ?? {};
    final state = question.state ?? {};
    final zip = question.zip ?? {};
    final country = question.country ?? {};

    return FormField<bool>(
      validator: (_) {
        if(widget.requiredAnswerByLogicCondition) {
          return AppLocalizations.of(context)!.response_required;
        }

        if (!(question.required ?? false)) return null;

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
            else if (_chewieController != null &&
                _videoController?.value.isInitialized == true)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Chewie(controller: _chewieController!),
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
              show: addressLine1['show'] ?? false,
              required: addressLine1['required'] ?? false,
              label: translate(addressLine1['placeholder'], context) ?? AppLocalizations.of(context)!.address_line_1,
              controller: _addressLine1Controller,
              revalidate: () => field.didChange,
                keyboardType: TextInputType.text
            ),
            _buildField(
              show: addressLine2['show'] ?? false,
              required: addressLine2['required'] ?? false,
              label: translate(addressLine2['placeholder'], context) ?? AppLocalizations.of(context)!.address_line_2,
              controller: _addressLine2Controller,
              revalidate: () =>  field.didChange,
                keyboardType: TextInputType.text
            ),
            _buildField(
              show: city['show'] ?? false,
              required: city['required'] ?? false,
              label: translate(city['placeholder'], context) ?? AppLocalizations.of(context)!.city,
              controller: _cityController,
              revalidate: () => field.didChange,
                keyboardType: TextInputType.text
            ),
            _buildField(
              show: state['show'] ?? false,
              required: state['required'] ?? false,
              label: translate(state['placeholder'], context) ?? AppLocalizations.of(context)!.state,
              controller: _stateController,
              revalidate: () => field.didChange,
                keyboardType: TextInputType.text
            ),
            _buildField(
              show: zip['show'] ?? false,
              required: zip['required'] ?? false,
              label: translate(zip['placeholder'], context) ?? AppLocalizations.of(context)!.zip,
              controller: _zipController,
                revalidate: () => field.didChange,
                keyboardType: TextInputType.text
            ),
            _buildField(
              show: country['show'] ?? false,
              required: country['required'] ?? false,
              label: translate(country['placeholder'], context) ?? AppLocalizations.of(context)!.country,
              controller: _countryController,
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
