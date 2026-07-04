import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography tokens matching the Figma FieldTrack UI Kit.
///
/// Uses Inter font via Google Fonts for a clean, modern look.
class AppTextStyles {
  AppTextStyles._();

  static String? get _fontFamily => GoogleFonts.inter().fontFamily;

  // ─── Headings ─────────────────────────────────────────────────────

  /// Screen titles — "Profile", "Locations", "My tasks"
  static TextStyle heading1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.27,
    letterSpacing: -0.2,
  );

  /// Section headings
  static TextStyle heading2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
  );

  /// Card titles — "Welcome back", "Create your account"
  static TextStyle heading3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  // ─── Body ─────────────────────────────────────────────────────────

  /// Primary body text
  static TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Body text — card content, descriptions
  static TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
  );

  /// Small body text
  static TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.38,
  );

  // ─── Labels ───────────────────────────────────────────────────────

  /// Button text, field labels
  static TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.25,
  );

  /// Card action labels, menu items
  static TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.29,
  );

  /// Small labels, badges, bottom nav
  static TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
  );

  // ─── Captions ─────────────────────────────────────────────────────

  /// Timestamps, coordinates, secondary info
  static TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
  );

  /// Badge text
  static TextStyle badge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.27,
  );

  // ─── Special ──────────────────────────────────────────────────────

  /// App name "FieldTrack"
  static TextStyle appTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.35,
    letterSpacing: -0.3,
  );

  /// Stats numbers ("1/5", "3")
  static TextStyle statNumber = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.27,
  );

  /// Input text
  static TextStyle input = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.29,
  );

  /// Input hint
  static TextStyle inputHint = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.29,
  );

  /// Field label above input
  static TextStyle fieldLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.15,
  );
}
