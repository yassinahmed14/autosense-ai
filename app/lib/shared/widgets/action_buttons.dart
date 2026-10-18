import 'package:flutter/material.dart';

/// Primary call to action: a full-width [FilledButton] with optional icon.
///
/// Use at most one per visual group. Pass `null` to [onPressed] to disable.
class PrimaryActionButton extends StatelessWidget {
  /// Creates a primary action button.
  const PrimaryActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  /// Button label.
  final String label;

  /// Tap handler; `null` renders the disabled state.
  final VoidCallback? onPressed;

  /// Optional leading icon.
  final IconData? icon;

  @override
  Widget build(BuildContext context) => icon == null
      ? FilledButton(onPressed: onPressed, child: Text(label))
      : FilledButton.icon(
          onPressed: onPressed, icon: Icon(icon), label: Text(label));
}

/// Secondary action: a full-width [OutlinedButton] with optional icon.
class SecondaryActionButton extends StatelessWidget {
  /// Creates a secondary action button.
  const SecondaryActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  /// Button label.
  final String label;

  /// Tap handler; `null` renders the disabled state.
  final VoidCallback? onPressed;

  /// Optional leading icon.
  final IconData? icon;

  @override
  Widget build(BuildContext context) => icon == null
      ? OutlinedButton(onPressed: onPressed, child: Text(label))
      : OutlinedButton.icon(
          onPressed: onPressed, icon: Icon(icon), label: Text(label));
}
