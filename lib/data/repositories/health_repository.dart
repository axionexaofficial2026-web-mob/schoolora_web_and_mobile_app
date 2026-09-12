import '../../core/errors/app_exception.dart';
import '../models/health_model.dart';
import '../services/health_api_service.dart';

abstract class IHealthRepository {
  Future<HealthModel> getHealth();
}

class HealthRepository implements IHealthRepository {
  final HealthApiService _apiService;

  HealthRepository(this._apiService);

  @override
  Future<HealthModel> getHealth() async {
    final response = await _apiService.getHealth();
    if (!response.success || response.data == null) {
      throw ServerException(
        message:
            response.error?.message ??
            'Failed to retrieve system health status.',
        code: response.error?.code ?? 'HEALTH_CHECK_FAILED',
      );
    }
    return response.data!;
  }
}
