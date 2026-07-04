import 'package:flutter/material.dart';

/// Design tokens extracted from Figma — FieldTrack UI Kit.
/// All colors are used via [AppColors] rather than hard-coded hex values.
class AppColors {
  AppColors._();

  // ─── Primary ──────────────────────────────────────────────────────
  static const Color primary = Color(0xFF0D9488);
  static const Color primaryLight = Color(0xFF14B8A6);
  static const Color primaryDark = Color(0xFF0F766E);
  static const Color primarySurface = Color(0xFFCCFBF1); // light tint

  // ─── Backgrounds ──────────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF0F1115);

  // ─── Surfaces (cards, inputs) ─────────────────────────────────────
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A1D23);
  static const Color surfaceDarkElevated = Color(0xFF22252D);

  // ─── Text ─────────────────────────────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color textTertiaryLight = Color(0xFF9CA3AF);
  static const Color textTertiaryDark = Color(0xFF6B7280);

  // ─── Borders ──────────────────────────────────────────────────────
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF2D3139);

  // ─── Status ───────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color successSurface = Color(0xFFD1FAE5);
  static const Color successSurfaceDark = Color(0xFF064E3B);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSurface = Color(0xFFFEF3C7);
  static const Color warningSurfaceDark = Color(0xFF78350F);

  static const Color error = Color(0xFFEF4444);
  static const Color errorSurface = Color(0xFFFEE2E2);
  static const Color errorSurfaceDark = Color(0xFF7F1D1D);

  static const Color info = Color(0xFF3B82F6);

  // ─── Specific UI ──────────────────────────────────────────────────
  static const Color inputFillLight = Color(0xFFF9FAFB);
  static const Color inputFillDark = Color(0xFF1A1D23);
  static const Color iconLight = Color(0xFF6B7280);
  static const Color iconDark = Color(0xFF9CA3AF);
  static const Color dividerLight = Color(0xFFF3F4F6);
  static const Color dividerDark = Color(0xFF2D3139);
  static const Color shimmerBase = Color(0xFFE5E7EB);
  static const Color shimmerHighlight = Color(0xFFF3F4F6);

  // ─── Bottom Nav ───────────────────────────────────────────────────
  static const Color navInactiveLight = Color(0xFF9CA3AF);
  static const Color navInactiveDark = Color(0xFF6B7280);
}
