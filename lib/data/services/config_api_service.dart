import '../../core/config/app_constants.dart';
import '../models/api_response.dart';
import '../models/config_model.dart';
import 'api_service.dart';

class ConfigApiService extends BaseApiService {
  ConfigApiService(super.dioClient);

  Future<ApiResponse<PublicConfigModel>> getPublicConfig() async {
    return getEnvelope<PublicConfigModel>(
      path: AppConstants.endpointPublicConfig,
      fromJsonT: (data) =>
          PublicConfigModel.fromJson(data as Map<String, dynamic>),
    );
  }
}
