import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/core/utils/price_formatter.dart';
import 'package:crypto_trading_app/core/widgets/app_empty_state.dart';

import 'package:crypto_trading_app/features/markets/domain/entities/currency.dart';
import 'package:crypto_trading_app/features/markets/presentation/providers/currencies_provider.dart';
import 'package:crypto_trading_app/features/markets/presentation/widgets/currency_detail_row.dart';
import 'package:crypto_trading_app/features/markets/presentation/widgets/currency_metric_card.dart';
import 'package:crypto_trading_app/features/markets/presentation/widgets/currency_status_badge.dart';

/// Currency Detail Screen
///
/// Shows a sticky header (symbol + name + status) followed by three themed
/// sections (market overview, configuration, status). All colors derive from
/// the active [ColorScheme].
class CurrencyDetailScreen extends StatefulWidget {
  final String currencyId;
  final Currency? initialCurrency;

  const CurrencyDetailScreen({
    super.key,
    required this.currencyId,
    this.initialCurrency,
  });

  @override
  State<CurrencyDetailScreen> createState() => _CurrencyDetailScreenState();
}

class _CurrencyDetailScreenState extends State<CurrencyDetailScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialCurrency == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<CurrenciesProvider>().getCurrencyById(widget.currencyId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Consumer<CurrenciesProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading &&
              provider.selectedCurrency == null &&
              widget.initialCurrency == null) {
            return const _DetailLoadingScaffold();
          }

          if (provider.error != null &&
              provider.selectedCurrency == null &&
              widget.initialCurrency == null) {
            return Scaffold(
              appBar: AppBar(),
              body: AppEmptyState(
                icon: Icons.error_outline,
                title: l10n.currenciesNotFound,
                message: provider.error!,
                action: () =>
                    provider.getCurrencyById(widget.currencyId),
                actionLabel: l10n.currenciesRetryAction,
              ),
            );
          }

          final currency =
              provider.selectedCurrency ?? widget.initialCurrency;
          if (currency == null) {
            return Scaffold(
              appBar: AppBar(),
              body: AppEmptyState(
                icon: Icons.help_outline,
                message: l10n.currenciesNotFound,
              ),
            );
          }

          return _DetailContent(
            currency: currency,
            showBackButton: widget.initialCurrency == null,
            onBack: () => Navigator.of(context).maybePop(),
          );
        },
      ),
    );
  }
}

class _DetailLoadingScaffold extends StatelessWidget {
  const _DetailLoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.currency,
    required this.showBackButton,
    required this.onBack,
  });

  final Currency currency;
  final bool showBackButton;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    final changeValue = _parseDouble(currency.priceChangePercent24h);
    final changeColor = _changeColor(changeValue, scheme);
    final changeText = _formatChange(changeValue, l10n);
    final lastPrice = _formatPrice(currency.lastPrice, l10n);
    final volumeText = _formatVolume(currency.volume24h, l10n);

    return CustomScrollView(
      slivers: [
        SliverAppBar.medium(
          pinned: true,
          leading: showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: l10n.currenciesDetailBackToMarkets,
                  onPressed: onBack,
                )
              : null,
          title: Text(currency.symbol),
          backgroundColor: scheme.surface,
          surfaceTintColor: scheme.surfaceTint,
        ),
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              children: [
                _Avatar(symbol: currency.symbol, scheme: scheme),
                const SizedBox(height: 12),
                Text(
                  currency.symbol,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currency.name,
                  style: textTheme.titleSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    currency.badgeFor(CurrencyStatusKind.active),
                    currency.badgeFor(CurrencyStatusKind.tradable),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  lastPrice,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 8),
                _ChangePill(text: changeText, color: changeColor),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _SectionHeader(
            title: l10n.currenciesMarketOverviewTitle,
            icon: Icons.show_chart,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          sliver: SliverGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.7,
            children: [
              CurrencyMetricCard(
                label: l10n.lastPrice,
                value: lastPrice,
                icon: Icons.price_change,
              ),
              CurrencyMetricCard(
                label: l10n.change24h,
                value: changeText,
                icon: Icons.trending_up,
                valueColor: changeColor,
              ),
              CurrencyMetricCard(
                label: l10n.volume24h,
                value: volumeText,
                icon: Icons.bar_chart,
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: _SectionHeader(
            title: l10n.currenciesConfigurationTitle,
            icon: Icons.tune,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed([
              CurrencyDetailRow(
                label: l10n.currenciesSymbolLabel,
                value: currency.symbol,
                icon: Icons.tag,
              ),
              CurrencyDetailRow(
                label: l10n.currenciesNameLabel,
                value: currency.name,
                icon: Icons.info_outline,
              ),
              CurrencyDetailRow(
                label: l10n.currenciesPrecisionScaleLabel,
                value: '${currency.precisionScale}',
                icon: Icons.precision_manufacturing,
              ),
              CurrencyDetailRow(
                label: l10n.currenciesMinWithdrawLabel,
                value:
                    '${FormatUtils.formatDecimalAmountForScale(currency.minWithdraw, currency.precisionScale)} ${currency.symbol}',
                icon: Icons.arrow_downward,
              ),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: _SectionHeader(
            title: l10n.currenciesDetailStatusTitle,
            icon: Icons.toggle_on,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed([
              _StatusRow(
                label: l10n.currenciesDetailActiveLabel,
                badge: currency.badgeFor(CurrencyStatusKind.active),
              ),
              const SizedBox(height: 8),
              _StatusRow(
                label: l10n.currenciesDetailTradableLabel,
                badge: currency.badgeFor(CurrencyStatusKind.tradable),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.symbol, required this.scheme});

  final String symbol;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final letter = symbol.isEmpty ? '?' : symbol.substring(0, 1);
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(40),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: scheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _ChangePill extends StatelessWidget {
  const _ChangePill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: textTheme.titleSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.badge});

  final String label;
  final Widget badge;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          badge,
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
