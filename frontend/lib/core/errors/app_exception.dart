class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({required this.message, this.statusCode});

  @override
  String toString() => 'AppException($statusCode): $message';
}

class NetworkException extends AppException {
  const NetworkException({required super.message, super.statusCode});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({super.message = 'Unauthorized. Please log in again.'})
      : super(statusCode: 401);
}

class NotFoundException extends AppException {
  const NotFoundException({required super.message}) : super(statusCode: 404);
}

class ServerException extends AppException {
  const ServerException({required super.message, super.statusCode});
}

class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;
  const ValidationException({required super.message, this.fieldErrors})
      : super(statusCode: 422);
}

class CacheException extends AppException {
  const CacheException({required super.message});
}
