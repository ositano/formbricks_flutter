/// Handles API errors and user feedback.
class FormbricksError implements Exception {
  final String message;

  FormbricksError(this.message);

  @override
  String toString() => 'FormbricksError: $message';
}