import 'package:flutter/material.dart';

class SafetyNotice extends StatelessWidget {
  const SafetyNotice({super.key});
  @override
  Widget build(BuildContext context) => const Card(
        child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
                'Preliminary guidance only. Stop in a safe place and seek assistance for '
                'overheating, oil-pressure warnings, braking/steering trouble, smoke, strong '
                'fuel smell, or a flashing check-engine light. Follow your owner’s manual. '
                'Set up and review diagnostics while parked. Performance recording is for '
                'a closed course with an operator handling the app.')),
      );
}
