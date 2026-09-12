abstract class AppException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final dynamic rawError;

  const AppException({
    required this.message,
    this.code,
    this.statusCode,
    this.rawError,
  });

  @override
  String toString() =>
      'AppException(code: $code, statusCode: $statusCode, message: $message)';
}

class NetworkException extends AppException {
  const NetworkException({
    super.message =
        'No internet connection or network unavailable. Please check your connection.',
    super.code = 'NETWORK_ERROR',
    super.statusCode,
    super.rawError,
  });
}

class TimeoutException extends AppException {
  const TimeoutException({
    super.message =
        'Connection timed out. The server is taking too long to respond.',
    super.code = 'TIMEOUT_ERROR',
    super.statusCode,
    super.rawError,
  });
}

class ServerException extends AppException {
  const ServerException({
    super.message =
        'An internal server error occurred. Please try again later.',
    super.code = 'SERVER_ERROR',
    super.statusCode = 500,
    super.rawError,
  });
}

class BadResponseException extends AppException {
  final dynamic details;

  const BadResponseException({
    required super.message,
    super.code = 'BAD_RESPONSE',
    super.statusCode,
    this.details,
    super.rawError,
  });
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Session expired or unauthorized. Please sign in again.',
    super.code = 'UNAUTHORIZED',
    super.statusCode = 401,
    super.rawError,
  });
}

class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'You do not have permission to perform this action.',
    super.code = 'FORBIDDEN',
    super.statusCode = 403,
    super.rawError,
  });
}

class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'The requested resource could not be found.',
    super.code = 'NOT_FOUND',
    super.statusCode = 404,
    super.rawError,
  });
}

class ParseException extends AppException {
  const ParseException({
    super.message = 'Failed to parse response data from server.',
    super.code = 'PARSE_ERROR',
    super.statusCode,
    super.rawError,
  });
}

class ValidationException extends AppException {
  final Map<String, dynamic>? errors;

  const ValidationException({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    super.statusCode = 422,
    this.errors,
    super.rawError,
  });
}

class UnknownException extends AppException {
  const UnknownException({
    super.message = 'An unexpected error occurred. Please try again.',
    super.code = 'UNKNOWN_ERROR',
    super.statusCode,
    super.rawError,
  });
}
