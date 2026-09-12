import '../../core/errors/app_exception.dart';
import '../models/config_model.dart';
import '../services/config_api_service.dart';

abstract class IConfigRepository {
  Future<PublicConfigModel> getPublicConfig();
}

class ConfigRepository implements IConfigRepository {
  final ConfigApiService _apiService;

  ConfigRepository(this._apiService);

  @override
  Future<PublicConfigModel> getPublicConfig() async {
    final response = await _apiService.getPublicConfig();
    if (!response.success || response.data == null) {
      throw ServerException(
        message:
            response.error?.message ??
            'Failed to retrieve public configuration.',
        code: response.error?.code ?? 'CONFIG_FETCH_FAILED',
      );
    }
    return response.data!;
  }
}
