import 'package:flutter/material.dart';

import 'package:field_track/app/theme/app_colors.dart';
import 'package:field_track/app/theme/app_text_styles.dart';

/// Reusable text field matching Figma design.
///
/// Features:
/// - Label above the field
/// - Leading icon (mail, lock, user, etc.)
/// - Trailing icon with tap (eye toggle for password)
/// - Error state
class AppTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final Widget? suffixWidget;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final int maxLines;

  const AppTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.prefixIcon,
    this.suffixWidget,
    this.obscureText = false,
    this.keyboardType,
    this.errorText,
    this.onChanged,
    this.textInputAction,
    this.readOnly = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Text(
          label,
          style: AppTextStyles.fieldLabel.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 7),

        // Input
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          readOnly: readOnly,
          maxLines: maxLines,
          style: AppTextStyles.input.copyWith(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 14, right: 10),
                    child: Icon(
                      prefixIcon,
                      size: 19,
                      color: isDark ? AppColors.iconDark : AppColors.iconLight,
                    ),
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 43,
              minHeight: 19,
            ),
            suffixIcon: suffixWidget,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}
