// lib/presentation/providers/products_admin_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/remote/api/product_remote_datasource.dart';
import '../../domain/model/product.dart';

enum ProductStockFilter { all, inStock, outOfStock, active, inactive }

extension ProductStockFilterLabel on ProductStockFilter {
  String get label => switch (this) {
    ProductStockFilter.all        => 'Todos',
    ProductStockFilter.inStock    => 'Con stock',
    ProductStockFilter.outOfStock => 'Sin stock',
    ProductStockFilter.active     => 'Activos',
    ProductStockFilter.inactive   => 'Inactivos',
  };
}

class ProductsAdminState {
  final List<Product>      products;
  final bool               isLoading;
  final String?            error;
  final int                total;
  final String             search;
  final ProductStockFilter stockFilter;
  final ProductFormState   formState;

  const ProductsAdminState({
    this.products    = const [],
    this.isLoading   = false,
    this.error,
    this.total       = 0,
    this.search      = '',
    this.stockFilter = ProductStockFilter.all,
    this.formState   = const ProductFormIdle(),
  });

  List<Product> get filtered => products.where((p) {
    final matchSearch = search.isEmpty ||
        p.name.toLowerCase().contains(search.toLowerCase());
    final matchFilter = switch (stockFilter) {
      ProductStockFilter.all        => true,
      ProductStockFilter.inStock    => p.stock > 0,
      ProductStockFilter.outOfStock => p.stock == 0,
      ProductStockFilter.active     => p.isActive,
      ProductStockFilter.inactive   => !p.isActive,
    };
    return matchSearch && matchFilter;
  }).toList();

  ProductsAdminState copyWith({
    List<Product>?      products,
    bool?               isLoading,
    String?             error,
    int?                total,
    String?             search,
    ProductStockFilter? stockFilter,
    ProductFormState?   formState,
  }) => ProductsAdminState(
    products:    products    ?? this.products,
    isLoading:   isLoading   ?? this.isLoading,
    error:       error,
    total:       total       ?? this.total,
    search:      search      ?? this.search,
    stockFilter: stockFilter ?? this.stockFilter,
    formState:   formState   ?? this.formState,
  );
}

sealed class ProductFormState {
  const ProductFormState();
}

class ProductFormIdle extends ProductFormState {
  const ProductFormIdle();
}

class ProductFormSaving extends ProductFormState {
  const ProductFormSaving();
}

class ProductFormSuccess extends ProductFormState {
  final String message;
  const ProductFormSuccess(this.message);
}

class ProductFormError extends ProductFormState {
  final String message;
  const ProductFormError(this.message);
}

class ProductsAdminNotifier extends StateNotifier<ProductsAdminState> {
  final ProductRemoteDatasource _datasource;

  ProductsAdminNotifier(this._datasource) : super(const ProductsAdminState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _datasource.getProducts(pageSize: 50);
      state = state.copyWith(
        products:  result.results,
        total:     result.count,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error:     e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void setSearch(String q) => state = state.copyWith(search: q);

  void setStockFilter(ProductStockFilter f) =>
      state = state.copyWith(stockFilter: f);

  Future<void> toggleActive(int id, bool isActive) async {
    state = state.copyWith(
      products: state.products.map((p) =>
        p.id == id ? p.copyWith(isActive: isActive) : p,
      ).toList(),
    );
    try {
      await _datasource.updateProduct(id, {'is_active': isActive});
    } catch (_) {
      state = state.copyWith(
        products: state.products.map((p) =>
          p.id == id ? p.copyWith(isActive: !isActive) : p,
        ).toList(),
      );
    }
  }

  Future<void> createProduct(Map<String, dynamic> payload) async {
    state = state.copyWith(formState: const ProductFormSaving());
    try {
      final created = await _datasource.createProduct(payload);
      state = state.copyWith(
        products:  [created, ...state.products],
        total:     state.total + 1,
        formState: const ProductFormSuccess('Producto creado'),
      );
    } catch (e) {
      state = state.copyWith(
        formState: ProductFormError(
          e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> updateProduct(int id, Map<String, dynamic> payload) async {
    state = state.copyWith(formState: const ProductFormSaving());
    try {
      final updated = await _datasource.updateProduct(id, payload);
      state = state.copyWith(
        products: state.products.map((p) => p.id == id ? updated : p).toList(),
        formState: const ProductFormSuccess('Producto actualizado'),
      );
    } catch (e) {
      state = state.copyWith(
        formState: ProductFormError(
          e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<int?> restock(int id, int quantity) async {
    try {
      final result   = await _datasource.restock(id, quantity);
      final newStock = result['new_stock'] as int;
      state = state.copyWith(
        products: state.products.map((p) =>
          p.id == id ? p.copyWith(stock: newStock) : p,
        ).toList(),
      );
      return newStock;
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await _datasource.deleteProduct(id);
      state = state.copyWith(
        products: state.products.where((p) => p.id != id).toList(),
        total:    state.total - 1,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void resetFormState() =>
      state = state.copyWith(formState: const ProductFormIdle());
}

final productsAdminProvider =
    StateNotifierProvider<ProductsAdminNotifier, ProductsAdminState>((ref) {
  return ProductsAdminNotifier(ref.watch(productDatasourceProvider));
});
