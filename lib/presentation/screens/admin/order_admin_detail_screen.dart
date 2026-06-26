// lib/presentation/screens/admin/order_admin_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/model/order.dart';
import '../../widgets/status_badge.dart';
import '../../providers/orders_admin_provider.dart';
import '../../widgets/status_dropdown.dart';

class OrderAdminDetailScreen extends ConsumerWidget {
  final int orderId;
  const OrderAdminDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderAdminDetailProvider(orderId));

    return orderAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
      error: (err, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(err.toString(), style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
      data: (order) => _DetailContent(order: order, ref: ref),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final Order order;
  final WidgetRef ref;
  const _DetailContent({required this.order, required this.ref});

  @override
  Widget build(BuildContext context) {
    final taxAmount = order.total - order.total / 1.15;
    final subtotal = order.total - taxAmount;
    final dateStr = formatDateTime(order.createdAt);
    final updatedStr = formatDateTime(order.updatedAt);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Card(
            title: 'Información del pedido',
            child: Column(
              children: [
                _InfoRow('Cliente', order.username),
                _InfoRow('Fecha', dateStr),
                _InfoRow('Actualizado', updatedStr),
                _InfoRow('Ítems', '${order.numItems}'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Estado actual',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    StatusBadge(status: order.status),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Cambiar estado',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    StatusDropdown(
                      current: order.status,
                      onChange: (s) {
                        ref.read(ordersAdminProvider.notifier).changeStatus(order.id, s);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Estado cambiado a "${s.label}"'),
                          backgroundColor: AppColors.success,
                          duration: const Duration(seconds: 2),
                        ));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Card(
            title: 'Productos (${order.numItems})',
            child: Column(
              children: order.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(child: Text('📦', style: TextStyle(fontSize: 20))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.productName,
                              style: const TextStyle(
                                color: AppColors.textPrimary, fontWeight: FontWeight.w600,
                              )),
                          Text('${formatPrice(item.unitPrice)} × ${item.quantity} ud.',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    Text(formatPrice(item.subtotal),
                        style: const TextStyle(
                          color: AppColors.accent, fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 14),
          _Card(
            title: 'Resumen financiero',
            child: Column(
              children: [
                _TotalRow('Subtotal (sin IVA)', subtotal, false),
                const SizedBox(height: 6),
                _TotalRow('IVA (15%)', taxAmount, false),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                _TotalRow('Total', order.total, true),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Card(
            title: 'Cambio rápido de estado',
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: OrderStatus.values
                  .where((s) => s != order.status)
                  .map((s) {
                    final color = orderStatusColor(s);
                    return GestureDetector(
                      onTap: () {
                        ref.read(ordersAdminProvider.notifier).changeStatus(order.id, s);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Estado cambiado a "${s.label}"'),
                          backgroundColor: AppColors.success,
                          duration: const Duration(seconds: 2),
                        ));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: color.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              s.label,
                              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textSecondary, fontSize: 11,
            fontWeight: FontWeight.bold, letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(value, style: const TextStyle(
          color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13,
        )),
      ],
    ),
  );
}

class _TotalRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isFinal;
  const _TotalRow(this.label, this.value, this.isFinal);

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          color: isFinal ? AppColors.textPrimary : AppColors.textSecondary,
          fontSize: isFinal ? 16 : 14,
          fontWeight: isFinal ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      Text(
        formatPrice(value),
        style: TextStyle(
          color: isFinal ? AppColors.accent : AppColors.textPrimary,
          fontSize: isFinal ? 18 : 14,
          fontWeight: isFinal ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
    ],
  );
}
