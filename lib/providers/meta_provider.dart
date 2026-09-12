import 'package:flutter/foundation.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/error_handler.dart';
import '../data/models/meta_model.dart';
import '../data/repositories/meta_repository.dart';
import 'view_state.dart';

class MetaProvider extends ChangeNotifier {
  final IMetaRepository _repository;

  MetaProvider(this._repository);

  ViewState _state = ViewState.initial;
  MetaModel? _meta;
  AppException? _error;

  ViewState get state => _state;
  MetaModel? get meta => _meta;
  AppException? get error => _error;

  bool get isLoading => _state == ViewState.loading;
  bool get isSuccess => _state == ViewState.success;
  bool get isError => _state == ViewState.error;
  bool get isRefreshing => _state == ViewState.refreshing;

  Future<void> fetchMeta({bool silentRefresh = false}) async {
    if (silentRefresh && _meta != null) {
      _state = ViewState.refreshing;
    } else {
      _state = ViewState.loading;
      _error = null;
    }
    notifyListeners();

    try {
      final result = await _repository.getMeta();
      _meta = result;
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
    _meta = null;
    _error = null;
    notifyListeners();
  }
}
