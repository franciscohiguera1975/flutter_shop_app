// lib/presentation/screens/admin/orders_admin_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/model/order.dart';

import '../../providers/orders_admin_provider.dart';
import '../../widgets/status_dropdown.dart';

const _statusFilters = [
  ('',          'Todos'),
  ('pending',   'Pendientes'),
  ('confirmed', 'Confirmados'),
  ('shipped',   'Enviados'),
  ('delivered', 'Entregados'),
  ('cancelled', 'Cancelados'),
];

class OrdersAdminScreen extends ConsumerStatefulWidget {
  const OrdersAdminScreen({super.key});

  @override
  ConsumerState<OrdersAdminScreen> createState() => _OrdersAdminScreenState();
}

class _OrdersAdminScreenState extends ConsumerState<OrdersAdminScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 150) {
        ref.read(ordersAdminProvider.notifier).loadMore();
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
    final state = ref.watch(ordersAdminProvider);
    final tt    = Theme.of(context).textTheme;

    return Column(
      children: [
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pedidos', style: tt.headlineMedium),
                      Text('${state.total} pedidos',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                  IconButton(
                    onPressed: ref.read(ordersAdminProvider.notifier).refresh,
                    icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _statusFilters.map((f) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f.$2),
                      selected: state.statusFilter == f.$1,
                      onSelected: (_) =>
                          ref.read(ordersAdminProvider.notifier).setStatusFilter(f.$1),
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
                    Text(state.error!, style: const TextStyle(color: AppColors.error)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: ref.read(ordersAdminProvider.notifier).refresh,
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
                    Text('🛍️', style: TextStyle(fontSize: 52)),
                    SizedBox(height: 12),
                    Text('Sin pedidos',
                        style: TextStyle(
                          color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              );
            }

            return ListView.separated(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: state.orders.length + (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                if (i >= state.orders.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2),
                    ),
                  );
                }
                final order = state.orders[i];
                return _OrderAdminCard(
                  order: order,
                  onStatus: (s) => ref.read(ordersAdminProvider.notifier).changeStatus(order.id, s),
                  onDetail: () => context.push('/admin/orders/${order.id}'),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

class _OrderAdminCard extends StatelessWidget {
  final Order                      order;
  final void Function(OrderStatus) onStatus;
  final VoidCallback               onDetail;

  const _OrderAdminCard({
    required this.order,
    required this.onStatus,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = formatDate(order.createdAt);

    return GestureDetector(
      onTap: onDetail,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pedido #${order.id}',
                      style: const TextStyle(
                        color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15,
                      ),
                    ),
                    Text(
                      '${order.username} · $dateStr',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
                StatusDropdown(current: order.status, onChange: onStatus),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6, runSpacing: 4,
              children: [
                ...order.items.take(2).map((item) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${item.quantity}× ${item.productName}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
                if (order.items.length > 2)
                  Text('+${order.items.length - 2} más',
                      style: const TextStyle(color: AppColors.textFaint, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.numItems} producto${order.numItems != 1 ? 's' : ''}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                Row(
                  children: [
                    Text(
                      formatPrice(order.total),
                      style: const TextStyle(
                        color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 15,
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
