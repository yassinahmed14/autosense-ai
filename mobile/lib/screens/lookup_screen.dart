import 'package:flutter/material.dart';
import '../models/diagnostic.dart';
import '../services/api_client.dart';

class LookupScreen extends StatefulWidget {
  const LookupScreen({super.key, required this.api});
  final ApiClient api;
  @override
  State<LookupScreen> createState() => _LookupScreenState();
}

class _LookupScreenState extends State<LookupScreen> {
  final _code = TextEditingController();
  DtcLookup? _result;
  String? _error;
  bool _busy = false;
  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _lookup() async {
    setState(() {
      _error = null;
      _result = null;
    });
    try {
      final codes = parseCodes(_code.text);
      if (codes.length != 1) {
        throw const FormatException('Enter exactly one DTC.');
      }
      setState(() => _busy = true);
      final result = await widget.api.lookup(codes.single);
      if (mounted) setState(() => _result = result);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('DTC library')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          const Text(
              'Eight generic demo definitions. OEM details may differ. A code alone does not identify a failed part.'),
          TextField(
              controller: _code,
              textCapitalization: TextCapitalization.characters,
              decoration:
                  const InputDecoration(labelText: 'DTC', hintText: 'P0420')),
          FilledButton(
              onPressed: _busy ? null : _lookup,
              child: Text(_busy ? 'Looking up…' : 'Look up code')),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red)),
          if (_result != null)
            Card(
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '${_result!.code}: ${_result!.title ?? 'Not in catalog'}',
                            style: Theme.of(context).textTheme.titleLarge),
                        if (_result!.explanation != null)
                          Text(_result!.explanation!),
                        Text(_result!.message),
                      ],
                    ))),
        ]),
      );
}
