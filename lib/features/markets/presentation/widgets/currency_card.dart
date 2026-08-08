import 'package:crypto_trading_app/features/markets/domain/entities/currency.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/core/utils/price_formatter.dart';
import 'package:flutter/material.dart';

import 'currency_status_badge.dart';

/// Visual density for [CurrencyCard]. The list screen chooses which variant
/// to render based on the current layout breakpoint.
enum CurrencyCardVariant {
  /// Full card with two metric tiles and status chips.
  full,

  /// Compact card used inside a 2-column grid. Avatar + symbol/name +
  /// last price + change only.
  compact,
}

/// Theme-aware card for a single [Currency] entry.
///
/// All colors derive from the active [ColorScheme] (no hard-coded
/// [Colors.*]). Used by both the list screen and any future picker.
class CurrencyCard extends StatelessWidget {
  final Currency currency;
  final VoidCallback? onTap;
  final bool showStatus;
  final CurrencyCardVariant variant;

  const CurrencyCard({
    super.key,
    required this.currency,
    this.onTap,
    this.showStatus = true,
    this.variant = CurrencyCardVariant.full,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final changeValue = _parseDouble(currency.priceChangePercent24h);
    final changeColor = _changeColor(changeValue, scheme);
    final changeText = _formatChange(changeValue, l10n);

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        mouseCursor:
            onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        borderRadius: BorderRadius.circular(12),
        child: variant == CurrencyCardVariant.compact
            ? _buildCompact(
                context,
                scheme: scheme,
                textTheme: textTheme,
                l10n: l10n,
                changeColor: changeColor,
                changeText: changeText,
              )
            : _buildFull(
                context,
                scheme: scheme,
                textTheme: textTheme,
                l10n: l10n,
                changeColor: changeColor,
                changeText: changeText,
              ),
      ),
    );
  }

  Widget _buildCompact(
    BuildContext context, {
    required ColorScheme scheme,
    required TextTheme textTheme,
    required AppLocalizations l10n,
    required Color changeColor,
    required String changeText,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _Avatar(symbol: currency.symbol, size: 40, scheme: scheme),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currency.symbol,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  currency.name,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatPrice(currency.lastPrice, l10n),
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 4),
              _ChangePill(
                text: changeText,
                color: changeColor,
                dense: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFull(
    BuildContext context, {
    required ColorScheme scheme,
    required TextTheme textTheme,
    required AppLocalizations l10n,
    required Color changeColor,
    required String changeText,
  }) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(symbol: currency.symbol, size: 48, scheme: scheme),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currency.symbol,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currency.name,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatPrice(currency.lastPrice, l10n),
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 4),
                  _ChangePill(text: changeText, color: changeColor),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: l10n.volume24h,
                  value: _formatVolume(currency.volume24h, l10n),
                  scheme: scheme,
                  textTheme: textTheme,
                ),
              ),
              if (showStatus) ...[
                const SizedBox(width: 8),
                currency.badgeFor(CurrencyStatusKind.active),
                const SizedBox(width: 6),
                currency.badgeFor(CurrencyStatusKind.tradable),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.symbol,
    required this.size,
    required this.scheme,
  });

  final String symbol;
  final double size;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final letter = symbol.isEmpty ? '?' : symbol.substring(0, 1);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: size * 0.42,
          fontWeight: FontWeight.bold,
          color: scheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _ChangePill extends StatelessWidget {
  const _ChangePill({
    required this.text,
    required this.color,
    this.dense = false,
  });

  final String text;
  final Color color;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 6 : 8,
        vertical: dense ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(dense ? 6 : 12),
      ),
      child: Text(
        text,
        style: textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.scheme,
    required this.textTheme,
  });

  final String label;
  final String value;
  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

String _formatPrice(String? raw, AppLocalizations l10n) {
  if (raw == null || raw.isEmpty) return l10n.na;
  return PriceFormatter.formatPriceStr(raw);
}

String _formatVolume(String? raw, AppLocalizations l10n) {
  if (raw == null || raw.isEmpty) return l10n.na;
  return PriceFormatter.formatVolumeStr(raw);
}

String _formatChange(double? value, AppLocalizations l10n) {
  if (value == null) return l10n.na;
  return FormatUtils.formatPriceChange(value);
}

Color _changeColor(double? value, ColorScheme scheme) {
  if (value == null) return scheme.onSurfaceVariant;
  if (value > 0) return scheme.tertiary;
  if (value < 0) return scheme.error;
  return scheme.onSurfaceVariant;
}

double? _parseDouble(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return double.tryParse(value);
}
