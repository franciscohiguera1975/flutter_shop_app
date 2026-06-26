// lib/presentation/screens/cart/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../data/remote/api/order_remote_datasource.dart';
import '../../../data/local/secure_storage.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cartProvider);

    if (state.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Carrito'),
          actions: [
            IconButton(
              icon: const Icon(Icons.receipt_long),
              tooltip: 'Mis órdenes',
              onPressed: () => context.go('/orders'),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
        body: const Center(
          child: Text(
            'El carrito está vacío',
            style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Carrito'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Mis órdenes',
            onPressed: () => context.go('/orders'),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          color: AppColors.background,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final it = state.items[i];
              return Card(
                color: AppColors.surface2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_bag, color: AppColors.accent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              it.product.name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${it.product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          IconButton(
                            onPressed: it.quantity > 1
                                ? () => ref.read(cartProvider.notifier).updateQuantity(
                                      it.product.id,
                                      it.quantity - 1,
                                    )
                                : () => ref.read(cartProvider.notifier).removeItem(it.product.id),
                            icon: const Icon(Icons.remove_circle_outline),
                            iconSize: 28,
                            color: AppColors.textSecondary,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 30,
                            child: Text(
                              it.quantity.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: it.quantity < it.product.stock
                                ? () => ref.read(cartProvider.notifier).updateQuantity(
                                      it.product.id,
                                      it.quantity + 1,
                                    )
                                : null,
                            icon: const Icon(Icons.add_circle_outline),
                            iconSize: 28,
                            color: it.quantity < it.product.stock
                                ? AppColors.accent
                                : AppColors.textFaint,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '\$${it.subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: AppColors.surface,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total: \$${state.totalWithTax.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await _confirmOrder(context, ref, state);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(160, 52), // Restrict width to avoid layout exception in Row
              ),
              child: const Text('Confirmar orden'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _confirmOrder(BuildContext context, WidgetRef ref, CartState state) async {
  print('DEBUG: Iniciando _confirmOrder con ${state.items.length} items');
  
  // Verificar autenticación
  final authState = ref.read(authProvider);
  print('DEBUG: Estado de autenticación: ${authState.isAuthenticated}');
  if (!authState.isAuthenticated) {
    print('DEBUG: Usuario no autenticado, redirigiendo a login');
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Debes iniciar sesión para confirmar una orden')),
    );
    context.go('/login');
    return;
  }
  
  final storage = ref.read(secureStorageProvider);
  final token = await storage.getAccess();
  print('DEBUG:.Token de acceso: ${token != null ? "Presente" : "Ausente"}');
  
  final datasource = ref.read(orderDatasourceProvider);
  
  final shouldConfirm = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Confirmar orden'),
      content: const Text('¿Deseas confirmar esta orden y enviar los productos?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(dialogContext).pop(true);
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(120, 48), // Restrict width to avoid layout exception in Dialog actions
          ),
          child: const Text('Confirmar'),
        ),
      ],
    ),
  );

  if (shouldConfirm != true) {
    print('DEBUG: Usuario canceló la confirmación');
    return;
  }

  print('DEBUG: Usuario confirmó, iniciando proceso de orden');
  
  try {
    print('DEBUG: Creando orden...');
    final order = await datasource.createOrder();
    print('DEBUG: Orden creada con ID: ${order.id}');
    
    for (final item in state.items) {
      print('DEBUG: Agregando item - product_id: ${item.product.id}, quantity: ${item.quantity}');
      await datasource.addItem(order.id, item.product.id, item.quantity);
    }
    print('DEBUG: Todos los items agregados');
    
    print('DEBUG: Confirmando orden ${order.id}...');
    final confirmedOrder = await datasource.confirmOrder(order.id);
    print('DEBUG: Orden confirmada: ${confirmedOrder.id}, status: ${confirmedOrder.status}');

    ref.read(cartProvider.notifier).clearCart();
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(content: Text('Orden #${confirmedOrder.id} confirmada')),
    );
    context.go('/orders');
  } catch (e) {
    print('DEBUG: Error confirmando orden: $e');
    print('DEBUG: Stack trace: ${StackTrace.current}');
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(content: Text('Error confirmando orden: $e')),
    );
  }
}