import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';

/// Which long-form body to render.
///
/// The set is intentionally small: Glossary, FAQ, Contact. New bodies can be
/// added here as more static content appears (e.g. release notes).
enum ManualDetailTopic { glossary, faq, contact }

extension on ManualDetailTopic {
  String bodyFor(AppLocalizations l) {
    switch (this) {
      case ManualDetailTopic.glossary:
        return l.manualGlossaryBody;
      case ManualDetailTopic.faq:
        return l.manualFaqBody;
      case ManualDetailTopic.contact:
        return l.manualContactBody;
    }
  }

  String titleFor(AppLocalizations l) {
    switch (this) {
      case ManualDetailTopic.glossary:
        return l.manualGlossaryTitle;
      case ManualDetailTopic.faq:
        return l.manualFaqTitle;
      case ManualDetailTopic.contact:
        return l.manualContactTitle;
    }
  }
}

/// In-app detail screen for long-form operator manual content.
///
/// Renders the localized Markdown body of a [ManualDetailTopic]. We parse
/// a small subset of Markdown (`## / ###` headers, bullet lists, paragraphs,
/// and `**bold**` spans) ourselves to avoid pulling in `flutter_markdown` as
/// a dependency. This keeps the rendering deterministic, accessible and
/// visually consistent with the rest of the app.
class ManualDetailScreen extends StatelessWidget {
  const ManualDetailScreen({super.key, required this.topic});

  final ManualDetailTopic topic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final body = topic.bodyFor(l10n);

    return Scaffold(
      appBar: AppBar(
        title: Text(topic.titleFor(l10n)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: _MarkdownContent(text: body),
      ),
    );
  }
}

// ── Markdown subset renderer ─────────────────────────────────────────────

/// Parsed block in the minimal markdown subset we support.
sealed class _Block {
  const _Block();
}

class _HeadingBlock extends _Block {
  const _HeadingBlock(this.level, this.text);
  final int level; // 2 for ##, 3 for ###, etc.
  final String text;
}

class _ParagraphBlock extends _Block {
  const _ParagraphBlock(this.text);
  final String text;
}

class _BulletBlock extends _Block {
  const _BulletBlock(this.text);
  final String text;
}

class _MarkdownParser {
  _MarkdownParser(this.input);

  final String input;

  List<_Block> parse() {
    final blocks = <_Block>[];
    final lines = const LineSplitter().convert(input);

    final paragraphBuffer = StringBuffer();
    void flushParagraph() {
      if (paragraphBuffer.isNotEmpty) {
        blocks.add(_ParagraphBlock(paragraphBuffer.toString().trim()));
        paragraphBuffer.clear();
      }
    }

    for (final raw in lines) {
      final line = raw.trimRight();
      if (line.isEmpty) {
        flushParagraph();
        continue;
      }
      if (line.startsWith('### ')) {
        flushParagraph();
        blocks.add(_HeadingBlock(3, line.substring(4).trim()));
      } else if (line.startsWith('## ')) {
        flushParagraph();
        blocks.add(_HeadingBlock(2, line.substring(3).trim()));
      } else if (line.startsWith('- ')) {
        flushParagraph();
        blocks.add(_BulletBlock(line.substring(2).trim()));
      } else {
        if (paragraphBuffer.isNotEmpty) {
          paragraphBuffer.write(' ');
        }
        paragraphBuffer.write(line);
      }
    }
    flushParagraph();
    return blocks;
  }
}

/// Widget that renders the parsed blocks of a [ManualDetailScreen] body.
class _MarkdownContent extends StatelessWidget {
  const _MarkdownContent({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final blocks = _MarkdownParser(text).parse();
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final block in blocks) ...[
          if (block is _HeadingBlock && block.level == 2)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Text(
                block.text,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
            )
          else if (block is _HeadingBlock)
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 6),
              child: Text(
                block.text,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            )
          else if (block is _BulletBlock)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, right: 8),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _InlineText(
                      text: block.text,
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (block is _ParagraphBlock)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: _InlineText(
                text: block.text,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                  height: 1.4,
                ),
              ),
            ),
        ],
      ],
    );
  }
}

/// Renders a single text line with `**bold**` segments styled bold.
class _InlineText extends StatelessWidget {
  const _InlineText({required this.text, required this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    final pattern = RegExp(r'\*\*(.+?)\*\*');
    int last = 0;
    for (final match in pattern.allMatches(text)) {
      if (match.start > last) {
        spans.add(TextSpan(text: text.substring(last, match.start), style: style));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: style?.copyWith(fontWeight: FontWeight.bold),
        ),
      );
      last = match.end;
    }
    if (last < text.length) {
      spans.add(TextSpan(text: text.substring(last), style: style));
    }
    return SelectableText.rich(TextSpan(children: spans));
  }
}