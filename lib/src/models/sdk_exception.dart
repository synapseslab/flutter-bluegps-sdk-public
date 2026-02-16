/// Base exception for all SDK errors.
class BlueGpsSdkException implements Exception {
  final String message;
  final Object? cause;

  BlueGpsSdkException(this.message, {this.cause});

  @override
  String toString() => 'BlueGpsSdkException: $message';
}

/// Thrown when a Quuppa advertising operation fails.
class QuuppaException extends BlueGpsSdkException {
  QuuppaException(super.message, {super.cause});

  @override
  String toString() => 'QuuppaException: $message';
}

/// Thrown when a server API operation fails.
class BlueGpsServerException extends BlueGpsSdkException {
  final int? statusCode;

  BlueGpsServerException(super.message, {super.cause, this.statusCode});

  @override
  String toString() => 'BlueGpsServerException($statusCode): $message';
}
