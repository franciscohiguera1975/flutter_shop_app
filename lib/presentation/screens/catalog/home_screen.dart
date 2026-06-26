// lib/presentation/screens/catalog/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../providers/catalog_provider.dart';
import '../../widgets/product_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final catalogState    = ref.watch(catalogProvider);
    final tt              = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              width:  double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 72, 24, 48),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end:   Alignment.bottomCenter,
                  colors: [AppColors.surface2, AppColors.background],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Descubre lo',
                    style: tt.headlineLarge?.copyWith(
                      color:      AppColors.textSecondary,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    'extraordinario',
                    style: tt.displaySmall?.copyWith(
                      color:      AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Los mejores productos seleccionados para ti.',
                    style: tt.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.go('/catalog'),
                    icon:      const Icon(Icons.grid_view_rounded, size: 18),
                    label:     const Text('Ver catálogo'),
                    style:     FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.onAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Categorías ────────────────────────────────────
          SliverToBoxAdapter(
            child: categoriesAsync.when(
              loading: () => const SizedBox.shrink(),
              error:   (_, __) => const SizedBox.shrink(),
              data: (cats) {
                final active = cats.where((c) => c.isActive).take(6).toList();
                if (active.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Categorías', style: tt.titleLarge),
                          TextButton(
                            onPressed: () => context.go('/catalog'),
                            child: const Text('Ver todas'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 80,
                      child:  ListView.separated(
                        padding:          const EdgeInsets.symmetric(horizontal: 24),
                        scrollDirection:  Axis.horizontal,
                        itemCount:        active.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final cat = active[i];
                          return GestureDetector(
                            onTap: () {
                              ref.read(catalogProvider.notifier).setCategory(cat.id);
                              context.go('/catalog');
                            },
                            child: Container(
                              width:   110,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color:        AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border:       Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('🏷️', style: TextStyle(fontSize: 22)),
                                  const SizedBox(height: 4),
                                  Text(
                                    cat.name,
                                    style:    const TextStyle(
                                      color:     AppColors.textPrimary,
                                      fontSize:  11,
                                      fontWeight:FontWeight.w600,
                                    ),
                                    maxLines:  1,
                                    overflow:  TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ),

          // ── Novedades — encabezado ─────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child:   Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Novedades', style: tt.titleLarge),
                  TextButton(
                    onPressed: () => context.go('/catalog'),
                    child: const Text('Ver todos'),
                  ),
                ],
              ),
            ),
          ),

          // ── Novedades — grid ───────────────────────────────
          if (catalogState.isLoading && catalogState.products.isEmpty)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child:   CircularProgressIndicator(color: AppColors.accent),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final product = catalogState.products.take(4).toList()[i];
                    return ProductCard(
                      product: product,
                      onTap:   () => context.push('/product/${product.id}'),
                    );
                  },
                  childCount: catalogState.products.take(4).length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:    2,
                  crossAxisSpacing:  12,
                  mainAxisSpacing:   12,
                  childAspectRatio:  0.68,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}