import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/di/injection_container.dart' as di;
import '../../../../app/router/app_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
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
    // Defensive auth guard: the floating button already redirects guests
    // to the login screen, but a deep-link / pasted URL / programmatic
    // push could still mount this route for an unauthenticated user.
    // Send them to the login screen instead of rendering an empty list.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      if (!auth.isAuthenticated) {
        context.go(AppRoutes.login);
        return;
      }
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

  Future<void> _openChat(BuildContext context, String route) async {
    await context.push(route);
    if (!context.mounted) return;
    // AiAssistantScreen is preserved on the back stack while AiChatScreen is
    // on top. Its initState() does NOT re-run when we pop back here, so the
    // provider's conversations list may not include the chat we just
    // finished (the chat:done handler triggers an async loadConversations,
    // but its notifyListeners can land between frames or be coalesced).
    // Re-fetch on every pop to guarantee the new/updated conversation
    // appears at the top of the list immediately.
    final provider = di.sl<AiAssistantProvider>();
    await provider.loadConversations();
    await provider.loadStatus();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AiAssistantProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
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
                  onTap: () => _openChat(
                    context,
                    AppRoutes.aiAssistantChat(conv.conversationId),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'ai-assistant-new-fab',
        onPressed: () => _openChat(context, AppRoutes.aiAssistantChatNew),
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text('Hỏi AI'),
      ),
    );
  }
}
