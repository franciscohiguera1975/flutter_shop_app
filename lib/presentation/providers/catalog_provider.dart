// lib/presentation/providers/catalog_provider.dart — versión M5 actualizada

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/remote/api/category_remote_datasource.dart';
import '../../data/remote/api/product_remote_datasource.dart';
import '../../domain/model/category.dart';
import '../../domain/model/product.dart';

// ── Estado del catálogo ──────────────────────────────────────
class CatalogState {
  final List<Product> products;
  final List<Category> categories;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int total;
  final bool hasMore;
  final int page;
  final String? search;
  final int? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final String? ordering;

  const CatalogState({
    this.products = const [],
    this.categories = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.total = 0,
    this.hasMore = false,
    this.page = 1,
    this.search,
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.ordering,
  });

  CatalogState copyWith({
    List<Product>? products,
    List<Category>? categories,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? total,
    bool? hasMore,
    int? page,
    String? search,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    String? ordering,
  }) => CatalogState(
    products: products ?? this.products,
    categories: categories ?? this.categories,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    error: error,
    total: total ?? this.total,
    hasMore: hasMore ?? this.hasMore,
    page: page ?? this.page,
    search: search,
    categoryId: categoryId,
    minPrice: minPrice,
    maxPrice: maxPrice,
    ordering: ordering,
  );
}

class CatalogNotifier extends StateNotifier<CatalogState> {
  final ProductRemoteDatasource _productDs;
  final CategoryRemoteDatasource _categoryDs;

  CatalogNotifier(this._productDs, this._categoryDs)
      : super(const CatalogState()) {
    loadCategories();
    load();
  }

  Future<void> loadCategories() async {
    try {
      final cats = await _categoryDs.getCategories();
      state = state.copyWith(categories: cats);
    } catch (e) {
      // No fallar si no cargan categorías
    }
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
      final result = await _productDs.getProducts(
        page: page,
        search: s.search,
        category: s.categoryId,
        priceMin: s.minPrice,
        priceMax: s.maxPrice,
        ordering: s.ordering,
      );
      state = state.copyWith(
        products: reset ? result.results : [...state.products, ...result.results],
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

  void setSearch(String? value) {
    state = state.copyWith(search: value?.isEmpty == true ? null : value);
    load();
  }

  void setCategory(int? id) {
    state = state.copyWith(categoryId: id);
    load();
  }

  void setPriceRange(double? min, double? max) {
    state = state.copyWith(minPrice: min, maxPrice: max);
    load();
  }

  void setOrdering(String? value) {
    state = state.copyWith(ordering: value);
    load();
  }

  void clearFilters() {
    state = state.copyWith(
      search: null,
      categoryId: null,
      minPrice: null,
      maxPrice: null,
      ordering: null,
    );
    load();
  }

  void loadMore() => load(reset: false);
  Future<void> refresh() => load();
}

final catalogProvider = StateNotifierProvider<CatalogNotifier, CatalogState>((ref) {
  return CatalogNotifier(
    ref.watch(productDatasourceProvider),
    ref.watch(categoryDatasourceProvider),
  );
});

// Expose categories as an AsyncValue so UI code can use `when(...)` patterns.
final categoriesProvider = Provider<AsyncValue<List<Category>>>((ref) {
  final state = ref.watch(catalogProvider);
  return AsyncValue.data(state.categories);
});