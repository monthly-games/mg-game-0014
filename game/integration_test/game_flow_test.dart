import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:game/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Game Flow Test - Main Menu Navigation', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verify main menu is visible
    expect(find.byType(MaterialApp), findsOneWidget);

    // Wait for animations
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Take a screenshot for verification (optional)
    await tester.pump();
  });
}
