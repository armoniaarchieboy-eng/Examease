import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:demo/main.dart';

void main() {
  testWidgets('demo student can sign in', (WidgetTester tester) async {
    AuthService.init();
    await tester.pumpWidget(const MyApp());

    expect(find.text('Student login'), findsOneWidget);
    expect(find.text('ID: 1015140001  |  Password: 1234'), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '1015140001');
    await tester.enterText(fields.at(1), '1234');

    final loginButton = find.widgetWithText(ElevatedButton, 'LOGIN');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('Hi, Juan! 👋'), findsOneWidget);
    expect(find.byTooltip('Ask AI'), findsOneWidget);

    await tester.tap(find.byTooltip('Ask AI'));
    await tester.pumpAndSettle();

    expect(find.text('ExamEase AI'), findsOneWidget);
    expect(find.text('Hi! Unsa ang i-review nato?'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'Explain derivatives');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('AI is not configured. Set ANTHROPIC_API_KEY'),
      findsOneWidget,
    );
  });
}
