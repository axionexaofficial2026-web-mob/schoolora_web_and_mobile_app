class ApiErrorPayload {
  final String code;
  final String message;
  final dynamic details;

  const ApiErrorPayload({
    required this.code,
    required this.message,
    this.details,
  });

  factory ApiErrorPayload.fromJson(Map<String, dynamic> json) {
    return ApiErrorPayload(
      code: json['code']?.toString() ?? 'UNKNOWN_ERROR',
      message: json['message']?.toString() ?? 'An error occurred.',
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    'details': details,
  };
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final ApiErrorPayload? error;
  final Map<String, dynamic>? meta;
  final String? timestamp;
  final String? requestId;

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.meta,
    this.timestamp,
    this.requestId,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic rawData) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] == true,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      error: json['error'] != null && json['error'] is Map<String, dynamic>
          ? ApiErrorPayload.fromJson(json['error'] as Map<String, dynamic>)
          : null,
      meta: json['meta'] is Map<String, dynamic>
          ? json['meta'] as Map<String, dynamic>
          : null,
      timestamp: json['timestamp']?.toString(),
      requestId: json['requestId']?.toString(),
    );
  }
}
