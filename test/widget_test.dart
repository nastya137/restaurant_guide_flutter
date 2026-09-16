import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project/main.dart';

void main() {
  testWidgets('registration screen uses the redesigned entry experience', (
    tester,
  ) async {
    dotenv.testLoad(fileInput: 'BASE_URL=http://localhost:3000');

    await tester.pumpWidget(const RestaurantGuideApp());
    await tester.pumpAndSettle();

    expect(find.text('Ваш столик уже\nгде-то ждёт'), findsOneWidget);
    expect(find.text('Давайте знакомиться'), findsOneWidget);
    expect(find.text('Найти ресторан'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.byIcon(Icons.restaurant_menu_rounded), findsOneWidget);
  });
}
