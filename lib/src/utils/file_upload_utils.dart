import 'dart:io';

class FileUploadUtils {
  /// Validate file size
  static bool isValidFileSize(File file, int maxSizeInMB) {
    final fileSizeInBytes = file.lengthSync();
    final maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    return fileSizeInBytes <= maxSizeInBytes;
  }

  /// Validate file extension
  static bool isValidFileExtension(String filePath, List<String> allowedExtensions) {
    final extension = filePath.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }
}