// lib/presentation/screens/catalog/catalog_screen.dart — versión M5

import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../providers/catalog_provider.dart';
import '../../widgets/product_card.dart';
import 'package:flutter_shop_app/presentation/widgets/filters_sheet.dart';
import '../../widgets/search_bar.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(catalogProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openFilters() async {
    final state = ref.read(catalogProvider);
    final activeFilters = ProductFilters(
      categoryId: state.categoryId,
      ordering: state.ordering,
      minPrice: state.minPrice,
      maxPrice: state.maxPrice,
    );
    final result = await showFiltersSheet(
      context: context,
      activeFilters: activeFilters,
      categories: state.categories,
    );
    if (result != null && mounted) {
      ref.read(catalogProvider.notifier).setCategory(result.categoryId);
      ref.read(catalogProvider.notifier).setOrdering(result.ordering);
      ref.read(catalogProvider.notifier).setPriceRange(result.minPrice, result.maxPrice);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(catalogProvider);
    final numFilters = _countActiveFilters(state);

    if (state.isLoading && state.products.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }
    if (state.error != null && state.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('❌', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(state.error!, style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(catalogProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: ref.read(catalogProvider.notifier).refresh,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── Search bar + filter button ─────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: SearchBar(
                      initialValue: state.search,
                      onChanged: (q) => ref.read(catalogProvider.notifier).setSearch(q),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Stack(
                    children: [
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: numFilters > 0
                              ? AppColors.accent
                              : AppColors.surface,
                          foregroundColor: numFilters > 0
                              ? AppColors.onAccent
                              : AppColors.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppColors.border),
                          ),
                        ),
                        icon: const Icon(Icons.tune),
                        onPressed: _openFilters,
                      ),
                      if (numFilters > 0)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$numFilters',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Results count ──────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${state.total} result${state.total != 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          ),

          // ── Grid ────────────────────────────────────────
          if (state.products.isEmpty && !state.isLoading)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('📦', style: TextStyle(fontSize: 52)),
                    SizedBox(height: 16),
                    Text('No results',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final p = state.products[i];
                    return ProductCard(
                      product: p,
                      onTap: () => context.push('/catalog/${p.id}'),
                    );
                  },
                  childCount: state.products.length,
                ),
              ),
            ),

          // ── Loading more spinner ────────────────────────
          if (state.isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  int _countActiveFilters(CatalogState state) {
    int count = 0;
    if (state.categoryId != null) count++;
    if (state.ordering != null) count++;
    if (state.minPrice != null) count++;
    if (state.maxPrice != null) count++;
    return count;
  }
}