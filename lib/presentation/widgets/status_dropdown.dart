// lib/presentation/widgets/status_dropdown.dart

import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../../domain/model/order.dart';

class StatusDropdown extends StatelessWidget {
  final OrderStatus                current;
  final void Function(OrderStatus) onChange;

  const StatusDropdown({
    super.key,
    required this.current,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final color = orderStatusColor(current);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: DropdownButton<OrderStatus>(
        value: current,
        isDense: true,
        underline: const SizedBox.shrink(),
        dropdownColor: const Color(0xFF111118),
        borderRadius: BorderRadius.circular(12),
        icon: Icon(Icons.arrow_drop_down, color: color, size: 18),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        selectedItemBuilder: (_) => OrderStatus.values.map((s) {
          final c = orderStatusColor(s);
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6, height: 6,
                margin: const EdgeInsets.only(right: 5),
                decoration: BoxDecoration(color: c, shape: BoxShape.circle),
              ),
              Text(s.label, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          );
        }).toList(),
        items: OrderStatus.values.map((s) {
          final c = orderStatusColor(s);
          final isCur = s == current;
          return DropdownMenuItem(
            value: s,
            child: Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  s.label,
                  style: TextStyle(
                    color: isCur ? c : Colors.white70,
                    fontWeight: isCur ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
                if (isCur) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.check, size: 14, color: c),
                ],
              ],
            ),
          );
        }).toList(),
        onChanged: (s) {
          if (s != null && s != current) onChange(s);
        },
      ),
    );
  }
}
