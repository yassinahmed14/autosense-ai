import 'dart:async';
import 'dart:math' as math;

import 'package:autosense_ai/core/theme/app_colors.dart';
import 'package:autosense_ai/core/theme/app_spacing.dart';
import 'package:autosense_ai/core/theme/app_typography.dart';
import 'package:autosense_ai/core/utils/formatters.dart';
import 'package:autosense_ai/features/dashboard/domain/performance_run_model.dart';
import 'package:autosense_ai/features/dashboard/domain/telemetry_model.dart';
import 'package:autosense_ai/features/scanner/data/mock_obd_adapter.dart';
import 'package:autosense_ai/features/scanner/domain/obd_adapter.dart';
import 'package:autosense_ai/shared/widgets/action_buttons.dart';
import 'package:autosense_ai/shared/widgets/metric_card.dart';
import 'package:autosense_ai/shared/widgets/page_layout.dart';
import 'package:autosense_ai/shared/widgets/section_header.dart';
import 'package:autosense_ai/shared/widgets/status_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Live telemetry dashboard with a motorsport RPM gauge, toggleable metric
/// cards, RPM trend chart, and automatic 10-second acceleration power estimator.
class DashboardScreen extends StatefulWidget {
  /// Creates a live dashboard screen.
  const DashboardScreen({
    super.key,
    required this.adapter,
    required this.simulated,
    this.alreadyConnected = false,
    this.disconnectOnDispose = true,
  });

  /// Live OBD adapter providing telemetry samples.
  final LiveObdAdapter adapter;

  /// Whether samples come from the demo simulator rather than a vehicle ECU.
  final bool simulated;

  /// True when [adapter] is already connected by a parent screen.
  final bool alreadyConnected;

  /// Whether to disconnect [adapter] when this screen disposes.
  final bool disconnectOnDispose;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  TelemetrySample? _latest;
  final _history = <TelemetrySample>[];
  final _runSamples = <TelemetrySample>[];
  final _mass = TextEditingController();
  final _runClock = Stopwatch();
  final _visible = <String>{'Speed', 'Coolant', 'Throttle'};
  Timer? _timer;
  Timer? _freshnessTimer;

  bool get _fresh =>
      _latest != null &&
      DateTime.now()
              .toUtc()
              .difference(_latest!.speedAt)
              .inMilliseconds
              .abs() <=
          2000;

  TelemetrySample? get _display => _fresh ? _latest : null;

  bool _stopped = false;
  bool _running = false;
  bool _confirmed = false;
  String _status = 'Connecting…';
  String? _runError;
  RunEstimate? _estimate;
  double? _runMass;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _freshnessTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _stopped || _latest == null || _fresh) return;
      setState(() {
        _status = 'Readings are stale. Waiting for fresh ECU data…';
        if (_running) {
          _timer?.cancel();
          _running = false;
          _runError = 'Recording stopped: live readings became stale.';
        }
      });
    });
    _poll();
  }

  Future<void> _poll() async {
    try {
      if (!widget.alreadyConnected) {
        final device = (await widget.adapter.discover()).single;
        if (_stopped) return;
        await widget.adapter.connect(device);
      }
      while (!_stopped) {
        final sample = await widget.adapter.readLiveData();
        if (_stopped || !mounted) break;
        if (sample.simulated != widget.simulated) {
          throw StateError('Unexpected data source.');
        }
        setState(() {
          _latest = sample;
          _history.add(sample);
          if (_history.length > 80) _history.removeAt(0);
          _status = widget.simulated
              ? 'Demo stream • simulated values'
              : 'Live ECU readings • experimental connection';
          if (_running && _runClock.elapsedMilliseconds <= 10000) {
            _runSamples.add(sample);
          }
        });
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
    } catch (error) {
      if (mounted && !_stopped) {
        setState(() {
          _status =
              'ECU read stopped: $error. Go back and retry with ignition on.';
          _latest = null;
          if (_running) {
            _runError = 'Recording interrupted. No estimate calculated.';
          }
          _running = false;
        });
      }
      _timer?.cancel();
      if (widget.disconnectOnDispose) await widget.adapter.disconnect();
    }
  }

  void _startRun() {
    final mass = double.tryParse(_mass.text.trim());
    if (mass == null || !mass.isFinite || mass < 300 || mass > 6000) {
      setState(() {
        _runError = 'Enter total car + occupants + cargo mass, 300–6000 kg.';
      });
      return;
    }
    if (_latest == null ||
        DateTime.now().toUtc().difference(_latest!.speedAt).inSeconds > 1) {
      setState(() => _runError = 'Wait for fresh speed and RPM data.');
      return;
    }
    final adapter = widget.adapter;
    if (adapter is MockObdAdapter) {
      adapter.beginDemoRun();
    }
    setState(() {
      _runSamples.clear();
      _runMass = mass;
      _estimate = null;
      _runError = null;
      _running = true;
      _runClock
        ..reset()
        ..start();
    });
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;
      if (_runClock.elapsedMilliseconds >= 10000) {
        _timer?.cancel();
        _runClock.stop();
        setState(() {
          _running = false;
          try {
            _estimate = estimateRun(_runSamples, _runMass!);
          } catch (error) {
            _runError = error.toString();
          }
        });
      } else {
        setState(() {});
      }
    });
  }

  void _abortRun() {
    _timer?.cancel();
    _runClock.stop();
    setState(() {
      _running = false;
      _runError = 'Recording cancelled. No estimate calculated.';
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _stopped = true;
      _timer?.cancel();
      unawaited(widget.adapter.disconnect());
      if (mounted) {
        setState(() {
          _latest = null;
          _running = false;
          _estimate = null;
          _runError = 'Recording stopped because the app left the foreground.';
          _status = 'Disconnected. Reopen the dashboard to reconnect.';
        });
      }
    }
  }

  @override
  void dispose() {
    _stopped = true;
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _freshnessTimer?.cancel();
    _mass.dispose();
    if (widget.disconnectOnDispose) unawaited(widget.adapter.disconnect());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Live dashboard')),
      body: PageListView(
        children: [
          Row(
            children: [
              Icon(
                Icons.circle,
                size: 10,
                color: _latest == null ? AppColors.caution : AppColors.success,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  _status,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xl,
              ),
              child: Center(
                child: SizedBox(
                  width: 300,
                  height: 220,
                  child: CustomPaint(
                    painter: _RpmGauge(_display?.rpm),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            formatReading(_display?.rpm),
                            style: AppTypography.gaugeValue,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'ENGINE RPM',
                            style: AppTypography.eyebrow.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            alignment: WrapAlignment.center,
            children: [
              if (_visible.contains('Speed'))
                MetricCard(
                  label: 'Speed',
                  value: formatReading(_display?.speedKph),
                  unit: 'km/h',
                  icon: Icons.speed,
                  accent: AppColors.brandYellow,
                ),
              if (_visible.contains('Coolant'))
                MetricCard(
                  label: 'Coolant',
                  value: formatReading(_display?.coolantC),
                  unit: '°C',
                  icon: Icons.thermostat,
                  accent: AppColors.caution,
                ),
              if (_visible.contains('Throttle'))
                MetricCard(
                  label: 'Throttle',
                  value: formatReading(_display?.throttlePercent),
                  unit: '%',
                  icon: Icons.tune,
                  accent: AppColors.info,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final name in ['Speed', 'Coolant', 'Throttle'])
                FilterChip(
                  label: Text(name),
                  selected: _visible.contains(name),
                  onSelected: (selected) => setState(() {
                    selected ? _visible.add(name) : _visible.remove(name);
                  }),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Unavailable readings show —. Absolute throttle position is not necessarily accelerator pedal position.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            height: 130,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.large,
              border: Border.all(color: AppColors.outline),
            ),
            child: CustomPaint(painter: _TrendPainter(List.of(_history))),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'RPM trend • latest readings',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          SectionHeader(
            '10-second performance run',
            eyebrow: 'TELEMETRY DYNO ESTIMATE',
            large: true,
            subtitle: widget.simulated
                ? 'SIMULATED RUN • Practice the complete recording flow.'
                : 'Record speed and RPM automatically; no horsepower or torque input needed.',
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _mass,
            enabled: !_running,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Total vehicle mass (kg)',
              helperText:
                  'Car + occupants + cargo. Weight affects every estimate.',
            ),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _confirmed,
            onChanged: _running
                ? null
                : (v) => setState(() => _confirmed = v ?? false),
            title: Text(
              widget.simulated
                  ? 'I understand this run uses simulated data.'
                  : 'Closed course, level surface, and safe test conditions confirmed.',
            ),
            subtitle: const Text(
              'Prepare while stationary. A passenger/operator handles the app; no phone interaction while driving. The app records a run—it does not control the throttle.',
            ),
          ),
          if (_running) ...[
            LinearProgressIndicator(
              value: (_runClock.elapsedMilliseconds / 10000).clamp(0, 1),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Recording • ${(10 - _runClock.elapsedMilliseconds / 1000).clamp(0, 10).toStringAsFixed(1)} s left • ${_runSamples.length} samples',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            SecondaryActionButton(
              label: 'Cancel recording',
              onPressed: _abortRun,
            ),
          ] else
            PrimaryActionButton(
              icon: Icons.fiber_manual_record,
              label: widget.simulated
                  ? 'Start 10-second demo run'
                  : 'Start 10-second recording',
              onPressed: _confirmed && _fresh && !_stopped ? _startRun : null,
            ),
          if (_runError != null) ...[
            const SizedBox(height: AppSpacing.sm),
            StatusBanner(_runError!, tone: BannerTone.warning),
          ],
          if (_estimate != null) ...[
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(
              _estimate!.simulated
                  ? 'SIMULATED estimate'
                  : 'Acceleration-based estimate',
            ),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                MetricCard(
                  label: 'Average acceleration',
                  value: _estimate!.averageHp.toStringAsFixed(1),
                  unit: 'hp',
                  icon: Icons.bolt,
                  accent: AppColors.brandYellow,
                ),
                MetricCard(
                  label: 'Peak ≥1 s window',
                  value: _estimate!.peakWindowHp.toStringAsFixed(1),
                  unit: 'hp',
                  icon: Icons.show_chart,
                  accent: AppColors.info,
                ),
                MetricCard(
                  label: 'RPM-referred equivalent',
                  value: _estimate!.equivalentTorqueNm.toStringAsFixed(1),
                  unit: 'N·m',
                  icon: Icons.rotate_right,
                  accent: AppColors.caution,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('${_estimate!.samples} samples • mass $_runMass kg'),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(
            'Method: change in ½mv² ÷ time. This is net translational acceleration power, not engine/crank horsepower or total wheel power. Equivalent torque uses engine RPM at the peak-power window; it is not measured engine or axle torque. Grade, wind, drag, rolling resistance, rotating inertia, shifts and wheel slip are not corrected. Full throttle alone cannot remove those uncertainties.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (_runSamples.isNotEmpty && !_running) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('Copy run data (CSV)'),
                onPressed: () async {
                  final lines = [
                    'mass_kg,$_runMass',
                    'speed_time_utc,rpm_time_utc,speed_kph,rpm,simulated',
                    for (final s in _runSamples)
                      '${s.speedAt.toIso8601String()},${s.rpmAt.toIso8601String()},${s.speedKph},${s.rpm},${s.simulated}',
                  ];
                  await Clipboard.setData(
                    ClipboardData(text: lines.join('\n')),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Run data copied.')),
                    );
                  }
                },
              ),
            ),
          ],
          Text(
            'Session data stays in memory and is cleared when this screen closes.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RpmGauge extends CustomPainter {
  const _RpmGauge(this.rpm);

  final double? rpm;

  static const _startAngle = math.pi * 0.75;
  static const _sweepAngle = math.pi * 1.5;
  static const _maxRpm = 8000.0;
  static const _redlineRpm = 6500.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 105.0;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..color = AppColors.gaugeTrack;
    canvas.drawArc(rect, _startAngle, _sweepAngle, false, trackPaint);

    // Subtle redline zone band on the outer rim (6500 - 8000 RPM).
    const redlineStartRatio = _redlineRpm / _maxRpm;
    final redlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.butt
      ..color = AppColors.gaugeRedline.withValues(alpha: 0.35);
    canvas.drawArc(
      rect,
      _startAngle + _sweepAngle * redlineStartRatio,
      _sweepAngle * (1 - redlineStartRatio),
      false,
      redlinePaint,
    );

    // Tick marks at every 1000 RPM.
    final tickPaint = Paint()
      ..strokeWidth = 2
      ..color = AppColors.outline;
    for (var k = 0; k <= 8; k++) {
      final angle = _startAngle + _sweepAngle * (k / 8);
      final inner = center + Offset(math.cos(angle), math.sin(angle)) * 84;
      final outer = center + Offset(math.cos(angle), math.sin(angle)) * 92;
      canvas.drawLine(
        inner,
        outer,
        tickPaint
          ..color = k >= 7 ? AppColors.gaugeRedline : AppColors.textSecondary,
      );
    }

    if (rpm != null) {
      final ratio = (rpm! / _maxRpm).clamp(0.0, 1.0);
      final activePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..color =
            rpm! >= _redlineRpm ? AppColors.gaugeRedline : AppColors.gaugeSweep;
      canvas.drawArc(
          rect, _startAngle, _sweepAngle * ratio, false, activePaint);
    }
  }

  @override
  bool shouldRepaint(_RpmGauge oldDelegate) => oldDelegate.rpm != rpm;
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter(this.samples);

  final List<TelemetrySample> samples;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = AppColors.chartGrid
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      canvas.drawLine(
        Offset(0, size.height * i / 4),
        Offset(size.width, size.height * i / 4),
        grid,
      );
    }
    if (samples.length < 2) return;
    final path = Path();
    final maxRpm = math.max(1000.0, samples.map((s) => s.rpm).reduce(math.max));
    for (var i = 0; i < samples.length; i++) {
      final x = size.width * i / (samples.length - 1);
      final y = size.height * (1 - samples[i].rpm / maxRpm);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.carbon
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(_TrendPainter oldDelegate) => true;
}
