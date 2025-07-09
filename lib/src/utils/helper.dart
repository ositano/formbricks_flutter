

import 'package:flutter/material.dart';
import 'package:formbricks_flutter/src/utils/extensions.dart';

String translateField(Map<String, dynamic>? map, BuildContext context) {
  return (map)?.tr(context) ?? '';
}