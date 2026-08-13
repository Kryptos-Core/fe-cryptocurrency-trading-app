import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crypto_trading_app/features/ai_assistant/presentation/widgets/ai_chat_input.dart';

void main() {
  testWidgets('disables input when not enabled', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AiChatInput(
          enabled: false,
          isStreaming: false,
          onSend: (_) async {},
          onStop: () {},
        ),
      ),
    ));

    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);
    final tf = tester.widget<TextField>(textField);
    expect(tf.enabled, isFalse);
  });

  testWidgets('shows stop icon while streaming', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AiChatInput(
          enabled: true,
          isStreaming: true,
          onSend: (_) async {},
          onStop: () {},
        ),
      ),
    ));

    expect(find.byKey(const ValueKey('ai-chat-stop')), findsOneWidget);
    expect(find.byKey(const ValueKey('ai-chat-send')), findsNothing);
  });

  testWidgets('sends text and clears input when user taps send', (tester) async {
    String? sentText;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AiChatInput(
          enabled: true,
          isStreaming: false,
          onSend: (t) async => sentText = t,
          onStop: () {},
        ),
      ),
    ));

    await tester.enterText(find.byType(TextField), 'Hello AI');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('ai-chat-send')));
    await tester.pump();

    expect(sentText, 'Hello AI');
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, isEmpty);
  });
}