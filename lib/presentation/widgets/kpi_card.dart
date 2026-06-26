// lib/presentation/widgets/kpi_card.dart

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class KpiCard extends StatelessWidget {
  final String        title;
  final String        value;
  final String?       subtitle;
  final IconData      icon;
  final Color         color;
  final bool          hasAlert;
  final VoidCallback? onTap;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.color    = AppColors.accent,
    this.hasAlert = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    final card = Container(
      padding:    const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border:       hasAlert
            ? Border.all(color: AppColors.error.withValues(alpha: 0.3))
            : Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width:  38, height: 38,
                decoration: BoxDecoration(
                  color:        color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (hasAlert)
                const Text('⚠️', style: TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color:      AppColors.textPrimary,
              fontSize:   26,
              fontWeight: FontWeight.w800,
              height:     1,
            ),
          ),
          const SizedBox(height: 2),
          Text(title, style: tt.bodySmall),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                color:    hasAlert ? AppColors.error : AppColors.textFaint,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );

    return onTap != null
        ? GestureDetector(onTap: onTap, child: card)
        : card;
  }
}
