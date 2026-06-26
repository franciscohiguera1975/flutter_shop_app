// lib/presentation/providers/dashboard_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/remote/api/category_remote_datasource.dart';
import '../../data/remote/api/product_remote_datasource.dart';
import '../../data/remote/api/order_remote_datasource.dart';
import '../../data/remote/api/user_remote_datasource.dart';
import '../../domain/model/product.dart';

class DashboardData {
  final int totalActiveProducts;
  final int outOfStockProducts;
  final int totalStock;
  final double avgPrice;
  final int activeCategories;
  final int totalCategories;
  final int totalOrders;
  final double totalRevenue;
  final int pendingOrders;
  final Map<String, int> ordersByStatus;
  final int activeUsers;
  final int totalUsers;
  final int staffUsers;
  final List<Product> lowStockProducts;

  const DashboardData({
    this.totalActiveProducts = 0,
    this.outOfStockProducts = 0,
    this.totalStock = 0,
    this.avgPrice = 0,
    this.activeCategories = 0,
    this.totalCategories = 0,
    this.totalOrders = 0,
    this.totalRevenue = 0,
    this.pendingOrders = 0,
    this.ordersByStatus = const {},
    this.activeUsers = 0,
    this.totalUsers = 0,
    this.staffUsers = 0,
    this.lowStockProducts = const [],
  });
}

sealed class DashboardState {
  const DashboardState();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardSuccess extends DashboardState {
  final DashboardData data;
  final DateTime loadedAt;
  const DashboardSuccess(this.data, this.loadedAt);
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final CategoryRemoteDatasource _catDs;
  final ProductRemoteDatasource _prodDs;
  final OrderRemoteDatasource _orderDs;
  final UserRemoteDatasource _userDs;

  DashboardNotifier(this._catDs, this._prodDs, this._orderDs, this._userDs)
      : super(const DashboardLoading()) {
    load();
  }

  Future<void> load() async {
    state = const DashboardLoading();
    try {
      final results = await Future.wait([
        _prodDs.getStats(),
        _catDs.getStats(),
        _orderDs.getStats(),
        _userDs.getStats(),
        _prodDs.getProducts(isActive: true, ordering: 'stock', pageSize: 10),
      ]);

      final prodStats  = results[0] as Map<String, dynamic>;
      final catStats   = results[1] as Map<String, dynamic>;
      final orderStats = results[2] as Map<String, dynamic>;
      final userStats  = results[3] as Map<String, dynamic>;
      final lowStock   = (results[4] as PaginatedProducts)
          .results
          .where((p) => p.stock < 5)
          .take(5)
          .toList();

      final byStatus = (orderStats['by_status'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
          {};

      state = DashboardSuccess(
        DashboardData(
          totalActiveProducts: (prodStats['total_active'] as num?)?.toInt() ?? 0,
          outOfStockProducts:  (prodStats['out_of_stock'] as num?)?.toInt() ?? 0,
          totalStock:          (prodStats['total_stock'] as num?)?.toInt() ?? 0,
          avgPrice:            (prodStats['avg_price'] as num?)?.toDouble() ?? 0,
          activeCategories:    (catStats['active'] as num?)?.toInt() ?? 0,
          totalCategories:     (catStats['total'] as num?)?.toInt() ?? 0,
          totalOrders:         (orderStats['total_orders'] as num?)?.toInt() ?? 0,
          totalRevenue:        (orderStats['total_revenue'] as num?)?.toDouble() ?? 0,
          pendingOrders:       byStatus['pending'] ?? 0,
          ordersByStatus:      byStatus,
          activeUsers:         (userStats['active'] as num?)?.toInt() ?? 0,
          totalUsers:          (userStats['total'] as num?)?.toInt() ?? 0,
          staffUsers:          (userStats['staff'] as num?)?.toInt() ?? 0,
          lowStockProducts:    lowStock,
        ),
        DateTime.now(),
      );
    } catch (e) {
      state = DashboardError(e.toString().replaceAll('Exception: ', ''));
    }
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(
    ref.watch(categoryDatasourceProvider),
    ref.watch(productDatasourceProvider),
    ref.watch(orderDatasourceProvider),
    ref.watch(userDatasourceProvider),
  );
});
