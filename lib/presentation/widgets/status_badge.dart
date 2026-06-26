// lib/presentation/widgets/status_badge.dart

import 'package:flutter/material.dart';
import '../../core/utils/formatters.dart';
import '../../domain/model/order.dart';

class StatusBadge extends StatelessWidget {
  final OrderStatus status;
  final bool        small;

  const StatusBadge({super.key, required this.status, this.small = false});

  @override
  Widget build(BuildContext context) {
    final color = orderStatusColor(status);
    final label = status.label;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8  : 10,
        vertical:   small ? 3  : 5,
      ),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border:       Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width:  small ? 5 : 6,
            height: small ? 5 : 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color:         color,
              fontSize:      small ? 10 : 11,
              fontWeight:    FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}