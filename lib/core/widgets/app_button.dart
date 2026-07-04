import 'package:flutter/material.dart';

import 'package:field_track/app/theme/app_colors.dart';

/// Reusable button matching Figma design.
///
/// Variants:
/// - [AppButton.primary] — filled teal button (e.g., "Sign in", "Save location")
/// - [AppButton.outlined] — bordered button (e.g., "Sign out")
/// - [AppButton.destructive] — red outlined button (e.g., "Delete location")
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final _AppButtonVariant _variant;
  final IconData? icon;
  final double? width;

  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  }) : _variant = _AppButtonVariant.primary;

  const AppButton.outlined({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  }) : _variant = _AppButtonVariant.outlined;

  const AppButton.destructive({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  }) : _variant = _AppButtonVariant.destructive;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: width ?? double.infinity,
      height: 52,
      child: switch (_variant) {
        _AppButtonVariant.primary => ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _buildChild(Colors.white),
          ),
        _AppButtonVariant.outlined => OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              side: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _buildChild(
              isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
        _AppButtonVariant.destructive => OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _buildChild(AppColors.error),
          ),
      },
    );
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation(color),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 19),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      );
    }

    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    );
  }
}

enum _AppButtonVariant { primary, outlined, destructive }
