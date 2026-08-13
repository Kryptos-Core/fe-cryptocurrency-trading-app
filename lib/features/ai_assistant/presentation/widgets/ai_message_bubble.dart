import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/message.dart';

/// Chat bubble for an AI message. Supports user, assistant, and tool roles.
class AiMessageBubble extends StatelessWidget {
  final Message? message;
  final String? streamingDelta;
  final bool isStreamingAssistant;

  const AiMessageBubble({
    super.key,
    this.message,
    this.streamingDelta,
    this.isStreamingAssistant = false,
  }) : assert(message != null || streamingDelta != null || isStreamingAssistant,
            'Either message, streamingDelta, or streaming placeholder must be provided');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final role = message?.role ?? MessageRole.assistant;
    final isUser = role == MessageRole.user;
    final isTool = role == MessageRole.tool;
    final content = (message?.content ?? streamingDelta ?? '').trim();
    final showLoadingPlaceholder =
        isStreamingAssistant && content.isEmpty && message == null;

    final alignment =
        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isUser
        ? theme.colorScheme.primary
        : (isTool
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surfaceContainerHigh);
    final textColor =
        isUser ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;

    final showTyping = isStreamingAssistant && content.isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(isUser ? 14 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 14),
                ),
              ),
              child: showTyping
                  ? _TypingIndicator(color: textColor)
                  : _MessageContent(
                      content: content,
                      isUser: isUser,
                      textColor: textColor,
                      bubbleColor: bubbleColor,
                      key: const ValueKey('ai-message-content'),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders chat text as Markdown for assistant/tool roles, plain text for the
/// user role (so user input is shown verbatim, not parsed).
class _MessageContent extends StatelessWidget {
  final String content;
  final bool isUser;
  final Color textColor;
  final Color bubbleColor;

  const _MessageContent({
    super.key,
    required this.content,
    required this.isUser,
    required this.textColor,
    required this.bubbleColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isUser) {
      return Text(
        content,
        style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
      );
    }
    final codeBackground = theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    final codeBlockBackground = theme.brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.35)
        : Colors.grey.shade100;
    final baseStyle = theme.textTheme.bodyMedium?.copyWith(color: textColor);
    return MarkdownBody(
      data: content,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: baseStyle,
        h1: baseStyle?.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
        h2: baseStyle?.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
        h3: baseStyle?.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
        h4: baseStyle?.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
        h5: baseStyle?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
        h6: baseStyle?.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
        strong: baseStyle?.copyWith(fontWeight: FontWeight.w700),
        em: baseStyle?.copyWith(fontStyle: FontStyle.italic),
        del: baseStyle?.copyWith(decoration: TextDecoration.lineThrough),
        a: baseStyle?.copyWith(
          color: theme.colorScheme.primary,
          decoration: TextDecoration.underline,
        ),
        blockquote: baseStyle?.copyWith(
          color: textColor.withValues(alpha: 0.75),
        ),
        blockquoteDecoration: BoxDecoration(
          color: bubbleColor.withValues(alpha: 0.35),
          border: Border(
            left: BorderSide(color: theme.colorScheme.primary, width: 3),
          ),
        ),
        blockquotePadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        code: baseStyle?.copyWith(
          fontFamily: 'monospace',
          fontSize: 13,
          backgroundColor: codeBackground,
        ),
        codeblockDecoration: BoxDecoration(
          color: codeBlockBackground,
          borderRadius: BorderRadius.circular(6),
        ),
        codeblockPadding: const EdgeInsets.all(10),
        listBullet: baseStyle,
        tableBody: baseStyle?.copyWith(fontSize: 13),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: textColor.withValues(alpha: 0.2), width: 1),
          ),
        ),
      ),
      onTapLink: (text, href, title) {
        if (href == null) return;
        final uri = Uri.tryParse(href);
        if (uri == null) return;
        launchUrl(uri, mode: LaunchMode.externalApplication);
      },
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  final Color color;
  const _TypingIndicator({required this.color});

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        Widget dot(int i) {
          final phase = (t + i / 3) % 1.0;
          final opacity = 0.4 + 0.6 * (1 - (phase - 0.5).abs() * 2).clamp(0.0, 1.0);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Opacity(
              opacity: opacity,
              child: Text(
                '•',
                style: TextStyle(
                  color: widget.color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [dot(0), dot(1), dot(2)],
        );
      },
    );
  }
}
