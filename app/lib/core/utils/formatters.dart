/// Placeholder shown for unavailable, stale or not-yet-received readings.
const missingValue = '—';

/// Formats [value] with [fractionDigits], or [missingValue] when null.
String formatReading(num? value, {int fractionDigits = 0}) =>
    value == null ? missingValue : value.toStringAsFixed(fractionDigits);

/// Human-readable urgency label, e.g. `see_soon` → `see soon`.
String formatUrgency(String urgency) => urgency.replaceAll('_', ' ');
