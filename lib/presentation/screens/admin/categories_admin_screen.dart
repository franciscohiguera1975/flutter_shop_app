// lib/presentation/screens/admin/categories_admin_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../domain/model/category.dart';
import '../../providers/categories_admin_provider.dart';
import '../../widgets/category_form.dart';

class CategoriesAdminScreen extends ConsumerWidget {
  const CategoriesAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(categoriesAdminProvider);
    final filtered = state.filtered;

    return Column(
      children: [
        Container(
          color:   AppColors.surface,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Categorías',
                        style: TextStyle(
                          color:      AppColors.textPrimary,
                          fontSize:   22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${state.categories.length} categorías',
                        style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => showCategoryForm(context, ref),
                    icon:      const Icon(Icons.add, size: 18),
                    label:     const Text('Nueva'),
                    style:     ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding:   const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: ref.read(categoriesAdminProvider.notifier).setSearch,
                decoration: const InputDecoration(
                  hintText:       'Buscar categoría...',
                  prefixIcon:     Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        Expanded(
          child: Builder(builder: (_) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              );
            }
            if (state.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.error!,
                        style: const TextStyle(color: AppColors.error)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(categoriesAdminProvider.notifier).load(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }
            if (filtered.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🏷️', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text(
                      state.search.isEmpty ? 'Sin categorías' : 'Sin resultados',
                      style: const TextStyle(
                        color:      AppColors.textPrimary,
                        fontSize:   18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding:          const EdgeInsets.all(16),
              itemCount:        filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _CategoryCard(
                category: filtered[i],
                onToggle: () => ref
                    .read(categoriesAdminProvider.notifier)
                    .toggleActive(filtered[i].id, !filtered[i].isActive),
                onEdit: () =>
                    showCategoryForm(context, ref, initial: filtered[i]),
                onDelete: () => _confirmDelete(context, ref, filtered[i]),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Category cat) {
    final hasProducts = cat.totalProducts > 0;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          hasProducts ? '¿Desactivar categoría?' : '¿Eliminar categoría?',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          hasProducts
              ? '"${cat.name}" tiene ${cat.totalProducts} producto(s). Se desactivará en lugar de eliminarse.'
              : '"${cat.name}" se eliminará permanentemente.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:     const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (hasProducts) {
                ref
                    .read(categoriesAdminProvider.notifier)
                    .toggleActive(cat.id, false);
              } else {
                ref.read(categoriesAdminProvider.notifier).deleteCategory(cat.id);
              }
            },
            child: Text(
              hasProducts ? 'Desactivar' : 'Eliminar',
              style: const TextStyle(
                color: AppColors.error, fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category     category;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: category.isActive ? 1.0 : 0.55,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Switch(
            value:            category.isActive,
            onChanged:        (_) => onToggle(),
            activeThumbColor: AppColors.accent,
            trackColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? AppColors.accent.withValues(alpha: 0.4)
                  : AppColors.border,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        category.name,
                        style: const TextStyle(
                          color:      AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!category.isActive) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Inactiva',
                          style: TextStyle(
                            color:      AppColors.error,
                            fontSize:   10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '/${category.slug}',
                  style: const TextStyle(
                    color:      AppColors.textFaint,
                    fontSize:   11,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  '${category.totalProducts} producto'
                  '${category.totalProducts != 1 ? "s" : ""}',
                  style: const TextStyle(
                    color:      AppColors.accent,
                    fontSize:   12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed:   onEdit,
                icon:        const Icon(Icons.edit_outlined, size: 20),
                color:       AppColors.textSecondary,
                padding:     EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              IconButton(
                onPressed:   onDelete,
                icon:        const Icon(Icons.delete_outline, size: 20),
                color:       AppColors.error,
                padding:     EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
