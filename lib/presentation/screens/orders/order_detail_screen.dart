// lib/presentation/screens/orders/order_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/model/order.dart';
import '../../providers/orders_provider.dart';
import '../../widgets/status_badge.dart';

const _progressSteps = [
  OrderStatus.pending,
  OrderStatus.confirmed,
  OrderStatus.shipped,
  OrderStatus.delivered,
];

class OrderDetailScreen extends ConsumerWidget {
  final int orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        title:   Text('Pedido #$orderId'),
        leading: IconButton(
          icon:      const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: orderAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('❌', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text(err.toString(), style: const TextStyle(color: AppColors.error)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child:     const Text('Volver'),
              ),
            ],
          ),
        ),
        data: (order) {
          final isCancelled  = order.status == OrderStatus.cancelled;
          final currentStep  = _progressSteps.indexOf(order.status);
          final taxAmount    = order.total - order.total / 1.15;
          final subtotal     = order.total - taxAmount;
          final dateStr      = formatDateTime(order.createdAt);
          final updatedStr   = formatDateTime(order.updatedAt);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child:   Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Header con status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dateStr,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text('Cliente: ${order.username}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                    StatusBadge(status: order.status),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Barra de progreso ────────────────────────
                if (!isCancelled) ...[
                  _SectionCard(
                    title: 'Estado del pedido',
                    child: _OrderProgressBar(
                      steps:       _progressSteps,
                      currentStep: currentStep,
                    ),
                  ),
                  const SizedBox(height: 14),
                ] else ...[
                  Container(
                    width:   double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color:        AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border:       Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: const Text(
                      '⚠️ Este pedido fue cancelado',
                      style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // ── Productos ────────────────────────────────
                _SectionCard(
                  title: 'Productos (${order.numItems})',
                  child: Column(
                    children: order.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width:  44, height: 44,
                            decoration: BoxDecoration(
                              color:        AppColors.surface2,
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
                                Text(
                                  '${formatPrice(item.unitPrice)} × ${item.quantity} ud.',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary, fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            formatPrice(item.subtotal),
                            style: const TextStyle(
                              color: AppColors.accent, fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 14),

                // ── Resumen financiero ───────────────────────
                _SectionCard(
                  title: 'Resumen',
                  child: Column(
                    children: [
                      _FinancialRow('Subtotal (sin IVA)', subtotal,      false),
                      const SizedBox(height: 6),
                      _FinancialRow('IVA (15%)',          taxAmount,     false),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      _FinancialRow('Total',              order.total,   true),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Meta
                Center(
                  child: Text(
                    'Actualizado: $updatedStr',
                    style: const TextStyle(color: AppColors.textFaint, fontSize: 11),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Barra de progreso ─────────────────────────────────────────

class _OrderProgressBar extends StatelessWidget {
  final List<OrderStatus> steps;
  final int               currentStep;
  const _OrderProgressBar({required this.steps, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: steps.asMap().entries.map((entry) {
        final idx     = entry.key;
        final step    = entry.value;
        final isDone  = idx <= currentStep;
        final isCurr  = idx == currentStep;

        return Expanded(
          child: Row(
            children: [
              // Nodo
              Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width:  isCurr ? 36 : 30,
                    height: isCurr ? 36 : 30,
                    decoration: BoxDecoration(
                      color:  isDone ? AppColors.accent : AppColors.surface2,
                      shape:  BoxShape.circle,
                      border: Border.all(
                        color: isDone ? AppColors.accent : AppColors.border,
                        width: isCurr ? 2 : 1,
                      ),
                      boxShadow: isCurr
                          ? [BoxShadow(
                              color:       AppColors.accent.withValues(alpha: 0.3),
                              blurRadius:  8,
                              spreadRadius:2,
                            )]
                          : null,
                    ),
                    child: Center(
                      child: isDone
                          ? Text(
                              '✓',
                              style: TextStyle(
                                color:      AppColors.onAccent,
                                fontWeight: FontWeight.bold,
                                fontSize:   isCurr ? 14 : 12,
                              ),
                            )
                          : Text(
                              '${idx + 1}',
                              style: const TextStyle(
                                color:    AppColors.textFaint,
                                fontSize: 11,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 60,
                    child: Text(
                      step.label,
                      style: TextStyle(
                        color:      isDone ? AppColors.accent : AppColors.textFaint,
                        fontSize:   9,
                        fontWeight: isCurr ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              // Línea conectora
              if (idx < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 20),
                    color:  idx < currentStep ? AppColors.accent : AppColors.border,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width:   double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color:        AppColors.surface,
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

class _FinancialRow extends StatelessWidget {
  final String label;
  final double value;
  final bool   isFinal;
  const _FinancialRow(this.label, this.value, this.isFinal);

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          color:      isFinal ? AppColors.textPrimary : AppColors.textSecondary,
          fontSize:   isFinal ? 16 : 14,
          fontWeight: isFinal ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      Text(
        formatPrice(value),
        style: TextStyle(
          color:      isFinal ? AppColors.accent : AppColors.textPrimary,
          fontSize:   isFinal ? 18 : 14,
          fontWeight: isFinal ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
    ],
  );
}