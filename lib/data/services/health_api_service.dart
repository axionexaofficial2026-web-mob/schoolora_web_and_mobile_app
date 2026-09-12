import '../../core/config/app_constants.dart';
import '../models/api_response.dart';
import '../models/health_model.dart';
import 'api_service.dart';

class HealthApiService extends BaseApiService {
  HealthApiService(super.dioClient);

  Future<ApiResponse<HealthModel>> getHealth() async {
    return getEnvelope<HealthModel>(
      path: AppConstants.endpointHealth,
      fromJsonT: (data) => HealthModel.fromJson(data as Map<String, dynamic>),
    );
  }
}
