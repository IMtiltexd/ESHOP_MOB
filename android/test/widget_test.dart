import 'package:flut/MainScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flut/main.dart'; // Импортируйте ваш основной файл

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Передаем startScreen в MyApp
    await tester.pumpWidget(MyApp(startScreen: MainScreen())); // Здесь передаем нужный экран

    // Вероятно, ваш тест выполняет действия с виджетами, например, с кнопкой
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
