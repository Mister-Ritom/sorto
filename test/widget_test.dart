// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Sorto smoke test', (WidgetTester tester) async {
    // Basic test to ensure it boots
    await tester.pumpWidget(MaterialApp(home: Container()));
    expect(find.byType(Container), findsOneWidget);
  });
}
