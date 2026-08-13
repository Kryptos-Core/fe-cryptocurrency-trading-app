import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../domain/entities/conversation.dart';

class AiConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const AiConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  String _intentLabel() {
    switch (conversation.intent) {
      case AiConversationIntent.guide:
        return 'Hướng dẫn';
      case AiConversationIntent.market:
        return 'Thị trường';
      case AiConversationIntent.trading:
        return 'Giao dịch';
      case AiConversationIntent.rag:
        return 'Tài liệu';
      case AiConversationIntent.general:
        return 'Chung';
    }
  }

  String _subtitle() {
    final ts = conversation.lastMessageAt;
    if (ts == null) return 'Chưa có tin nhắn';
    final m = '${ts.month.toString().padLeft(2, '0')}/${ts.day.toString().padLeft(2, '0')} '
        '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';
    return '$m • ${conversation.messageCount} tin nhắn';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.smart_toy_outlined)),
      title: Text(
        conversation.title.isEmpty ? 'Cuộc hội thoại' : conversation.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(_subtitle()),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _intentLabel(),
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
      onTap: () {
        context.push(AppRoutes.aiAssistantChat(conversation.conversationId));
      },
    );
  }
}
