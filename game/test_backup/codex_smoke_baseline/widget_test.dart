import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/main.dart';

void main() {
  testWidgets("Witch's Lab app builds", (WidgetTester tester) async {
    await tester.pumpWidget(const WitchLabApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text("WITCH'S LAB"), findsOneWidget);
  });
}
