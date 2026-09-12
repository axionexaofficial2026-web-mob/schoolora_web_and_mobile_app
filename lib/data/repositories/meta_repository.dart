import '../../core/errors/app_exception.dart';
import '../models/meta_model.dart';
import '../services/meta_api_service.dart';

abstract class IMetaRepository {
  Future<MetaModel> getMeta();
}

class MetaRepository implements IMetaRepository {
  final MetaApiService _apiService;

  MetaRepository(this._apiService);

  @override
  Future<MetaModel> getMeta() async {
    final response = await _apiService.getMeta();
    if (!response.success || response.data == null) {
      throw ServerException(
        message:
            response.error?.message ??
            'Failed to retrieve application metadata.',
        code: response.error?.code ?? 'META_FETCH_FAILED',
      );
    }
    return response.data!;
  }
}
