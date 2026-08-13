import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crypto_trading_app/features/ai_assistant/domain/entities/message.dart';
import 'package:crypto_trading_app/features/ai_assistant/presentation/widgets/ai_message_bubble.dart';

Message _make({
  required String content,
  MessageRole role = MessageRole.assistant,
}) {
  return Message(
    messageId: '1',
    conversationId: 'c1',
    role: role,
    content: content,
    model: null,
    tokensIn: 0,
    tokensOut: 0,
    toolCalls: null,
    contextRefs: null,
    parentMessageId: null,
    createdAt: DateTime(2026, 1, 1),
  );
}

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
}

void main() {
  group('AiMessageBubble', () {
    testWidgets('renders assistant text', (tester) async {
      await _pump(
        tester,
        AiMessageBubble(message: _make(content: 'Xin chào')),
      );
      expect(find.text('Xin chào'), findsOneWidget);
    });

    testWidgets('renders user text aligned to end', (tester) async {
      await _pump(
        tester,
        AiMessageBubble(message: _make(content: 'Hi', role: MessageRole.user)),
      );
      expect(find.text('Hi'), findsOneWidget);
    });

    testWidgets('shows typing indicator when streaming assistant and delta is empty',
        (tester) async {
      await _pump(
        tester,
        const AiMessageBubble(
          streamingDelta: '',
          isStreamingAssistant: true,
        ),
      );
      // The streaming indicator renders dots; the text widget for content
      // should not be present (delta is empty).
      expect(find.byKey(const ValueKey('ai-message-content')), findsNothing);
      // At least three dot characters should be rendered by the indicator.
      expect(find.text('•'), findsWidgets);
    });

    testWidgets('appends streaming delta text', (tester) async {
      await _pump(
        tester,
        const AiMessageBubble(
          streamingDelta: 'Hello',
          isStreamingAssistant: true,
        ),
      );
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('throws assertion when both message and delta are null', (tester) async {
      expect(
        () => AiMessageBubble(),
        throwsAssertionError,
      );
    });
  });
}