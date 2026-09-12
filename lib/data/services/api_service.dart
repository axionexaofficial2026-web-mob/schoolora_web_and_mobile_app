import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/api_response.dart';

abstract class BaseApiService {
  final DioClient dioClient;

  BaseApiService(this.dioClient);

  Future<ApiResponse<T>> getEnvelope<T>({
    required String path,
    required T Function(dynamic rawData) fromJsonT,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final response = await dioClient.get<Map<String, dynamic>>(
      path,
      queryParameters: queryParameters,
      options: options,
    );

    return ApiResponse<T>.fromJson(response.data ?? {}, fromJsonT);
  }

  Future<ApiResponse<T>> postEnvelope<T>({
    required String path,
    dynamic data,
    required T Function(dynamic rawData) fromJsonT,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final response = await dioClient.post<Map<String, dynamic>>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );

    return ApiResponse<T>.fromJson(response.data ?? {}, fromJsonT);
  }

  Future<ApiResponse<T>> putEnvelope<T>({
    required String path,
    dynamic data,
    required T Function(dynamic rawData) fromJsonT,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final response = await dioClient.put<Map<String, dynamic>>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );

    return ApiResponse<T>.fromJson(response.data ?? {}, fromJsonT);
  }

  Future<ApiResponse<T>> deleteEnvelope<T>({
    required String path,
    dynamic data,
    required T Function(dynamic rawData) fromJsonT,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final response = await dioClient.delete<Map<String, dynamic>>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );

    return ApiResponse<T>.fromJson(response.data ?? {}, fromJsonT);
  }
}
