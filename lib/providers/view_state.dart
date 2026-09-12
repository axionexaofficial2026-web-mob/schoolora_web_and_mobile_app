enum ViewState { initial, loading, success, empty, error, refreshing }

extension ViewStateX on ViewState {
  bool get isInitial => this == ViewState.initial;
  bool get isLoading => this == ViewState.loading;
  bool get isSuccess => this == ViewState.success;
  bool get isEmpty => this == ViewState.empty;
  bool get isError => this == ViewState.error;
  bool get isRefreshing => this == ViewState.refreshing;
}
