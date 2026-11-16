import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:demo/main.dart';

void main() {
  testWidgets('reviewer notes can open as flashcards', (
    WidgetTester tester,
  ) async {
    AuthService.init();
    await tester.pumpWidget(const MyApp());

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '1015140001');
    await tester.enterText(fields.at(1), '1234');
    await tester.tap(find.widgetWithText(ElevatedButton, 'LOGIN'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reviewer').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Derivative rules'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('STUDY'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Flashcards'));
    await tester.pumpAndSettle();

    expect(find.text('Card 1 of 3'), findsOneWidget);
    expect(find.text('Power rule'), findsOneWidget);
  });
}
