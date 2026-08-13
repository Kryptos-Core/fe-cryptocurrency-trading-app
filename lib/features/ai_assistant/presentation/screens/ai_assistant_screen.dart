import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/di/injection_container.dart' as di;
import '../../../../app/router/app_routes.dart';
import '../../application/providers/ai_assistant_provider.dart';
import '../widgets/ai_conversation_tile.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  late final AiAssistantProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = di.sl<AiAssistantProvider>();
    // Defer to after first frame to avoid calling setState during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadConversations();
      _provider.loadStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AiAssistantProvider>.value(
      value: _provider,
      child: const _AiAssistantScreenBody(),
    );
  }
}

class _AiAssistantScreenBody extends StatelessWidget {
  const _AiAssistantScreenBody();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AiAssistantProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        actions: [
          if (provider.status != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: Text(
                  'Còn ${provider.status!.dailyRemainingTokens} tokens',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await provider.loadConversations();
          await provider.loadStatus();
        },
        child: Builder(
          builder: (context) {
            if (provider.isLoadingConversations && provider.conversations.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.conversationsError != null && provider.conversations.isEmpty) {
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Lỗi: ${provider.conversationsError}'),
                  ),
                ],
              );
            }
            if (provider.conversations.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 80),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Chưa có cuộc hội thoại nào.\nNhấn + để bắt đầu.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              itemCount: provider.conversations.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final conv = provider.conversations[i];
                return AiConversationTile(
                  conversation: conv,
                  onTap: () => context.push(AppRoutes.aiAssistantChat(conv.conversationId)),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'ai-assistant-new-fab',
        onPressed: () => context.push(AppRoutes.aiAssistantChatNew),
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text('Hỏi AI'),
      ),
    );
  }
}
