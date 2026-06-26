// lib/presentation/screens/admin/products_admin_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/repository/category_repository_impl.dart';
import '../../../domain/model/category.dart';
import '../../../domain/model/product.dart';
import '../../providers/products_admin_provider.dart';
import '../../widgets/product_form.dart';
import '../../widgets/restock_dialog.dart';

class ProductsAdminScreen extends ConsumerStatefulWidget {
  const ProductsAdminScreen({super.key});

  @override
  ConsumerState<ProductsAdminScreen> createState() =>
      _ProductsAdminScreenState();
}

class _ProductsAdminScreenState extends ConsumerState<ProductsAdminScreen> {
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    ref.read(categoryRepositoryProvider).getCategories().then((cats) {
      if (mounted) setState(() => _categories = cats);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state    = ref.watch(productsAdminProvider);
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
                        'Productos',
                        style: TextStyle(
                          color:      AppColors.textPrimary,
                          fontSize:   22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${state.total} productos',
                        style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () =>
                            ref.read(productsAdminProvider.notifier).load(),
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => showProductForm(
                          context,
                          ref,
                          categories: _categories,
                        ),
                        icon:  const Icon(Icons.add, size: 18),
                        label: const Text('Nuevo'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged:
                    ref.read(productsAdminProvider.notifier).setSearch,
                decoration: const InputDecoration(
                  hintText:       'Buscar producto...',
                  prefixIcon:     Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: ProductStockFilter.values.map((f) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label:     Text(f.label),
                      selected:  state.stockFilter == f,
                      onSelected: (_) => ref
                          .read(productsAdminProvider.notifier)
                          .setStockFilter(f),
                    ),
                  )).toList(),
                ),
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
                          ref.read(productsAdminProvider.notifier).load(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }
            if (filtered.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('📦', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 12),
                    Text(
                      'Sin productos',
                      style: TextStyle(
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
              itemBuilder: (_, i) => _ProductAdminCard(
                product:  filtered[i],
                onToggle: () => ref
                    .read(productsAdminProvider.notifier)
                    .toggleActive(filtered[i].id, !filtered[i].isActive),
                onEdit: () => showProductForm(
                  context,
                  ref,
                  initial:    filtered[i],
                  categories: _categories,
                ),
                onRestock: () async {
                  final qty =
                      await showRestockDialog(context, filtered[i]);
                  if (qty != null && context.mounted) {
                    final newStock = await ref
                        .read(productsAdminProvider.notifier)
                        .restock(filtered[i].id, qty);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          newStock != null
                              ? '✅ Stock actualizado: $newStock unidades'
                              : '❌ Error al actualizar el stock',
                        ),
                        backgroundColor: newStock != null
                            ? AppColors.success
                            : AppColors.error,
                      ));
                    }
                  }
                },
                onDelete: () => _confirmDelete(context, ref, filtered[i]),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Product product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '¿Eliminar producto?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '"${product.name}" se eliminará permanentemente.',
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
              ref.read(productsAdminProvider.notifier).deleteProduct(product.id);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(
                color: AppColors.error, fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductAdminCard extends StatelessWidget {
  final Product      product;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onRestock;
  final VoidCallback onDelete;

  const _ProductAdminCard({
    required this.product,
    required this.onToggle,
    required this.onEdit,
    required this.onRestock,
    required this.onDelete,
  });

  Color _stockColor() {
    if (product.stock == 0) return AppColors.error;
    if (product.stock < 5) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: product.isActive ? 1.0 : 0.55,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width:  54,
              height: 54,
              child: product.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: product.imageUrl!,
                      fit:      BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.surface2,
                        child: const Center(child: Text('📦')),
                      ),
                    )
                  : Container(
                      color: AppColors.surface2,
                      child: const Center(
                        child: Text('📦', style: TextStyle(fontSize: 22)),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    color:      AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (product.category != null)
                  Text(
                    product.category!.name,
                    style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12,
                    ),
                  ),
                Row(
                  children: [
                    Text(
                      formatPrice(product.price),
                      style: const TextStyle(
                        color:      AppColors.accent,
                        fontWeight: FontWeight.bold,
                        fontSize:   14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _stockColor().withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.stock == 0
                            ? 'Agotado'
                            : '${product.stock} uds.',
                        style: TextStyle(
                          color:      _stockColor(),
                          fontSize:   10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Switch(
                value:            product.isActive,
                onChanged:        (_) => onToggle(),
                activeThumbColor: AppColors.accent,
              ),
              Row(
                children: [
                  _ActionIcon(
                    icon:  Icons.inventory_2_outlined,
                    color: AppColors.accent,
                    onTap: onRestock,
                  ),
                  _ActionIcon(
                    icon:  Icons.edit_outlined,
                    color: AppColors.textSecondary,
                    onTap: onEdit,
                  ),
                  _ActionIcon(
                    icon:  Icons.delete_outline,
                    color: AppColors.error,
                    onTap: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _ActionIcon extends StatelessWidget {
  final IconData     icon;
  final Color        color;
  final VoidCallback onTap;
  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(4),
      child:   Icon(icon, color: color, size: 20),
    ),
  );
}
