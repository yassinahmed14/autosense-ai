import 'package:autosense_ai/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Standard scrollable page body: centred, width-capped [ListView] with the
/// default page padding. Contains exactly one [Scrollable].
class PageListView extends StatelessWidget {
  /// Creates a page list view.
  const PageListView({
    super.key,
    required this.children,
    this.maxWidth = AppSpacing.maxContentWidth,
    this.padding = AppSpacing.page,
  });

  /// Page content, top to bottom.
  final List<Widget> children;

  /// Maximum content width.
  final double maxWidth;

  /// Outer padding.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: ListView(padding: padding, children: children),
        ),
      );
}

/// Tappable card with an icon well, title, description and chevron.
/// Used for navigation choices such as the connection hub options.
class NavigationCard extends StatelessWidget {
  /// Creates a navigation card.
  const NavigationCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  /// Leading icon.
  final IconData icon;

  /// Bold title.
  final String title;

  /// Supporting description.
  final String description;

  /// Tap handler.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: AppRadius.small,
          ),
          child: Icon(icon, color: scheme.onPrimaryContainer),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }
}

/// Large circular icon well used at the top of task screens.
class HeaderIcon extends StatelessWidget {
  /// Creates a header icon.
  const HeaderIcon(this.icon, {super.key, this.color, this.background});

  /// Icon to show.
  final IconData icon;

  /// Icon colour; defaults to `onPrimaryContainer`.
  final Color? color;

  /// Well colour; defaults to `primaryContainer`.
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: background ?? scheme.primaryContainer,
          borderRadius: AppRadius.medium,
        ),
        child: Icon(icon, size: 32, color: color ?? scheme.onPrimaryContainer),
      ),
    );
  }
}
