import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/catalog_filter.dart';
import '../../domain/catalog_repository.dart';
import '../../domain/product.dart';
import 'catalog_state.dart';

class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit(this._repository) : super(const CatalogState());
  final CatalogRepository _repository;
  bool _isLoading = false;
  bool? _hasInterface;
  bool _automaticRefreshPending = false;
  DateTime? _lastSuccessfulRefresh;

  void connectionChanged(bool available, {bool refresh = true}) {
    if (isClosed || _hasInterface == available) {
      return;
    }
    final previous = _hasInterface;
    _hasInterface = available;
    _setConnection(
      available
          ? (previous == false ? CatalogConnection.checking : state.connection)
          : CatalogConnection.offline,
    );
    if (refresh && available && (previous == false || state.failure != null)) {
      _requestAutomaticRefresh();
    }
  }

  void refreshOnResume() {
    if (isClosed || _hasInterface == false) {
      return;
    }
    final last = _lastSuccessfulRefresh;
    if (state.failure != null ||
        state.connection != CatalogConnection.online ||
        last == null ||
        DateTime.now().difference(last) >= const Duration(minutes: 1)) {
      _requestAutomaticRefresh();
    }
  }

  void _setConnection(CatalogConnection connection) {
    emit(
      _buildState(
        connection: connection,
        isRefreshing: state.isRefreshing,
        failure: state.failure,
        cacheWriteFailed: state.cacheWriteFailed,
      ),
    );
  }

  void _requestAutomaticRefresh() {
    if (_isLoading) {
      _automaticRefreshPending = true;
    } else if (!isClosed) {
      unawaited(refresh());
    }
  }

  void applyFilter(CatalogFilter filter) {
    if (!filter.isValid) {
      throw ArgumentError.value(filter, 'filter', 'Invalid price range');
    }
    if (!isClosed && filter != state.filter) {
      emit(
        _buildState(
          filter: filter,
          isRefreshing: state.isRefreshing,
          failure: state.failure,
          cacheWriteFailed: state.cacheWriteFailed,
        ),
      );
    }
  }

  void resetFilters() => applyFilter(const CatalogFilter());
  Future<void> load() => _load(readCache: true);
  Future<void> refresh() => _load(readCache: !state.hasCatalog);
  CatalogState _buildState({
    CatalogStatus? status,
    List<Product>? products,
    CatalogFilter? filter,
    bool isRefreshing = false,
    bool? isFromCache,
    AppFailure? failure,
    DateTime? updatedAt,
    bool cacheWriteFailed = false,
    CatalogConnection? connection,
  }) {
    final source = products ?? state.products;
    final active = filter ?? state.filter;
    final categories = products == null
        ? state.categories
        : List<String>.unmodifiable(
            source.map((p) => p.category).toSet().toList()..sort(),
          );
    final visible = products == null && filter == null
        ? state.filteredProducts
        : List<Product>.unmodifiable(
            source.where(
              (p) =>
                  (active.category == null || p.category == active.category) &&
                  (active.minPriceCents == null ||
                      p.unitPriceCents >= active.minPriceCents!) &&
                  (active.maxPriceCents == null ||
                      p.unitPriceCents <= active.maxPriceCents!),
            ),
          );
    return CatalogState(
      status: status ?? state.status,
      products: source,
      filteredProducts: visible,
      categories: categories,
      filter: active,
      isRefreshing: isRefreshing,
      isFromCache: isFromCache ?? state.isFromCache,
      failure: failure,
      updatedAt: updatedAt ?? state.updatedAt,
      cacheWriteFailed: cacheWriteFailed,
      connection: connection ?? state.connection,
    );
  }

  Future<void> _load({required bool readCache}) async {
    if (_isLoading || isClosed) return;
    _isLoading = true;
    try {
      if (!state.hasCatalog) {
        emit(_buildState(status: CatalogStatus.loading));
        if (readCache) {
          final cached = await _repository.readCache();
          if (isClosed) return;
          if (cached != null) {
            _applySnapshot(cached, fromCache: true, refreshing: true);
          }
        }
      } else {
        emit(_buildState(isRefreshing: true));
      }
      final result = await _repository.refresh();
      if (!isClosed) {
        _lastSuccessfulRefresh = DateTime.now();
        _applySnapshot(result);
      }
    } on Exception catch (error) {
      if (isClosed) return;
      final failure = error is AppFailure
          ? error
          : const AppFailure(FailureKind.unexpected);
      emit(
        _buildState(
          status: state.hasCatalog ? state.status : CatalogStatus.error,
          failure: failure,
          connection: _hasInterface == false
              ? CatalogConnection.offline
              : failure.kind == FailureKind.clientError ||
                    failure.kind == FailureKind.serverError
              ? CatalogConnection.online
              : CatalogConnection.unreachable,
        ),
      );
    } finally {
      _isLoading = false;
      if (_automaticRefreshPending) {
        _automaticRefreshPending = false;
        if (!isClosed && _hasInterface != false) {
          unawaited(refresh());
        }
      }
    }
  }

  void _applySnapshot(
    CatalogSnapshot snapshot, {
    bool fromCache = false,
    bool refreshing = false,
  }) => emit(
    _buildState(
      status: snapshot.products.isEmpty
          ? CatalogStatus.empty
          : CatalogStatus.success,
      products: snapshot.products,
      updatedAt: snapshot.updatedAt,
      isFromCache: fromCache,
      isRefreshing: refreshing,
      cacheWriteFailed: snapshot.cacheWriteFailed,
      connection: fromCache
          ? state.connection
          : _hasInterface == false
          ? CatalogConnection.offline
          : CatalogConnection.online,
    ),
  );
}
