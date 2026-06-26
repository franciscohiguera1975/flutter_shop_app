// lib/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // ── Fondos ────────────────────────────────────────────────
  static const Color background  = Color(0xFF0A0A0F);
  static const Color surface     = Color(0xFF111118);
  static const Color surface2    = Color(0xFF1A1A24);
  static const Color border      = Color(0xFF2A2A38);
  static const Color borderLight = Color(0xFF1E1E2A);

  // ── Texto ─────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF0F0F8);
  static const Color textSecondary = Color(0xFF8888AA);
  static const Color textFaint     = Color(0xFF44445A);

  // ── Accent dorado ─────────────────────────────────────────
  static const Color accent      = Color(0xFFD4A843);
  static const Color accentLight = Color(0xFFF0C96E);
  static const Color accentDark  = Color(0xFFA07820);
  static const Color onAccent    = Color(0xFF0A0A0F);

  // ── Semánticos ────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error   = Color(0xFFEF4444);
  static const Color info    = Color(0xFF3B82F6);

  // ── Estado de pedido ──────────────────────────────────────
  static const Color statusPending   = Color(0xFFF59E0B);
  static const Color statusConfirmed = Color(0xFF3B82F6);
  static const Color statusShipped   = Color(0xFF8B5CF6);
  static const Color statusDelivered = Color(0xFF22C55E);
  static const Color statusCancelled = Color(0xFFEF4444);

  AppColors._();
}