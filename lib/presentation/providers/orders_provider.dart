// lib/presentation/providers/orders_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/remote/api/order_remote_datasource.dart';
import '../../domain/model/order.dart';

// ── Estado del historial ──────────────────────────────────────
class OrdersState {
  final List<Order> orders;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int total;
  final bool hasMore;
  final String statusFilter;
  final int page;

  const OrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.total = 0,
    this.hasMore = false,
    this.statusFilter = '',
    this.page = 1,
  });

  OrdersState copyWith({
    List<Order>? orders,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? total,
    bool? hasMore,
    String? statusFilter,
    int? page,
  }) => OrdersState(
    orders: orders ?? this.orders,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    error: error,
    total: total ?? this.total,
    hasMore: hasMore ?? this.hasMore,
    statusFilter: statusFilter ?? this.statusFilter,
    page: page ?? this.page,
  );
}

class OrdersNotifier extends StateNotifier<OrdersState> {
  final OrderRemoteDatasource _datasource;

  OrdersNotifier(this._datasource) : super(const OrdersState()) {
    load();
  }

  Future<void> load({bool reset = true}) async {
    final s = state;
    final page = reset ? 1 : s.page;

    if (reset) {
      state = s.copyWith(isLoading: true, error: null, page: 1);
    } else {
      if (s.isLoadingMore || !s.hasMore) return;
      state = s.copyWith(isLoadingMore: true);
    }

    try {
      final result = await _datasource.getOrders(
        page: page,
        status: s.statusFilter.isEmpty ? null : s.statusFilter,
      );
      state = state.copyWith(
        orders: reset ? result.results : [...state.orders, ...result.results],
        total: result.count,
        hasMore: result.next != null,
        isLoading: false,
        isLoadingMore: false,
        page: page + 1,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void setStatusFilter(String filter) {
    state = state.copyWith(statusFilter: filter);
    load();
  }

  void loadMore() => load(reset: false);
  void refresh() => load();
}

final ordersProvider =
    StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
  return OrdersNotifier(ref.watch(orderDatasourceProvider));
});

// Provider de un pedido individual
final orderDetailProvider = FutureProvider.family<Order, int>((ref, id) {
  return ref.watch(orderDatasourceProvider).getOrder(id);
});