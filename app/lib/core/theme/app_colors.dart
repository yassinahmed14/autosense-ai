import 'package:flutter/material.dart';

/// "Racing Yellow & Carbon" light palette – the single source of truth for
/// every colour in the app.
///
/// Widgets should prefer `Theme.of(context).colorScheme`; use these constants
/// directly for roles the [ColorScheme] does not model (brand ink, caution,
/// success, carbon surfaces, gauge colours) or inside `CustomPainter`s.
///
/// Rule: [brandYellow] is a FILL colour only. Never draw yellow text or thin
/// yellow lines on a light background – use [brandInk] instead.
abstract final class AppColors {
  // Brand.
  /// Racing yellow. Primary fills: primary buttons, gauge sweep, selected
  /// chips, highlights, focus ring.
  static const brandYellow = Color(0xFFFFC20E);

  /// Content drawn on [brandYellow] (carbon).
  static const onBrandYellow = Color(0xFF111317);

  /// Yellow-family text, links and icons on white (AA ≥ 4.5:1).
  static const brandInk = Color(0xFF8A6100);

  /// Tinted brand surface; simulated-data banners, icon wells.
  static const primaryContainer = Color(0xFFFFF4CC);

  /// Content drawn on [primaryContainer].
  static const onPrimaryContainer = Color(0xFF3D2E00);

  // Carbon.
  /// Carbon. Secondary role: dark buttons, headings, navigation icons.
  static const carbon = Color(0xFF111317);

  /// Softer carbon for large dark surfaces and the gauge track.
  static const carbonSoft = Color(0xFF1C1F24);

  /// Content drawn on [carbon] / [carbonSoft].
  static const onCarbon = Color(0xFFFFFFFF);

  // Info – steel blue (tertiary role).
  /// Informational accent; secondary data series.
  static const info = Color(0xFF2F6FDE);

  /// Informational banner background.
  static const infoContainer = Color(0xFFE3ECFC);

  /// Content drawn on [infoContainer].
  static const onInfoContainer = Color(0xFF0B2A66);

  // Caution – orange (yellow is the brand, so warnings are orange).
  /// Caution accent for icons, borders and indicators.
  static const caution = Color(0xFFE06A00);

  /// Caution banner background.
  static const cautionContainer = Color(0xFFFFE9D6);

  /// Content drawn on [cautionContainer].
  static const onCautionContainer = Color(0xFF4A2300);

  // Status.
  /// Errors, destructive actions, urgent safety messages, gauge redline.
  static const error = Color(0xFFC62828);

  /// Content drawn on [error].
  static const onError = Color(0xFFFFFFFF);

  /// Error banner background.
  static const errorContainer = Color(0xFFFDE2E1);

  /// Content drawn on [errorContainer].
  static const onErrorContainer = Color(0xFF5C0A0A);

  /// Positive status (connected, verified).
  static const success = Color(0xFF1F8A4C);

  /// Success banner / icon-well background.
  static const successContainer = Color(0xFFDDF3E6);

  /// Content drawn on [successContainer].
  static const onSuccessContainer = Color(0xFF0A3D20);

  // Neutrals.
  /// App scaffold background (light silver).
  static const background = Color(0xFFF6F7F9);

  /// Cards, app bar, sheets, dialogs, inputs.
  static const surface = Color(0xFFFFFFFF);

  /// Subtle containers, chart backgrounds, empty states.
  static const surfaceContainer = Color(0xFFEEF0F3);

  /// 1 px borders on cards, inputs and chips.
  static const outline = Color(0xFFD3D7DD);

  /// Primary text and icons (carbon).
  static const textPrimary = Color(0xFF111317);

  /// Secondary text, captions, helper text.
  static const textSecondary = Color(0xFF5A616B);

  // Gauge.
  /// Gauge track (unfilled arc).
  static const gaugeTrack = carbonSoft;

  /// Gauge sweep (filled arc).
  static const gaugeSweep = brandYellow;

  /// Gauge redline segment (6 500–8 000 rpm).
  static const gaugeRedline = error;

  /// Trend-chart grid lines.
  static const chartGrid = outline;
}
