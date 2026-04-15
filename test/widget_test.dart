// Test: App smoke test | Author: Piyush Puri | Date: 15 Apr 2026
// Verifies EmotracApp initializes and renders without crashing.
// Full integration tests require a real database — skipped here.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:emotrace/main.dart';

void main() {
  testWidgets('EmotracApp renders without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EmotracApp());

    // App shell renders (providers + MaterialApp)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
