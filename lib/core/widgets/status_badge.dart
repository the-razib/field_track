import 'package:flutter/material.dart';

import 'package:field_track/app/theme/app_colors.dart';
import 'package:field_track/app/theme/app_text_styles.dart';

/// Small pill-shaped badge for status indicators.
///
/// Used for: "Active", "Inactive", "Pending", "Completed", "150 m radius", etc.
enum BadgeVariant { active, inactive, pending, completed, neutral }

class StatusBadge extends StatelessWidget {
  final String text;
  final BadgeVariant variant;

  const StatusBadge({
    super.key,
    required this.text,
    this.variant = BadgeVariant.neutral,
  });

  /// Convenience constructors
  const StatusBadge.active({super.key, required this.text})
      : variant = BadgeVariant.active;

  const StatusBadge.inactive({super.key, required this.text})
      : variant = BadgeVariant.inactive;

  const StatusBadge.pending({super.key, required this.text})
      : variant = BadgeVariant.pending;

  const StatusBadge.completed({super.key, required this.text})
      : variant = BadgeVariant.completed;

  const StatusBadge.neutral({super.key, required this.text})
      : variant = BadgeVariant.neutral;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (bgColor, textColor) = _getColors(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: AppTextStyles.badge.copyWith(color: textColor),
      ),
    );
  }

  (Color bg, Color text) _getColors(bool isDark) {
    return switch (variant) {
      BadgeVariant.active => (
          isDark ? AppColors.successSurfaceDark : AppColors.successSurface,
          AppColors.success,
        ),
      BadgeVariant.inactive => (
          isDark ? AppColors.warningSurfaceDark : AppColors.warningSurface,
          AppColors.warning,
        ),
      BadgeVariant.pending => (
          isDark ? AppColors.warningSurfaceDark : AppColors.warningSurface,
          AppColors.warning,
        ),
      BadgeVariant.completed => (
          isDark ? AppColors.successSurfaceDark : AppColors.successSurface,
          AppColors.success,
        ),
      BadgeVariant.neutral => (
          isDark ? AppColors.surfaceDarkElevated : AppColors.backgroundLight,
          isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
    };
  }
}
