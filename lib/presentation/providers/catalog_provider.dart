// lib/presentation/providers/catalog_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/remote/api/category_remote_datasource.dart';
import '../../data/remote/api/product_remote_datasource.dart';
import '../../data/repository/category_repository_impl.dart';
import '../../domain/model/category.dart';
import '../../domain/model/product.dart';

// ── Categorías ────────────────────────────────────────────────
final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).getCategories();
});

// ── Estado del catálogo ───────────────────────────────────────
class CatalogState {
  final List<Product> products;
  final bool          isLoading;
  final bool          isLoadingMore;
  final String?       error;
  final int           total;
  final bool          hasMore;
  final String        search;
  final int?          selectedCategory;
  final String        ordering;
  final int           page;

  const CatalogState({
    this.products        = const [],
    this.isLoading       = false,
    this.isLoadingMore   = false,
    this.error,
    this.total           = 0,
    this.hasMore         = false,
    this.search          = '',
    this.selectedCategory,
    this.ordering        = '',
    this.page            = 1,
  });

  CatalogState copyWith({
    List<Product>? products,
    bool?          isLoading,
    bool?          isLoadingMore,
    String?        error,
    int?           total,
    bool?          hasMore,
    String?        search,
    int?           selectedCategory,
    bool           clearCategory = false,
    String?        ordering,
    int?           page,
  }) => CatalogState(
    products:         products         ?? this.products,
    isLoading:        isLoading        ?? this.isLoading,
    isLoadingMore:    isLoadingMore    ?? this.isLoadingMore,
    error:            error,
    total:            total            ?? this.total,
    hasMore:          hasMore          ?? this.hasMore,
    search:           search           ?? this.search,
    selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
    ordering:         ordering         ?? this.ordering,
    page:             page             ?? this.page,
  );
}

class CatalogNotifier extends StateNotifier<CatalogState> {
  final ProductRemoteDatasource _datasource;
  CatalogNotifier(this._datasource) : super(const CatalogState()) {
    load();
  }

  Future<void> load({bool reset = true}) async {
    final s    = state;
    final page = reset ? 1 : s.page;

    if (reset) {
      state = s.copyWith(isLoading: true, error: null, page: 1);
    } else {
      if (s.isLoadingMore || !s.hasMore) return;
      state = s.copyWith(isLoadingMore: true);
    }

    try {
      final result = await _datasource.getProducts(
        search:   s.search.isEmpty    ? null : s.search,
        category: s.selectedCategory,
        ordering: s.ordering.isEmpty  ? null : s.ordering,
        isActive: true,
        page:     page,
        pageSize: 12,
      );
      state = state.copyWith(
        products:     reset ? result.results : [...state.products, ...result.results],
        total:        result.count,
        hasMore:      result.next != null,
        isLoading:    false,
        isLoadingMore:false,
        page:         page + 1,
        error:        null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading:    false,
        isLoadingMore:false,
        error:        e.toString(),
      );
    }
  }

  void setSearch(String query) {
    state = state.copyWith(search: query);
    load();
  }

  void setCategory(int? id) {
    state = id == null
        ? state.copyWith(clearCategory: true)
        : state.copyWith(selectedCategory: id);
    load();
  }

  void setOrdering(String ordering) {
    state = state.copyWith(ordering: ordering);
    load();
  }

  void loadMore() => load(reset: false);
  void refresh()  => load();
}

final catalogProvider = StateNotifierProvider<CatalogNotifier, CatalogState>((ref) {
  return CatalogNotifier(ref.watch(productDatasourceProvider));
});

// Provider de un producto individual
final productDetailProvider = FutureProvider.family<Product, int>((ref, id) {
  return ref.watch(productDatasourceProvider).getProduct(id);
});