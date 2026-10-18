import 'package:autosense_ai/core/theme/app_colors.dart';
import 'package:autosense_ai/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Visual tone of a [StatusBanner].
enum BannerTone {
  /// Neutral information (steel-blue info container).
  info,

  /// Positive confirmation (success container).
  success,

  /// Caution / experimental (orange caution container).
  warning,

  /// Simulated or demo data (primary container + left hazard stripe).
  simulated,

  /// Error or urgent safety instruction (error container).
  error,
}

/// Inline, non-dismissible banner for status, caution and simulated-data
/// labels. Text is rendered verbatim so labels stay testable.
class StatusBanner extends StatelessWidget {
  /// Creates a status banner.
  const StatusBanner(
    this.message, {
    super.key,
    this.tone = BannerTone.info,
    this.icon,
    this.emphasize = false,
  });

  /// Banner text (rendered as a single [Text]).
  final String message;

  /// Colour / icon treatment.
  final BannerTone tone;

  /// Overrides the tone's default icon.
  final IconData? icon;

  /// Renders the message in bold.
  final bool emphasize;

  (Color, Color, IconData) _style() => switch (tone) {
        BannerTone.info => (
            AppColors.infoContainer,
            AppColors.onInfoContainer,
            Icons.info_outline,
          ),
        BannerTone.success => (
            AppColors.successContainer,
            AppColors.onSuccessContainer,
            Icons.check_circle_outline,
          ),
        BannerTone.warning => (
            AppColors.cautionContainer,
            AppColors.onCautionContainer,
            Icons.warning_amber_rounded,
          ),
        BannerTone.simulated => (
            AppColors.primaryContainer,
            AppColors.carbon,
            Icons.science_outlined,
          ),
        BannerTone.error => (
            AppColors.errorContainer,
            AppColors.onErrorContainer,
            Icons.error_outline,
          ),
      };

  @override
  Widget build(BuildContext context) {
    final (background, foreground, defaultIcon) = _style();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.small,
        border: Border.all(color: foreground.withValues(alpha: 0.18)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (tone == BannerTone.simulated)
              const SizedBox(
                width: 6,
                child: CustomPaint(painter: _HazardStripePainter()),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon ?? defaultIcon, color: foreground, size: 20),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: foreground,
                              fontWeight: emphasize ? FontWeight.w700 : null,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HazardStripePainter extends CustomPainter {
  const _HazardStripePainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.brandYellow,
    );
    final stripe = Paint()
      ..color = AppColors.carbon
      ..strokeWidth = 3;
    for (double y = -size.width; y < size.height + size.width; y += 8) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y - size.width), stripe);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
