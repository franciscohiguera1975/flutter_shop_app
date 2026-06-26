// lib/presentation/screens/catalog/catalog_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../providers/catalog_provider.dart';
import '../../widgets/product_card.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _searchCtrl  = TextEditingController();
  final _scrollCtrl  = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(catalogProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state        = ref.watch(catalogProvider);
    final catsAsync    = ref.watch(categoriesProvider);
    final tt           = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────
            Container(
              color:   AppColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child:   Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Catálogo', style: tt.headlineMedium),
                      Text(
                        '${state.total} productos',
                        style: tt.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Búsqueda
                  TextField(
                    controller:  _searchCtrl,
                    onChanged:   (q) {
                      ref.read(catalogProvider.notifier).setSearch(q);
                    },
                    decoration: const InputDecoration(
                      hintText:    'Buscar productos...',
                      prefixIcon:  Icon(Icons.search_rounded, color: AppColors.textSecondary),
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),

                  // Chips de ordenamiento
                  SizedBox(
                    height: 34,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final item in [
                          ('',             'Relevancia'),
                          ('price',        'Precio ↑'),
                          ('-price',       'Precio ↓'),
                          ('-created_at',  'Recientes'),
                        ])
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child:   ChoiceChip(
                              label:     Text(item.$2),
                              selected:  state.ordering == item.$1,
                              onSelected:(_) => ref.read(catalogProvider.notifier).setOrdering(item.$1),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Chips de categorías
                  catsAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error:   (_, __) => const SizedBox.shrink(),
                    data: (cats) => SizedBox(
                      height: 34,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child:   ChoiceChip(
                              label:     const Text('Todas'),
                              selected:  state.selectedCategory == null,
                              onSelected:(_) => ref.read(catalogProvider.notifier).setCategory(null),
                            ),
                          ),
                          for (final cat in cats.where((c) => c.isActive))
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child:   ChoiceChip(
                                label:     Text(cat.name),
                                selected:  state.selectedCategory == cat.id,
                                onSelected:(_) =>
                                    ref.read(catalogProvider.notifier).setCategory(cat.id),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // ── Grid de productos ────────────────────────────
            Expanded(
              child: Builder(
                builder: (_) {
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
                          FilledButton(
                            onPressed: () => ref.read(catalogProvider.notifier).refresh(),
                            style:     FilledButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: AppColors.onAccent,
                            ),
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state.products.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🔍', style: TextStyle(fontSize: 48)),
                          SizedBox(height: 12),
                          Text('Sin resultados', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Intenta con otra búsqueda', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    controller:  _scrollCtrl,
                    padding:     const EdgeInsets.all(16),
                    gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:   2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing:  12,
                      childAspectRatio: 0.68,
                    ),
                    itemCount:  state.products.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder:(ctx, i) {
                      if (i >= state.products.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child:   CircularProgressIndicator(
                              color:       AppColors.accent,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      }
                      final product = state.products[i];
                      return ProductCard(
                        product: product,
                        onTap:   () => context.push('/product/${product.id}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}