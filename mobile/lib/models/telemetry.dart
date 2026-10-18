class TelemetrySample {
  const TelemetrySample(
      {required this.speedKph,
      required this.rpm,
      required this.speedAt,
      required this.rpmAt,
      required this.simulated,
      this.coolantC,
      this.throttlePercent});
  final double speedKph, rpm;
  final DateTime speedAt, rpmAt;
  final double? coolantC, throttlePercent;
  final bool simulated;
}
