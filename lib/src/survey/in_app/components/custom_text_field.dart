import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final bool show;
  final bool required;
  final String label;
  final TextEditingController controller;
  final void Function() revalidate;
  final TextInputType? keyboardType;
  final void Function() updateResponse;

  const CustomTextField({
    super.key,
    required this.show,
    required this.required,
    required this.label,
    required this.controller,
    required this.revalidate,
    required this.keyboardType,
    required this.updateResponse
  });

  @override
  Widget build(BuildContext context) {
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
                updateResponse();
                revalidate();
              },
              textInputAction: TextInputAction.next,
              keyboardType: keyboardType ?? TextInputType.text,
            ),
          ],
        )
    );
  }

}