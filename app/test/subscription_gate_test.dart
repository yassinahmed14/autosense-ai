import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autosense_ai/main.dart';
import 'package:autosense_ai/services/subscription_controller.dart';

void main() {
  testWidgets('billing-enabled build blocks app access when unverified',
      (tester) async {
    await tester.pumpWidget(const AutoSenseApp());
    await tester.pumpAndSettle();
    expect(find.text('One membership. Full app access.'), findsOneWidget);
    expect(find.text('Open live dashboard').hitTestable(), findsNothing);
    expect(find.text('Start 3-day trial'), findsNothing);
    await tester.scrollUntilVisible(find.text('Privacy & support'), 250,
        scrollable: find.byType(Scrollable).last);
    await tester.tap(find.text('Privacy & support'));
    await tester.pumpAndSettle();
    expect(find.text('Privacy & app information'), findsOneWidget);
  }, skip: !SubscriptionController.enabled);
}
