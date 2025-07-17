import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';
import 'dart:convert';

class FileUploadUtils {
  /// Generate UUID (simple implementation)
  static String generateUUID() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp * 1000 + (timestamp % 1000)).toString();
    return random;
  }

  /// Generate signature for local storage upload
  static String generateSignature({
    required String fileName,
    required String fileType,
    required String environmentId,
    required String timestamp,
    required String uuid,
    required String secretKey,
  }) {
    final data = '$fileName$fileType$environmentId$timestamp$uuid$secretKey';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Get file type from file path
  static String getFileType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.pdf':
        return 'application/pdf';
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case '.txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  /// Validate file size
  static bool isValidFileSize(File file, int maxSizeInMB) {
    final fileSizeInBytes = file.lengthSync();
    final maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    return fileSizeInBytes <= maxSizeInBytes;
  }

  /// Validate file extension
  static bool isValidFileExtension(String filePath, List<String> allowedExtensions) {
    final extension = path.extension(filePath).toLowerCase();
    return allowedExtensions.contains(extension);
  }
}