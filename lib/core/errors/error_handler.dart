import 'dart:io';
import 'package:dio/dio.dart';
import 'app_exception.dart';

class ErrorHandler {
  ErrorHandler._();

  static AppException handle(dynamic error) {
    if (error is AppException) {
      return error;
    }

    if (error is DioException) {
      return _handleDioException(error);
    }

    if (error is SocketException) {
      return NetworkException(
        message:
            'Unable to reach the server. Please check your network connection.',
        rawError: error,
      );
    }

    if (error is FormatException) {
      return ParseException(
        message: 'Data formatting or JSON parsing error: ${error.message}',
        rawError: error,
      );
    }

    return UnknownException(
      message: error?.toString() ?? 'An unexpected error occurred.',
      rawError: error,
    );
  }

  static AppException _handleDioException(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          message:
              'Connection timed out. Please check your internet connection or try again.',
          rawError: dioError,
        );

      case DioExceptionType.badCertificate:
        return const NetworkException(
          message: 'Security certificate verification failed.',
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(dioError);

      case DioExceptionType.cancel:
        return const UnknownException(
          message: 'Request was cancelled.',
          code: 'REQUEST_CANCELLED',
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          message:
              'Connection to server failed. Please verify that the server is running and accessible.',
          rawError: dioError,
        );

      case DioExceptionType.unknown:
      default:
        if (dioError.error is SocketException) {
          return NetworkException(
            message: 'Network connection error. Server unreachable.',
            rawError: dioError,
          );
        }
        return UnknownException(
          message: dioError.message ?? 'An unknown network error occurred.',
          rawError: dioError,
        );
    }
  }

  static AppException _handleBadResponse(DioException dioError) {
    final response = dioError.response;
    final statusCode = response?.statusCode;
    final responseData = response?.data;

    String message = 'Server returned an error.';
    String? code;
    dynamic details;

    if (responseData is Map<String, dynamic>) {
      if (responseData['error'] is Map<String, dynamic>) {
        final errMap = responseData['error'] as Map<String, dynamic>;
        message = errMap['message']?.toString() ?? message;
        code = errMap['code']?.toString();
        details = errMap['details'];
      } else if (responseData['message'] != null) {
        message = responseData['message'].toString();
        code = responseData['code']?.toString();
      }
    } else if (responseData is String && responseData.isNotEmpty) {
      message = responseData;
    }

    switch (statusCode) {
      case 400:
        return BadResponseException(
          message: message,
          code: code ?? 'BAD_REQUEST',
          statusCode: statusCode,
          details: details,
          rawError: dioError,
        );
      case 401:
        return UnauthorizedException(
          message: message.isNotEmpty ? message : 'Unauthorized access.',
          code: code ?? 'UNAUTHORIZED',
          statusCode: statusCode,
          rawError: dioError,
        );
      case 403:
        return ForbiddenException(
          message: message.isNotEmpty ? message : 'Access forbidden.',
          code: code ?? 'FORBIDDEN',
          statusCode: statusCode,
          rawError: dioError,
        );
      case 404:
        return NotFoundException(
          message: message.isNotEmpty ? message : 'Resource not found.',
          code: code ?? 'NOT_FOUND',
          statusCode: statusCode,
          rawError: dioError,
        );
      case 422:
        return ValidationException(
          message: message,
          code: code ?? 'VALIDATION_ERROR',
          statusCode: statusCode,
          errors: details is Map<String, dynamic> ? details : null,
          rawError: dioError,
        );
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(
          message: message.isNotEmpty ? message : 'Internal server error.',
          code: code ?? 'SERVER_ERROR',
          statusCode: statusCode,
          rawError: dioError,
        );
      default:
        return BadResponseException(
          message: message,
          code: code ?? 'HTTP_$statusCode',
          statusCode: statusCode,
          details: details,
          rawError: dioError,
        );
    }
  }
}
