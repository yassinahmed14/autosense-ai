import 'package:flutter/material.dart';
import '../models/diagnostic.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result});
  final DiagnosticResult result;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Diagnostic guidance')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          if (result.simulated)
            const Text('SIMULATED DATA • Not a vehicle scan',
                style: TextStyle(
                    color: Colors.deepOrange, fontWeight: FontWeight.bold)),
          Text(result.urgency.replaceAll('_', ' ').toUpperCase(),
              style: Theme.of(context).textTheme.headlineSmall),
          Text(result.summary),
          for (final reason in result.reasons)
            ListTile(
                leading: const Icon(Icons.info_outline), title: Text(reason)),
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(result.safetyMessage))),
          Text('Reported codes', style: Theme.of(context).textTheme.titleLarge),
          if (result.dtcs.isEmpty)
            const Text('No codes supplied. This does not rule out a fault.'),
          for (final dtc in result.dtcs)
            ListTile(
                title: Text('${dtc.code} • ${dtc.title ?? 'Unknown code'}'),
                subtitle: Text('${dtc.explanation ?? ''}\n${dtc.message}')),
          Text('Possible causes • unconfirmed',
              style: Theme.of(context).textTheme.titleLarge),
          if (result.causes.isEmpty)
            const Text(
                'Insufficient catalog evidence. Ask for professional review.'),
          for (final cause in result.causes)
            ListTile(
                title: Text(cause.title),
                subtitle: Text(
                    '${cause.certainty} • Evidence: ${cause.evidence.join(', ')}')),
          Text('Next steps', style: Theme.of(context).textTheme.titleLarge),
          for (final step in result.nextSteps)
            ListTile(leading: const Icon(Icons.checklist), title: Text(step)),
          ExpansionTile(
              title: const Text('Limitations and provenance'),
              children: [
                for (final limitation in result.limitations)
                  ListTile(title: Text(limitation)),
                ListTile(
                    title: Text(
                        'Result ${result.id}\n${result.createdAt.toLocal()}')),
              ]),
        ]),
      );
}
