/// Generic wrapper for API responses from the BlueGPS server.
class BlueGpsApiResponse<T> {
  final bool success;
  final T? data;
  final String? errorMessage;
  final int? statusCode;

  const BlueGpsApiResponse({
    required this.success,
    this.data,
    this.errorMessage,
    this.statusCode,
  });

  factory BlueGpsApiResponse.success(T data) =>
      BlueGpsApiResponse(success: true, data: data);

  factory BlueGpsApiResponse.error(String message, {int? statusCode}) =>
      BlueGpsApiResponse(
        success: false,
        errorMessage: message,
        statusCode: statusCode,
      );
}
