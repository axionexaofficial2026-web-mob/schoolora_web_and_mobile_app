import 'package:flutter/foundation.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/error_handler.dart';
import '../data/models/config_model.dart';
import '../data/repositories/config_repository.dart';
import 'view_state.dart';

class ConfigProvider extends ChangeNotifier {
  final IConfigRepository _repository;

  ConfigProvider(this._repository);

  ViewState _state = ViewState.initial;
  PublicConfigModel? _config;
  AppException? _error;

  ViewState get state => _state;
  PublicConfigModel? get config => _config;
  AppException? get error => _error;

  bool get isLoading => _state == ViewState.loading;
  bool get isSuccess => _state == ViewState.success;
  bool get isError => _state == ViewState.error;
  bool get isRefreshing => _state == ViewState.refreshing;

  Future<void> fetchPublicConfig({bool silentRefresh = false}) async {
    if (silentRefresh && _config != null) {
      _state = ViewState.refreshing;
    } else {
      _state = ViewState.loading;
      _error = null;
    }
    notifyListeners();

    try {
      final result = await _repository.getPublicConfig();
      _config = result;
      _error = null;
      _state = ViewState.success;
    } catch (e) {
      _error = ErrorHandler.handle(e);
      _state = ViewState.error;
    } finally {
      notifyListeners();
    }
  }

  void reset() {
    _state = ViewState.initial;
    _config = null;
    _error = null;
    notifyListeners();
  }
}
