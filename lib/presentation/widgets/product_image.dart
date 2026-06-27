// lib/presentation/widgets/product_image.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Widget que muestra la imagen de un producto desde una URL remota.
///
/// - Si [imageUrl] es null, muestra un placeholder con icono.
/// - Mientras carga, muestra un shimmer animado.
/// - Si la carga falla, muestra un icono de error.
class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height = 220,
    this.fit = BoxFit.cover,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  final String?       imageUrl;
  final double?       width;
  final double        height;
  final BoxFit        fit;
  final BorderRadius  borderRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: borderRadius,
      child: imageUrl != null
          ? CachedNetworkImage(
              imageUrl:    imageUrl!,
              width:       width,
              height:      height,
              fit:         fit,
              placeholder: (context, url) => _ShimmerBox(
                width:  width,
                height: height,
              ),
              errorWidget: (context, url, error) => _PlaceholderBox(
                width:       width,
                height:      height,
                colorScheme: colorScheme,
                icon:        Icons.broken_image_outlined,
              ),
            )
          : _PlaceholderBox(
              width:       width,
              height:      height,
              colorScheme: colorScheme,
              icon:        Icons.image_outlined,
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Subwidgets privados
// ---------------------------------------------------------------------------

class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox({this.width, required this.height});

  final double? width;
  final double  height;

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double>   _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        width:  widget.width,
        height: widget.height,
        color:  base.withValues(alpha: _animation.value),
      ),
    );
  }
}

class _PlaceholderBox extends StatelessWidget {
  const _PlaceholderBox({
    this.width,
    required this.height,
    required this.colorScheme,
    required this.icon,
  });

  final double?      width;
  final double       height;
  final ColorScheme  colorScheme;
  final IconData     icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  width,
      height: height,
      color:  colorScheme.surfaceContainerHighest,
      child:  Center(
        child: Icon(
          icon,
          size:  48,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
