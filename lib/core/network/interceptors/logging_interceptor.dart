import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Safe logging interceptor that strips sensitive authentication data,
/// tokens, passwords, and secret keys before printing in development mode.
class LoggingInterceptor extends Interceptor {
  static const List<String> _sensitiveKeys = [
    'authorization',
    'password',
    'token',
    'accesstoken',
    'refreshtoken',
    'secret',
    'api_key',
    'apikey',
    'otp',
  ];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final sanitizedHeaders = _sanitizeMap(options.headers);
      final sanitizedData = options.data is Map<String, dynamic>
          ? _sanitizeMap(options.data as Map<String, dynamic>)
          : options.data;

      debugPrint('[DIO >>] ${options.method} ${options.uri}');
      debugPrint('[DIO >> Headers] $sanitizedHeaders');
      if (sanitizedData != null) {
        debugPrint('[DIO >> Body] $sanitizedData');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '[DIO <<] ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}',
      );
      if (response.data != null) {
        final sanitized = response.data is Map<String, dynamic>
            ? _sanitizeMap(response.data as Map<String, dynamic>)
            : response.data;
        debugPrint('[DIO << Body] $sanitized');
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '[DIO !!] ERROR [${err.response?.statusCode}] ${err.requestOptions.method} ${err.requestOptions.uri}: ${err.message}',
      );
      if (err.response?.data != null) {
        debugPrint('[DIO !! Response Data] ${err.response?.data}');
      }
    }
    handler.next(err);
  }

  Map<String, dynamic> _sanitizeMap(Map<dynamic, dynamic> source) {
    final clean = <String, dynamic>{};
    source.forEach((key, value) {
      final keyStr = key.toString();
      final lowerKey = keyStr.toLowerCase().replaceAll(RegExp(r'[-_]'), '');
      final isSensitive = _sensitiveKeys.any((s) => lowerKey.contains(s));

      if (isSensitive) {
        clean[keyStr] = '***REDACTED***';
      } else if (value is Map) {
        clean[keyStr] = _sanitizeMap(value);
      } else if (value is List) {
        clean[keyStr] = value.map((item) {
          if (item is Map) return _sanitizeMap(item);
          return item;
        }).toList();
      } else {
        clean[keyStr] = value;
      }
    });
    return clean;
  }
}
