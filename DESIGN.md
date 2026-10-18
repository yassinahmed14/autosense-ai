# DESIGN.md — AutoSense AI Design System ("Racing Yellow & Carbon")

> **Direction:** Light, modern, precision-engineered automotive diagnostics UI inspired by exotic supercar service bays (clean white/silver showroom floor, racing yellow brand fills, carbon-black typography and gauge tracks).

---

## 1. Brand Principles

1. **Showroom Clarity:** High-luminance white and light-silver surfaces (`#FFFFFF` / `#F6F7F9`) keep diagnostic information readable in bright daylight garages or outdoor driveways.
2. **Yellow as a Fill, Never as Text on White:** Racing yellow (`#FFC20E`) is reserved for **fills** (primary buttons, gauge sweeps, selected filter chips, focus rings, accent bars). For text, links, or small icons on a white surface, always use **Brand Ink (`#8A6100`)** or **Carbon (`#111317`)** to guarantee WCAG AA contrast ($\ge 4.5:1$).
3. **Orange for Caution:** Because yellow is the brand color, warnings and caution states use **Caution Orange (`#E06A00` / `#FFE9D6`)** so users never confuse brand highlights with warning alerts.
4. **Honest Telemetry:** Unavailable or stale readings display an em-dash (`—`), never a guessed zero. Simulated or demo streams always carry a prominent hazard-striped banner (`BannerTone.simulated`).

---

## 2. Color Palette & Tokens (`AppColors`)

Defined in [`app/lib/core/theme/app_colors.dart`](app/lib/core/theme/app_colors.dart). Never use raw `Color(0x...)` literals in feature screens—always reference `AppColors` or `Theme.of(context).colorScheme`.

| Token | Hex | Role & Usage |
|---|---|---|
| `AppColors.brandYellow` | `#FFC20E` | Primary button fill, active RPM sweep, selected chip fill, focus border, accent bar. **Fill only.** |
| `AppColors.onBrandYellow` | `#111317` | Carbon text/icons drawn on top of `brandYellow` (contrast $11.8:1$). |
| `AppColors.brandInk` | `#8A6100` | Yellow-family text, spec-sheet eyebrows, text buttons, and icons on white (contrast $5.4:1$). |
| `AppColors.primaryContainer` | `#FFF4CC` | Tinted brand well for metric card icons and simulated-data banners. |
| `AppColors.onPrimaryContainer` | `#3D2E00` | Text on `primaryContainer`. |
| `AppColors.carbon` | `#111317` | Primary text, headings, secondary button outlines, trend chart line, app bar icons. |
| `AppColors.carbonSoft` | `#1C1F24` | Unfilled RPM gauge track (`gaugeTrack`). |
| `AppColors.onCarbon` | `#FFFFFF` | Text on carbon surfaces (snackbars, dark badges). |
| `AppColors.info` / `infoContainer` | `#2F6FDE` / `#E3ECFC` | Informational banners, secondary chart/metric accents (Throttle). |
| `AppColors.caution` / `cautionContainer` | `#E06A00` / `#FFE9D6` | Warning banners, experimental transport notices, Coolant accent. |
| `AppColors.error` / `errorContainer` | `#C62828` / `#FDE2E1` | Urgent safety stops, validation errors, gauge redline ($6{,}500\text{–}8{,}000\text{ RPM}$). |
| `AppColors.success` / `successContainer` | `#1F8A4C` / `#DDF3E6` | Connected adapter indicator, verified state. |
| `AppColors.background` | `#F6F7F9` | Scaffold background (light silver). |
| `AppColors.surface` | `#FFFFFF` | Cards, app bar, dialogs, text fields. |
| `AppColors.surfaceContainer` | `#EEF0F3` | Empty states, subtle wells, disabled button fills. |
| `AppColors.outline` | `#D3D7DD` | $1\text{ px}$ card, input, chip, and app bar borders. |
| `AppColors.textPrimary` | `#111317` | Primary body and headline copy. |
| `AppColors.textSecondary` | `#5A616B` | Subtitles, units, helper text, captions. |

---

## 3. Typography (`AppTypography`)

Defined in [`app/lib/core/theme/app_typography.dart`](app/lib/core/theme/app_typography.dart) using bundled OFL fonts in `app/assets/fonts/` (zero runtime network fetches):

- **Display & Numeric (`Saira`, SemiBold 600 / Bold 700):** Technical motorsport geometry used for `displaySmall` ($36\text{ sp}$), `headlineMedium` ($28\text{ sp}$), `headlineSmall` ($24\text{ sp}$), `titleLarge` ($20\text{ sp}$), `AppTypography.gaugeValue` ($56\text{ sp}$ tabular figures), and `AppTypography.metricValue` ($30\text{ sp}$ tabular figures).
- **Body & Controls (`Inter`, Regular 400 / Medium 500 / SemiBold 600):** Clean legibility for diagnostic explanations, safety checklists, form inputs, and buttons.
- **Spec-Sheet Eyebrow (`AppTypography.eyebrow`):** $12\text{ sp}$, SemiBold, `letterSpacing: 2.0`, uppercase, colored `AppColors.brandInk`.

---

## 4. Spacing, Radii & Layout (`AppSpacing`, `AppRadius`)

Defined in [`app/lib/core/theme/app_spacing.dart`](app/lib/core/theme/app_spacing.dart):

- **4-pt Spacing Scale:** `xs = 4`, `sm = 8`, `md = 12`, `lg = 16`, `xl = 20` (default page padding), `xxl = 24`, `xxxl = 32`, `huge = 48`.
- **Corner Radii:**
  - `AppRadius.small` ($12\text{ dp}$): inputs, chips, status banners, icon wells.
  - `AppRadius.medium` ($16\text{ dp}$): primary and secondary action buttons.
  - `AppRadius.large` ($20\text{ dp}$): standard cards and metric cards.
  - `AppRadius.extraLarge` ($24\text{ dp}$): home hero card and modal dialogs.
- **Elevation & Borders:** Cards use `elevation: 0` with a crisp $1\text{ px}$ `AppColors.outline` border.
- **Touch Targets & Responsive Width:** Minimum interactive target is $48 \times 48\text{ dp}$ (`AppSpacing.minTouchTarget`); primary/secondary buttons are $52\text{ dp}$ tall (`AppSpacing.buttonHeight`). Scrollable pages use `PageListView`, which centers content within `maxContentWidth = 840` on tablets and desktops.

---

## 5. Signature Components

| Component | File | Visual Specification |
|---|---|---|
| `HomeHeroCard` | `lib/features/home/presentation/widgets/home_hero_card.dart` | White card with 16:9 studio supercar illustration (`assets/images/hero_car.png`), $4\text{ dp}$ racing-yellow divider bar, `AUTOSENSE / DRIVE INSIGHT` eyebrow, Saira display headline, and primary yellow CTA. Includes an icon fallback so widget tests run without asset bundles. |
| `StatusBanner` | `lib/shared/widgets/status_banner.dart` | Tonal container with icon + message. `BannerTone.simulated` renders a $6\text{ dp}$ left diagonal yellow-and-carbon hazard stripe (`_HazardStripePainter`) on `primaryContainer`. |
| `MetricCard` | `lib/shared/widgets/metric_card.dart` | $160\text{ dp}$ tile with tinted icon well, `AppTypography.metricValue` readout (or `—` when stale/missing), and `label • unit` caption. |
| `SectionHeader` | `lib/shared/widgets/section_header.dart` | Optional uppercase `eyebrow` in `brandInk`, Saira section title (`Semantics(header: true)`), optional subtitle and trailing action. |
| `PrimaryActionButton` / `SecondaryActionButton` | `lib/shared/widgets/action_buttons.dart` | Full-width $52\text{ dp}$ buttons. Primary = racing-yellow fill with carbon text; Secondary = white surface with $1.5\text{ px}$ carbon border. |
| `_RpmGauge` | `lib/features/dashboard/presentation/dashboard_screen.dart` | $270^\circ$ arc gauge with `carbonSoft` track, $1{,}000\text{ RPM}$ tick marks, redline band from $6{,}500\text{–}8{,}000\text{ RPM}$, and racing-yellow active sweep (turns red in redline). |

---

## 6. How to Add a New Screen

1. Place the screen under `app/lib/features/<feature>/presentation/<name>_screen.dart`.
2. Wrap scrollable body content in `PageListView` (`lib/shared/widgets/page_layout.dart`).
3. Use `SectionHeader`, `StatusBanner`, `MetricCard`, `PrimaryActionButton`, and `SecondaryActionButton` instead of ad-hoc containers.
4. Pull all colors from `AppColors` / `Theme.of(context).colorScheme` and all spacing from `AppSpacing`.
5. Register the route constant in `AppRoutes` (`lib/core/routing/app_router.dart`) and add a widget test under `app/test/features/<feature>/`.
