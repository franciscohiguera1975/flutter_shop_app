// lib/presentation/widgets/product_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/model/product.dart';

class ProductCard extends StatelessWidget {
  final Product      product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color:        AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border:       Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Imagen
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 1,
                child: product.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl:   product.imageUrl!,
                        fit:        BoxFit.cover,
                        placeholder:(_, __) => Container(color: AppColors.surface2),
                        errorWidget:(_, __, ___) => _ImagePlaceholder(),
                      )
                    : _ImagePlaceholder(),
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Categoría
                    if (product.category != null)
                      Text(
                        product.category!.name.toUpperCase(),
                        style: const TextStyle(
                          color:         AppColors.accent,
                          fontSize:      9,
                          fontWeight:    FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 2),

                    // Nombre
                    Flexible(
                      child: Text(
                        product.name,
                        style:    tt.bodySmall?.copyWith(
                          color:      AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Precio
                    Text(
                      formatPrice(product.price),
                      style: const TextStyle(
                        color:      AppColors.accent,
                        fontWeight: FontWeight.bold,
                        fontSize:   11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatPrice(product.priceWithTax)} IVA',
                      style: const TextStyle(
                        color:    AppColors.textSecondary,
                        fontSize: 8,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Sin stock
                    if (!product.inStock) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color:        AppColors.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text(
                          'Sin stock',
                          style: TextStyle(
                            color:     AppColors.error,
                            fontSize:  8,
                            fontWeight:FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    color:      AppColors.surface2,
    alignment:  Alignment.center,
    child:      const Text('📦', style: TextStyle(fontSize: 40)),
  );
}