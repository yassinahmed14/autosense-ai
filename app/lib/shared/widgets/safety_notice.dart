import 'package:autosense_ai/core/theme/app_colors.dart';
import 'package:autosense_ai/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Persistent safety disclaimer shown on diagnostic and scanner screens.
///
/// The wording is reviewed copy; do not shorten or paraphrase it.
class SafetyNotice extends StatelessWidget {
  /// Creates the standard safety disclaimer card.
  const SafetyNotice({super.key});

  /// Exact disclaimer text (also asserted by tests).
  static const text =
      'Preliminary guidance only. Stop in a safe place and seek assistance for '
      'overheating, oil-pressure warnings, braking/steering trouble, smoke, strong '
      'fuel smell, or a flashing check-engine light. Follow your owner’s manual. '
      'Set up and review diagnostics while parked. Performance recording is for '
      'a closed course with an operator handling the app.';

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.health_and_safety_outlined, color: AppColors.brandInk),
            SizedBox(width: AppSpacing.md),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}
