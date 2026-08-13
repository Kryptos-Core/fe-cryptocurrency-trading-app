import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crypto_trading_app/features/ai_assistant/domain/entities/conversation.dart';
import 'package:crypto_trading_app/features/ai_assistant/presentation/widgets/ai_conversation_tile.dart';

void main() {
  testWidgets('renders title, intent badge, and metadata subtitle', (tester) async {
    final conv = Conversation(
      conversationId: 'c1',
      userId: 'u1',
      title: 'Câu hỏi BTC',
      intent: AiConversationIntent.market,
      lastMessageAt: DateTime(2026, 8, 13, 10, 30),
      messageCount: 3,
      totalTokensIn: 0,
      totalTokensOut: 0,
      deletedAt: null,
      createdAt: DateTime(2026, 8, 13),
      updatedAt: DateTime(2026, 8, 13),
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: AiConversationTile(conversation: conv, onTap: () {})),
    ));

    expect(find.text('Câu hỏi BTC'), findsOneWidget);
    expect(find.text('Thị trường'), findsOneWidget); // intent label
    expect(find.textContaining('3 tin nhắn'), findsOneWidget);
  });

  testWidgets('falls back to default title and label when empty intent', (tester) async {
    final conv = Conversation(
      conversationId: 'c1',
      userId: 'u1',
      title: '',
      intent: AiConversationIntent.general,
      lastMessageAt: null,
      messageCount: 0,
      totalTokensIn: 0,
      totalTokensOut: 0,
      deletedAt: null,
      createdAt: DateTime(2026, 8, 13),
      updatedAt: DateTime(2026, 8, 13),
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: AiConversationTile(conversation: conv, onTap: () {})),
    ));

    expect(find.text('Cuộc hội thoại'), findsOneWidget);
    expect(find.text('Chung'), findsOneWidget);
    expect(find.text('Chưa có tin nhắn'), findsOneWidget);
  });
}