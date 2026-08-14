import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/di/injection_container.dart' as di;
import '../../application/providers/ai_assistant_provider.dart';
import '../widgets/ai_chat_input.dart';
import '../widgets/ai_message_bubble.dart';

class AiChatScreen extends StatefulWidget {
  final String? conversationId;

  const AiChatScreen({super.key, this.conversationId});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  late final AiAssistantProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = di.sl<AiAssistantProvider>();
    // Wait for socket auth before loading to avoid race conditions with
    // _ensureSocketConnected() in the provider constructor.
    _loadAfterSocketAuth();
  }

  Future<void> _loadAfterSocketAuth() async {
    final socketService = _provider.socketService;
    // Poll up to 5s for socket auth (from _ensureSocketConnected).
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (!socketService.isAuthenticated && DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (!mounted) return;
    _provider.loadStatus();
    if (widget.conversationId == null) {
      _provider.startNewConversation();
    } else {
      _provider.openConversation(widget.conversationId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AiAssistantProvider>.value(
      value: _provider,
      child: _AiChatScreenBody(conversationId: widget.conversationId),
    );
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

  /// Scroll offset (from the bottom) within which we ignore "user is at top"
  /// signals so the typing-indicator bubble + auto-scroll don't accidentally
  /// trip the older-page loader.
  static const double _bottomAnchorSlack = 96;

  /// Distance from the top of the (reversed) list at which we kick off an
  /// older-page fetch. Same 20% threshold convention used by the markets
  /// tab — wide enough that fast scroll gestures always trigger the load.
  static const double _topLoadThreshold = 0.2;

  /// Minimum scroll extent below which we consider the list "not yet
  /// scrollable" — mirrors the markets/currencies tabs so first-load with a
  /// short message history still feels snappy.
  static const double _minScrollExtentToSkipPrefetch = 48;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final provider = context.read<AiAssistantProvider>();
    if (provider.isLoadingMessages) return;
    if (!provider.hasMoreOlder) return;

    final position = _scrollController.position;
    // Reverse list: pixels == 0 is the bottom (newest). When the user
    // scrolls up, pixels grows toward maxScrollExtent (oldest).
    if (position.maxScrollExtent <= 0) {
      // List isn't yet scrollable — handle the prefetch loop in
      // _maybePrefetchOlderIfListShort.
      _maybePrefetchOlderIfListShort(provider);
      return;
    }
    final distanceFromTop = position.maxScrollExtent - position.pixels;
    if (distanceFromTop <= position.maxScrollExtent * _topLoadThreshold) {
      // ignore: discarded_futures
      provider.loadOlderMessages();
    }
  }

  Future<void> _maybePrefetchOlderIfListShort(AiAssistantProvider provider) async {
    // If the loaded page is shorter than the viewport the user cannot
    // scroll, so the scroll listener never fires. Poll the server until
    // either the list overflows or we run out of older pages.
    if (!provider.hasMoreOlder || provider.isLoadingMessages) return;
    if (!_scrollController.hasClients) return;
    final maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent >= _minScrollExtentToSkipPrefetch) return;
    await provider.loadOlderMessages();
    if (!mounted) return;
    if (provider.hasMoreOlder && !provider.isLoadingMessages) {
      _maybePrefetchOlderIfListShort(provider);
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    // Reverse list: pixels == 0 is the bottom. If the user is already
    // pinned to the bottom, don't fight their scroll position.
    final position = _scrollController.position;
    if (position.pixels <= _bottomAnchorSlack) {
      _scrollController.jumpTo(0);
      return;
    }
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AiAssistantProvider>();
    final messages = provider.messages;
    final hasStreamingDelta = provider.streamingDelta.isNotEmpty;
    final showStreamingBubble = provider.isStreaming;
    final conversationId = widget.conversationId;

    // Auto-scroll to bottom on new content, but only when the user is
    // already pinned to the bottom (or there is no scroll history yet).
    // This is what keeps the existing UX: new tokens slide into view, but
    // the user can scroll up to read older history without being yanked
    // back down every frame.
    final isPinnedToBottom = !_scrollController.hasClients ||
        _scrollController.position.pixels <= _bottomAnchorSlack;
    if ((messages.isNotEmpty || showStreamingBubble) && isPinnedToBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _scrollToBottom();
      });
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
            child: messages.isEmpty && !showStreamingBubble
                ? _EmptyConversationView(conversationId: conversationId)
                : _AiMessagesList(
                    controller: _scrollController,
                    messages: messages,
                    hasStreamingDelta: hasStreamingDelta,
                    showStreamingBubble: showStreamingBubble,
                    isLoadingOlder: provider.isLoadingMessages,
                    hasMoreOlder: provider.hasMoreOlder,
                    onLoadOlder: provider.loadOlderMessages,
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

/// Empty-state shown while waiting for the first message of a new (or
/// freshly opened, empty) conversation to land.
class _EmptyConversationView extends StatelessWidget {
  final String? conversationId;

  const _EmptyConversationView({required this.conversationId});

  @override
  Widget build(BuildContext context) {
    final isNew = conversationId == null;
    return ListView(
      // Reverse + non-scrollable body — gives us a stable bottom anchor
      // and lets the user still pull-to-refresh.
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              Icon(
                isNew ? Icons.chat_bubble_outline : Icons.history,
                size: 56,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                isNew
                    ? 'Bắt đầu cuộc hội thoại mới'
                    : 'Cuộc hội thoại này chưa có tin nhắn nào',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                isNew
                    ? 'Hỏi giá coin, cách đặt lệnh, hoặc bất kỳ câu hỏi nào về ứng dụng.'
                    : 'Hãy gửi tin nhắn đầu tiên bên dưới.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Reverse-list view with a top "load older" indicator and explicit older-page
/// trigger callback. Kept separate from [AiChatScreen] so the scroll controller
/// can listen to lifecycle events without rebuilding the whole chat tree.
class _AiMessagesList extends StatelessWidget {
  final ScrollController controller;
  final List<dynamic> messages;
  final bool hasStreamingDelta;
  final bool showStreamingBubble;
  final bool isLoadingOlder;
  final bool hasMoreOlder;
  final Future<void> Function() onLoadOlder;

  const _AiMessagesList({
    required this.controller,
    required this.messages,
    required this.hasStreamingDelta,
    required this.showStreamingBubble,
    required this.isLoadingOlder,
    required this.hasMoreOlder,
    required this.onLoadOlder,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = messages.length + (showStreamingBubble ? 1 : 0);
    return ListView.builder(
      controller: controller,
      // Reverse so the newest message sits at the bottom (the natural chat
      // UX). With reverse, item index 0 is the last element of `messages`,
      // so we reverse the index lookup in itemBuilder.
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: itemCount,
      itemBuilder: (context, reversedIndex) {
        final i = messages.length - 1 - reversedIndex;
        if (reversedIndex == 0 && showStreamingBubble) {
          // Streaming assistant bubble pinned to the very bottom.
          return AiMessageBubble(
            streamingDelta: hasStreamingDelta ? _streamingDelta(context) : null,
            isStreamingAssistant: true,
          );
        }
        if (i < 0) {
          // Defensive: shouldn't happen because itemCount accounts for the
          // streaming bubble, but bail safely rather than crash.
          return const SizedBox.shrink();
        }
        // Top-of-list footer — only visible at the very top of the reverse
        // list (i.e. the oldest visible message), and only when there is
        // actually more to load or a load is in flight.
        final isTopFooter = i == 0;
        if (isTopFooter && (hasMoreOlder || isLoadingOlder)) {
          return _OlderMessagesFooter(
            hasMoreOlder: hasMoreOlder,
            isLoading: isLoadingOlder,
            onLoadOlder: onLoadOlder,
          );
        }
        return AiMessageBubble(message: messages[i] as dynamic);
      },
    );
  }

  String _streamingDelta(BuildContext context) {
    // Read from the provider at build time so the reverse-list re-renders
    // when tokens stream in.
    final provider = context.read<AiAssistantProvider>();
    return provider.streamingDelta;
  }
}

class _OlderMessagesFooter extends StatelessWidget {
  final bool hasMoreOlder;
  final bool isLoading;
  final Future<void> Function() onLoadOlder;

  const _OlderMessagesFooter({
    required this.hasMoreOlder,
    required this.isLoading,
    required this.onLoadOlder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : hasMoreOlder
                ? TextButton.icon(
                    key: const ValueKey('ai-chat-load-older'),
                    onPressed: () {
                      // ignore: discarded_futures
                      onLoadOlder();
                    },
                    icon: const Icon(Icons.expand_less, size: 18),
                    label: const Text('Tải tin nhắn cũ hơn'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                    ),
                  )
                : Text(
                    'Đã tải hết cuộc hội thoại',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
      ),
    );
  }
}
