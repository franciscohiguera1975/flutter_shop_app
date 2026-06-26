// lib/presentation/screens/catalog/product_detail_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/config/app_config.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/cart_provider.dart';
import '../../../domain/model/product.dart';

class ProductDetailScreen extends ConsumerWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogProvider);
    final product = state.products.firstWhere(
      (p) => p.id == productId,
      orElse: () => state.products.isEmpty
          ? Product.empty()
          : state.products.first,
    );

    if (state.isLoading && state.products.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    if (product.id == 0) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Product not found', style: TextStyle(color: AppColors.error)),
        ),
      );
    }

    return _ProductDetailContent(product: product);
  }
}

class _ProductDetailContent extends ConsumerStatefulWidget {
  final Product product;
  const _ProductDetailContent({required this.product});

  @override
  ConsumerState<_ProductDetailContent> createState() => _ProductDetailContentState();
}

class _ProductDetailContentState extends ConsumerState<_ProductDetailContent> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final outOfStock = p.stock == 0;
    final subtotal = p.price * _quantity;
    final taxAmount = subtotal * AppConfig.taxRate;
    final totalWithTax = subtotal + taxAmount;

    return Scaffold(
      appBar: AppBar(title: Text(p.name, overflow: TextOverflow.ellipsis)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ─────────────────────────────────────
            Stack(
              children: [
                Container(
                  height: 240,
                  width: double.infinity,
                  color: AppColors.borderLight,
                  child: p.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: p.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppColors.surface2,
                            child: const Center(
                              child: CircularProgressIndicator(color: AppColors.accent),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.surface2,
                            child: const Center(
                              child: Text('📦', style: TextStyle(fontSize: 72)),
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.surface2,
                          child: const Center(
                            child: Text('📦', style: TextStyle(fontSize: 72)),
                          ),
                        ),
                ),
                if (outOfStock)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: AppColors.error.withValues(alpha: 0.85),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: const Text(
                        'OUT OF STOCK',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // ── Body ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  Text(
                    (p.category?.name ?? 'No category').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Name
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Prices
                  Text(
                    formatPrice(p.price),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent,
                    ),
                  ),
                  Text(
                    '${formatPrice(totalWithTax)} with tax (${(AppConfig.taxRate * 100).toInt()}%)',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),

                  // Stock
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: outOfStock ? AppColors.error : AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        outOfStock
                            ? 'Product out of stock'
                            : '${p.stock} units in stock',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),

                  // Description
                  if (p.description.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.description,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],

                  // Quantity selector
                  if (!outOfStock) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _QuantityButton(
                          icon: Icons.remove,
                          onTap: _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            '$_quantity',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        _QuantityButton(
                          icon: Icons.add,
                          onTap: _quantity < p.stock
                              ? () => setState(() => _quantity++)
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Subtotal
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: AppColors.border)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Subtotal:',
                            style: TextStyle(
                                fontSize: 16, color: AppColors.textSecondary),
                          ),
                          Text(
                            formatPrice(totalWithTax),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Add to cart button
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: outOfStock
                        ? ElevatedButton.styleFrom(
                            backgroundColor: AppColors.textFaint)
                        : null,
                    onPressed: outOfStock
                        ? null
                        : () {
                            ref.read(cartProvider.notifier).addItem(
                                  p,
                                  quantity: _quantity,
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '✅ $_quantity× ${p.name} agregado al carrito',
                                ),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                    child: Text(
                      outOfStock
                          ? 'Out of stock'
                          : 'Add${_quantity > 1 ? ' $_quantity×' : ''} to cart',
                    ),
                  ),

                  // Meta
                  const SizedBox(height: 20),
                  Text(
                    'Updated: ${formatDateTime(p.updatedAt)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textFaint),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QuantityButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) => IconButton(
        style: IconButton.styleFrom(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border, width: 1.5),
          ),
        ),
        icon: Icon(icon,
            color: onTap != null
                ? AppColors.textPrimary
                : AppColors.textFaint),
        onPressed: onTap,
      );
}