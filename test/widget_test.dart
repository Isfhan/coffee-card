import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coffee_card/main.dart';

void main() {
  testWidgets('Coffee Card app loads home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CoffeeCardApp());

    expect(find.text('Coffee Card'), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsWidgets);
    expect(find.text('Home'), findsOneWidget);
  });
}
