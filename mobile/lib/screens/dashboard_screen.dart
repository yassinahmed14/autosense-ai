import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/telemetry.dart';
import '../models/performance_run.dart';
import '../services/obd_adapter.dart';
import '../services/mock_obd_adapter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen(
      {super.key,
      required this.adapter,
      required this.simulated,
      this.alreadyConnected = false,
      this.disconnectOnDispose = true});
  final LiveObdAdapter adapter;
  final bool simulated, alreadyConnected;
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
  bool _stopped = false, _running = false, _confirmed = false;
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
      setState(() =>
          _runError = 'Enter total car + occupants + cargo mass, 300–6000 kg.');
      return;
    }
    if (_latest == null ||
        DateTime.now().toUtc().difference(_latest!.speedAt).inSeconds > 1) {
      setState(() => _runError = 'Wait for fresh speed and RPM data.');
      return;
    }
    if (widget.adapter is MockObdAdapter) {
      (widget.adapter as MockObdAdapter).beginDemoRun();
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

  Widget _metric(String label, String value, String unit, IconData icon,
          Color color) =>
      Container(
          width: 150,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: const Color(0xff152334),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: color.withValues(alpha: 0.25))),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 12),
            Text(value,
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
            Text('$label • $unit',
                style: const TextStyle(color: Color(0xffa3b7cd))),
          ]));

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xff0b1420),
        appBar: AppBar(
            backgroundColor: const Color(0xff0b1420),
            title: const Text('Live dashboard')),
        body: Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView(padding: const EdgeInsets.all(22), children: [
                  Row(children: [
                    Icon(Icons.circle,
                        size: 10,
                        color: _latest == null
                            ? Colors.orange
                            : const Color(0xff4ce0b3)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_status))
                  ]),
                  const SizedBox(height: 22),
                  Center(
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
                                        _display?.rpm.toStringAsFixed(0) ?? '—',
                                        style: const TextStyle(
                                            fontSize: 62,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: -2)),
                                    const Text('ENGINE RPM',
                                        style: TextStyle(
                                            color: Color(0xffa3b7cd),
                                            letterSpacing: 3)),
                                  ]))))),
                  Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        if (_visible.contains('Speed'))
                          _metric(
                              'Speed',
                              _display?.speedKph.toStringAsFixed(0) ?? '—',
                              'km/h',
                              Icons.speed,
                              const Color(0xff4ce0b3)),
                        if (_visible.contains('Coolant'))
                          _metric(
                              'Coolant',
                              _display?.coolantC?.toStringAsFixed(0) ?? '—',
                              '°C',
                              Icons.thermostat,
                              const Color(0xffffbd69)),
                        if (_visible.contains('Throttle'))
                          _metric(
                              'Throttle',
                              _display?.throttlePercent?.toStringAsFixed(0) ??
                                  '—',
                              '%',
                              Icons.tune,
                              const Color(0xff91a7ff)),
                      ]),
                  const SizedBox(height: 18),
                  Wrap(spacing: 8, children: [
                    for (final name in ['Speed', 'Coolant', 'Throttle'])
                      FilterChip(
                          label: Text(name),
                          selected: _visible.contains(name),
                          onSelected: (selected) => setState(() {
                                selected
                                    ? _visible.add(name)
                                    : _visible.remove(name);
                              }))
                  ]),
                  const Text(
                      'Unavailable readings show —. Absolute throttle position is not necessarily accelerator pedal position.',
                      style: TextStyle(color: Color(0xffa3b7cd))),
                  const SizedBox(height: 18),
                  Container(
                      height: 130,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: const Color(0xff152334),
                          borderRadius: BorderRadius.circular(18)),
                      child: CustomPaint(
                          painter: _TrendPainter(List.of(_history)))),
                  const Text('RPM trend • latest readings',
                      style: TextStyle(color: Color(0xffa3b7cd))),
                  const SizedBox(height: 28),
                  const Text('10-second performance run',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  Text(widget.simulated
                      ? 'SIMULATED RUN • Practice the complete recording flow.'
                      : 'Record speed and RPM automatically; no horsepower or torque input needed.'),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _mass,
                      enabled: !_running,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                          labelText: 'Total vehicle mass (kg)',
                          helperText:
                              'Car + occupants + cargo. Weight affects every estimate.')),
                  CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _confirmed,
                      onChanged: _running
                          ? null
                          : (v) => setState(() => _confirmed = v ?? false),
                      title: Text(widget.simulated
                          ? 'I understand this run uses simulated data.'
                          : 'Closed course, level surface, and safe test conditions confirmed.'),
                      subtitle: const Text(
                          'Prepare while stationary. A passenger/operator handles the app; no phone interaction while driving. The app records a run—it does not control the throttle.')),
                  if (_running) ...[
                    LinearProgressIndicator(
                        value: (_runClock.elapsedMilliseconds / 10000)
                            .clamp(0, 1)),
                    Text(
                        'Recording • ${(10 - _runClock.elapsedMilliseconds / 1000).clamp(0, 10).toStringAsFixed(1)} s left • ${_runSamples.length} samples',
                        style: const TextStyle(fontSize: 22)),
                    OutlinedButton(
                        onPressed: _abortRun,
                        child: const Text('Cancel recording')),
                  ] else
                    FilledButton.icon(
                        icon: const Icon(Icons.fiber_manual_record),
                        onPressed: _confirmed && _fresh && !_stopped
                            ? _startRun
                            : null,
                        label: Text(widget.simulated
                            ? 'Start 10-second demo run'
                            : 'Start 10-second recording')),
                  if (_runError != null)
                    Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(_runError!,
                            style: const TextStyle(color: Color(0xffffbd69)))),
                  if (_estimate != null) ...[
                    const SizedBox(height: 16),
                    Text(
                        _estimate!.simulated
                            ? 'SIMULATED estimate'
                            : 'Acceleration-based estimate',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    Wrap(spacing: 12, runSpacing: 12, children: [
                      _metric(
                          'Average acceleration',
                          _estimate!.averageHp.toStringAsFixed(1),
                          'hp',
                          Icons.bolt,
                          const Color(0xff4ce0b3)),
                      _metric(
                          'Peak ≥1 s window',
                          _estimate!.peakWindowHp.toStringAsFixed(1),
                          'hp',
                          Icons.show_chart,
                          const Color(0xff91a7ff)),
                      _metric(
                          'RPM-referred equivalent',
                          _estimate!.equivalentTorqueNm.toStringAsFixed(1),
                          'N·m',
                          Icons.rotate_right,
                          const Color(0xffffbd69)),
                    ]),
                    Text('${_estimate!.samples} samples • mass $_runMass kg'),
                  ],
                  const SizedBox(height: 12),
                  const Text(
                      'Method: change in ½mv² ÷ time. This is net translational acceleration power, not engine/crank horsepower or total wheel power. Equivalent torque uses engine RPM at the peak-power window; it is not measured engine or axle torque. Grade, wind, drag, rolling resistance, rotating inertia, shifts and wheel slip are not corrected. Full throttle alone cannot remove those uncertainties.',
                      style: TextStyle(color: Color(0xffa3b7cd))),
                  if (_runSamples.isNotEmpty && !_running)
                    TextButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text('Copy run data (CSV)'),
                        onPressed: () async {
                          final lines = [
                            'mass_kg,$_runMass',
                            'speed_time_utc,rpm_time_utc,speed_kph,rpm,simulated',
                            for (final s in _runSamples)
                              '${s.speedAt.toIso8601String()},${s.rpmAt.toIso8601String()},${s.speedKph},${s.rpm},${s.simulated}'
                          ];
                          await Clipboard.setData(
                              ClipboardData(text: lines.join('\n')));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Run data copied.')));
                          }
                        }),
                  const Text(
                      'Session data stays in memory and is cleared when this screen closes.',
                      style: TextStyle(color: Color(0xffa3b7cd))),
                ]))),
      );
}

class _RpmGauge extends CustomPainter {
  _RpmGauge(this.rpm);
  final double? rpm;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: 230,
        height: 230);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, math.pi * 0.75, math.pi * 1.5, false,
        paint..color = const Color(0xff223449));
    if (rpm != null) {
      canvas.drawArc(
          rect,
          math.pi * 0.75,
          math.pi * 1.5 * (rpm! / 8000).clamp(0, 1),
          false,
          paint
            ..shader = const SweepGradient(colors: [
              Color(0xff4ce0b3),
              Color(0xff91a7ff),
              Color(0xffffbd69)
            ]).createShader(rect));
    }
  }

  @override
  bool shouldRepaint(_RpmGauge oldDelegate) => oldDelegate.rpm != rpm;
}

class _TrendPainter extends CustomPainter {
  _TrendPainter(this.samples);
  final List<TelemetrySample> samples;
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xff25374b)
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      canvas.drawLine(Offset(0, size.height * i / 4),
          Offset(size.width, size.height * i / 4), grid);
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
          ..color = const Color(0xff4ce0b3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5);
  }

  @override
  bool shouldRepaint(_TrendPainter oldDelegate) => true;
}
