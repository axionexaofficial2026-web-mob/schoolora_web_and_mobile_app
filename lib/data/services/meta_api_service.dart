import '../../core/config/app_constants.dart';
import '../models/api_response.dart';
import '../models/meta_model.dart';
import 'api_service.dart';

class MetaApiService extends BaseApiService {
  MetaApiService(super.dioClient);

  Future<ApiResponse<MetaModel>> getMeta() async {
    return getEnvelope<MetaModel>(
      path: AppConstants.endpointMeta,
      fromJsonT: (data) => MetaModel.fromJson(data as Map<String, dynamic>),
    );
  }
}
