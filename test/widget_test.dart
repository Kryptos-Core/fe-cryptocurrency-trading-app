import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_trading_app/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen has a title and a message', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    final titleFinder = find.text('Crypto Trading App');
    final messageFinder = find.text('Welcome to the Crypto Trading App!');

    expect(titleFinder, findsOneWidget);
    expect(messageFinder, findsOneWidget);
  });
}