import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/di/injection_container.dart' as di;
import '../../application/providers/ai_assistant_provider.dart';
import '../../application/services/ai_assistant_socket_service.dart';
import '../../domain/repositories/ai_assistant_repository.dart';
import '../widgets/ai_chat_input.dart';
import '../widgets/ai_message_bubble.dart';

class AiChatScreen extends StatelessWidget {
  final String? conversationId;

  const AiChatScreen({super.key, this.conversationId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AiAssistantProvider>(
      create: (_) => AiAssistantProvider(
        repository: di.sl<AiAssistantRepository>(),
        socketService: di.sl<AiAssistantSocketService>(),
      )..loadStatus().._bootstrap(conversationId),
      child: _AiChatScreenBody(conversationId: conversationId),
    );
  }
}

extension on AiAssistantProvider {
  Future<void> _bootstrap(String? conversationId) async {
    if (conversationId == null) {
      await startNewConversation();
    } else {
      await openConversation(conversationId);
    }
  }
}

class _AiChatScreenBody extends StatefulWidget {
  final String? conversationId;
  const _AiChatScreenBody({this.conversationId});

  @override
  State<_AiChatScreenBody> createState() => _AiChatScreenBodyState();
}

class _AiChatScreenBodyState extends State<_AiChatScreenBody> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AiAssistantProvider>();
    final messages = provider.messages;
    final hasStreamingDelta = provider.streamingDelta.isNotEmpty;

    if (provider.messages.isNotEmpty || provider.isStreaming) {
      _scrollToBottom();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.activeConversation?.title ?? 'AI Assistant'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          if (provider.status != null && !provider.status!.enabled)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Theme.of(context).colorScheme.errorContainer,
              child: Text(
                'AI Assistant chưa được bật trên máy chủ.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: messages.length + (provider.isStreaming ? 1 : 0),
              itemBuilder: (context, i) {
                if (i < messages.length) {
                  return AiMessageBubble(message: messages[i]);
                }
                // Streaming assistant bubble
                return AiMessageBubble(
                  streamingDelta: hasStreamingDelta ? provider.streamingDelta : null,
                  isStreamingAssistant: true,
                );
              },
            ),
          ),
          if (provider.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Theme.of(context).colorScheme.errorContainer,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      provider.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.read<AiAssistantProvider>().loadStatus(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          AiChatInput(
            enabled: provider.status?.enabled ?? true,
            isStreaming: provider.isStreaming,
            onSend: (text) => provider.sendMessage(text),
            onStop: () => provider.stopStream(),
          ),
        ],
      ),
    );
  }
}
