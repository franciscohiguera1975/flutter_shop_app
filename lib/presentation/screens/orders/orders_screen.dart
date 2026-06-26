// lib/presentation/screens/orders/orders_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/model/order.dart';
import '../../providers/orders_provider.dart';
import '../../widgets/status_badge.dart';

const _statusFilters = [
  ('',          'Todos'),
  ('pending',   'Pendientes'),
  ('confirmed', 'Confirmados'),
  ('shipped',   'Enviados'),
  ('delivered', 'Entregados'),
  ('cancelled', 'Cancelados'),
];

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 150) {
        ref.read(ordersProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ordersProvider);
    final tt    = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────
            Container(
              color:   AppColors.surface,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child:   Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mis pedidos', style: tt.headlineMedium),
                          Text(
                            '${state.total} pedido${state.total != 1 ? "s" : ""}',
                            style: tt.bodySmall,
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: ref.read(ordersProvider.notifier).refresh,
                        icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Filtros por estado
                  SizedBox(
                    height: 34,
                    child:  ListView(
                      scrollDirection:  Axis.horizontal,
                      children: _statusFilters.map((filter) {
                        final isSelected = state.statusFilter == filter.$1;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child:   ChoiceChip(
                            label:     Text(filter.$2),
                            selected:  isSelected,
                            onSelected:(_) =>
                                ref.read(ordersProvider.notifier).setStatusFilter(filter.$1),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // ── Contenido ─────────────────────────────────────
            Expanded(
              child: Builder(builder: (_) {
                if (state.isLoading && state.orders.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  );
                }
                if (state.error != null && state.orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('❌', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 12),
                        Text(state.error!,
                            style: const TextStyle(color: AppColors.error)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: ref.read(ordersProvider.notifier).refresh,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }
                if (state.orders.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('📦', style: TextStyle(fontSize: 52)),
                        SizedBox(height: 16),
                        Text('Sin pedidos',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            )),
                        Text('Tus pedidos aparecerán aquí',
                            style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  controller:      _scrollCtrl,
                  padding:         const EdgeInsets.all(16),
                  itemCount:       state.orders.length + (state.isLoadingMore ? 1 : 0),
                  separatorBuilder:(_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    if (i >= state.orders.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child:   CircularProgressIndicator(
                            color: AppColors.accent, strokeWidth: 2,
                          ),
                        ),
                      );
                    }
                    final order = state.orders[i];
                    return _OrderCard(
                      order:   order,
                      onTap:   () => context.push('/orders/${order.id}'),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── OrderCard ─────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final Order        order;
  final VoidCallback onTap;
  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tt      = Theme.of(context).textTheme;
    final dateStr = formatDate(order.createdAt);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:    const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border:       Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pedido #${order.id}', style: tt.titleMedium),
                    Text(dateStr, style: tt.bodySmall),
                  ],
                ),
                StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 12),

            // Preview de ítems
            Wrap(
              spacing: 6, runSpacing: 4,
              children: [
                ...order.items.take(3).map((item) => Container(
                  padding:    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color:        AppColors.surface2,
                    borderRadius: BorderRadius.circular(6),
                    border:       Border.all(color: AppColors.borderLight),
                  ),
                  child: Text(
                    '${item.quantity}× ${item.productName}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                )),
                if (order.items.length > 3)
                  Text(
                    '+${order.items.length - 3} más',
                    style: const TextStyle(color: AppColors.textFaint, fontSize: 11),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.numItems} producto${order.numItems != 1 ? "s" : ""}',
                  style: tt.bodySmall,
                ),
                Row(
                  children: [
                    Text(
                      formatPrice(order.total),
                      style: const TextStyle(
                        color: AppColors.accent, fontSize: 16, fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, color: AppColors.textFaint, size: 18),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}