import 'package:flutter/material.dart';

/// Bottom-of-screen input row: TextField + send/stop IconButton.
class AiChatInput extends StatefulWidget {
  final bool enabled;
  final bool isStreaming;
  final Future<void> Function(String) onSend;
  final VoidCallback onStop;

  const AiChatInput({
    super.key,
    required this.enabled,
    required this.isStreaming,
    required this.onSend,
    required this.onStop,
  });

  @override
  State<AiChatInput> createState() => _AiChatInputState();
}

class _AiChatInputState extends State<AiChatInput> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) {
        setState(() => _hasText = has);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final future = widget.onSend(text);
    if (future != null) {
      // ignore: discarded_futures
      future.then((_) => _controller.clear());
    } else {
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.4)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: widget.enabled && !widget.isStreaming,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: widget.isStreaming
                      ? 'AI đang trả lời…'
                      : 'Hỏi gì đó (vd: "giá BTC/USDT?", "cách đặt lệnh?")',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                onSubmitted: widget.isStreaming ? null : (_) => _handleSend(),
              ),
            ),
            const SizedBox(width: 8),
            if (widget.isStreaming)
              IconButton(
                key: const ValueKey('ai-chat-stop'),
                onPressed: widget.onStop,
                icon: const Icon(Icons.stop_circle_outlined),
                color: theme.colorScheme.error,
                tooltip: 'Dừng',
              )
            else
              IconButton(
                key: const ValueKey('ai-chat-send'),
                onPressed: (widget.enabled && _hasText) ? _handleSend : null,
                icon: const Icon(Icons.send),
                color: theme.colorScheme.primary,
                tooltip: 'Gửi',
              ),
          ],
        ),
      ),
    );
  }
}
