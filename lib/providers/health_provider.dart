import 'package:flutter/foundation.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/error_handler.dart';
import '../data/models/health_model.dart';
import '../data/repositories/health_repository.dart';
import 'view_state.dart';

class HealthProvider extends ChangeNotifier {
  final IHealthRepository _repository;

  HealthProvider(this._repository);

  ViewState _state = ViewState.initial;
  HealthModel? _health;
  AppException? _error;
  DateTime? _lastCheckedAt;

  ViewState get state => _state;
  HealthModel? get health => _health;
  AppException? get error => _error;
  DateTime? get lastCheckedAt => _lastCheckedAt;

  bool get isLoading => _state == ViewState.loading;
  bool get isSuccess => _state == ViewState.success;
  bool get isError => _state == ViewState.error;
  bool get isRefreshing => _state == ViewState.refreshing;

  Future<void> fetchHealth({bool silentRefresh = false}) async {
    if (silentRefresh && _health != null) {
      _state = ViewState.refreshing;
    } else {
      _state = ViewState.loading;
      _error = null;
    }
    notifyListeners();

    try {
      final result = await _repository.getHealth();
      _health = result;
      _error = null;
      _state = ViewState.success;
      _lastCheckedAt = DateTime.now();
    } catch (e) {
      _error = ErrorHandler.handle(e);
      _state = ViewState.error;
    } finally {
      notifyListeners();
    }
  }

  void reset() {
    _state = ViewState.initial;
    _health = null;
    _error = null;
    _lastCheckedAt = null;
    notifyListeners();
  }
}
