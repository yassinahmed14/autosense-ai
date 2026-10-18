import 'package:flutter/widgets.dart';

/// 4-pt spacing scale. Use these instead of literal paddings.
abstract final class AppSpacing {
  /// 4 dp – icon/text gaps.
  static const double xs = 4;

  /// 8 dp – tight stacks, chip spacing.
  static const double sm = 8;

  /// 12 dp – between related controls.
  static const double md = 12;

  /// 16 dp – card padding, default gap.
  static const double lg = 16;

  /// 20 dp – screen padding.
  static const double xl = 20;

  /// 24 dp – hero padding, section gaps.
  static const double xxl = 24;

  /// 32 dp – major section breaks.
  static const double xxxl = 32;

  /// 48 dp – empty-state breathing room.
  static const double huge = 48;

  /// Default page padding for scrollable screens.
  static const page = EdgeInsets.all(xl);

  /// Maximum readable content width on tablets / desktop.
  static const double maxContentWidth = 840;

  /// Minimum interactive target size (Material / WCAG).
  static const double minTouchTarget = 48;

  /// Height of primary and secondary action buttons.
  static const double buttonHeight = 52;
}

/// Corner radii used across the design system.
abstract final class AppRadius {
  /// 12 dp – inputs, chips, banners, icon wells.
  static const double sm = 12;

  /// 16 dp – buttons.
  static const double md = 16;

  /// 20 dp – cards and metric cards.
  static const double lg = 20;

  /// 24 dp – hero card, dialogs.
  static const double xl = 24;

  /// [sm] as a [BorderRadius].
  static const small = BorderRadius.all(Radius.circular(sm));

  /// [md] as a [BorderRadius].
  static const medium = BorderRadius.all(Radius.circular(md));

  /// [lg] as a [BorderRadius].
  static const large = BorderRadius.all(Radius.circular(lg));

  /// [xl] as a [BorderRadius].
  static const extraLarge = BorderRadius.all(Radius.circular(xl));
}
