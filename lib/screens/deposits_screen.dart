import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crypto_trading_app/core/utils/checkout_tab_preopen.dart';
import 'package:crypto_trading_app/core/utils/currency_amount_input.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/deposits_provider.dart';
import 'package:crypto_trading_app/presentation/providers/exchange_rate_provider.dart';
import 'package:crypto_trading_app/presentation/providers/wallets_provider.dart';
import 'package:crypto_trading_app/presentation/providers/payment_config_provider.dart';
import 'package:crypto_trading_app/presentation/widgets/rate_preview_widget.dart';
import 'package:crypto_trading_app/screens/market_prices_screen.dart';

class _AmountThousandsSeparatorFormatter extends TextInputFormatter {
  final NumberFormat _numberFormat = NumberFormat('#,###');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final number = int.tryParse(digitsOnly);
    if (number == null) {
      return oldValue;
    }

    final formatted = _numberFormat.format(number);
    final selectionFromRight = newValue.text.length - newValue.selection.end;
    var newOffset = formatted.length - selectionFromRight;
    if (newOffset < 0) newOffset = 0;
    if (newOffset > formatted.length) newOffset = formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}

class DepositsScreen extends StatefulWidget {
  const DepositsScreen({super.key});

  @override
  State<DepositsScreen> createState() => _DepositsScreenState();
}

class _DepositsScreenState extends State<DepositsScreen> {
  final TextEditingController _amountController = TextEditingController();
  final _amountFormatter = _AmountThousandsSeparatorFormatter();
  bool _isPollingAfterCheckout = false;

  int? _parseAmountFromInput(String input) {
    final digitsOnly = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return null;
    return int.tryParse(digitsOnly);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<DepositsProvider>();
      p.fetchMyDeposits();
      p.loadCheckoutMeta();
      context
          .read<ExchangeRateProvider>()
          .fetchMarketPrices(symbols: const ['USDT']);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleDeposit() async {
    final l10n = AppLocalizations.of(context);
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.payosEnterAmount)),
      );
      return;
    }

    final deposits = context.read<DepositsProvider>();
    final minVnd = deposits.effectivePayosMinAmountFiat;
    final amount = _parseAmountFromInput(amountText);
    if (amount == null || amount < minVnd) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.payosInvalidAmountMin(minVnd))),
      );
      return;
    }
    final maxVnd = deposits.effectivePayosMaxAmountFiat;
    if (maxVnd != null && amount > maxVnd) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.payosInvalidAmountMax(maxVnd))),
      );
      return;
    }

    // Open a blank tab immediately on user click to reduce popup-blocker risk on web.
    final preopenedTab = kIsWeb ? preopenCheckoutTab() : null;

    final provider = deposits;
    final session = await provider.createDepositLink(amount);
    final checkoutUrl = session?.checkoutUrl;
    final orderCode = session?.orderCode;

    if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
      if (preopenedTab != null) {
        final navigated = preopenedTab.navigateTo(checkoutUrl);
        if (!navigated) {
          preopenedTab.close();
          await _openCheckoutUrl(checkoutUrl);
        }
      } else {
        await _openCheckoutUrl(checkoutUrl);
      }

      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<WalletsProvider>().fetchWallets();
        provider.fetchMyDeposits();
      });

      await _pollForPaidStatus(
        orderCode: orderCode,
        timeout: const Duration(seconds: 90),
        interval: const Duration(seconds: 5),
      );
    } else {
      preopenedTab?.close();
      if (mounted && provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error!)),
        );
      }
    }
  }

  /// Tap PENDING deposit: sync first, then open checkout if still PENDING (e.g. paid on PayOS but app not synced yet).
  Future<void> _onTapPendingDeposit(int orderCode, String checkoutUrl) async {
    final provider = context.read<DepositsProvider>();
    final l10n = AppLocalizations.of(context);

    await provider.syncDepositStatus(orderCode);
    await provider.fetchMyDeposits();

    if (!mounted) return;

    final updated =
        provider.deposits.where((d) => d.orderCode == orderCode).firstOrNull;
    final isPaid = updated?.status.toUpperCase() == 'PAID';

    if (isPaid) {
      context.read<WalletsProvider>().fetchWallets();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.payosPaymentUpdated)),
      );
      return;
    }

    await _openCheckoutUrl(checkoutUrl);
  }

  Future<bool> _tryLaunchCheckoutUrl(Uri uri) async {
    try {
      if (kIsWeb) {
        final openedInNewTab =
            await launchUrl(uri, webOnlyWindowName: '_blank');
        if (openedInNewTab) return true;

        // Fallback for popup blockers: navigate in current tab.
        return await launchUrl(uri, webOnlyWindowName: '_self');
      }

      // Mobile/Desktop: open external browser/payment app.
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  Future<bool> _openCheckoutUrl(String checkoutUrl) async {
    final l10n = AppLocalizations.of(context);
    final uri = Uri.tryParse(checkoutUrl);

    if (uri == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.payosOpenLinkFailed)),
        );
      }
      return false;
    }

    final opened = await _tryLaunchCheckoutUrl(uri);
    if (opened) {
      return true;
    }

    if (!mounted) return false;

    final fallbackOpened = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.payosOpenLinkFallbackTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.payosOpenLinkFallbackDesc),
              const SizedBox(height: 12),
              SelectableText(checkoutUrl),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: checkoutUrl));
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.payosLinkCopied)),
                );
              },
              child: Text(l10n.payosCopyLink),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.close),
            ),
            FilledButton(
              onPressed: () async {
                final ok = await _tryLaunchCheckoutUrl(uri);
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop(ok);
              },
              child: Text(l10n.payosOpenInBrowser),
            ),
          ],
        );
      },
    );

    if ((fallbackOpened ?? false) == false && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.payosOpenLinkFailed)),
      );
    }

    return fallbackOpened ?? false;
  }

  Future<void> _pollForPaidStatus({
    required int? orderCode,
    required Duration timeout,
    required Duration interval,
  }) async {
    if (_isPollingAfterCheckout || !mounted) return;
    final l10n = AppLocalizations.of(context);

    setState(() {
      _isPollingAfterCheckout = true;
    });

    final provider = context.read<DepositsProvider>();
    final walletsProvider = context.read<WalletsProvider>();
    final startedAt = DateTime.now();

    bool foundPaid = false;
    bool foundCancelled = false;
    while (mounted && DateTime.now().difference(startedAt) < timeout) {
      await Future<void>.delayed(interval);
      if (!mounted) break;

      if (orderCode != null) {
        await provider.syncDepositStatus(orderCode);
      }
      await provider.fetchMyDeposits();

      String? status;
      if (orderCode != null) {
        for (final deposit in provider.deposits) {
          if (deposit.orderCode == orderCode) {
            status = deposit.status.toUpperCase();
            break;
          }
        }
      }

      final isPaid = status == 'PAID' ||
          (orderCode == null &&
              provider.deposits.any((d) => d.status.toUpperCase() == 'PAID'));

      if (isPaid) {
        foundPaid = true;
        break;
      }

      if (status == 'CANCELLED') {
        foundCancelled = true;
        break;
      }
    }

    if (mounted) {
      if (foundPaid) {
        await walletsProvider.fetchWallets();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.payosPaymentUpdated)),
        );
      } else if (foundCancelled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.payosPaymentCancelled)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.payosOrderProcessing)),
        );
      }

      setState(() {
        _isPollingAfterCheckout = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<DepositsProvider>();
    final exchangeRateProvider = context.watch<ExchangeRateProvider>();
    final paymentConfig = context.watch<PaymentConfigProvider>();
    String? usdtPriceVnd;
    for (final item in exchangeRateProvider.marketPrices) {
      if (item.symbol.toUpperCase() == 'USDT') {
        usdtPriceVnd = item.priceVnd;
        break;
      }
    }

    final isPayosTransitioning = paymentConfig.isAnyTransitioning &&
        (paymentConfig.transitioningType == 'PAYOS' ||
            paymentConfig.transitioningType == null);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.payosDepositTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart),
            tooltip: l10n.payosMarketPricesTooltip,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MarketPricesScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPayosTransitioning) ...[
              Material(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          paymentConfig.payosTransitioningDepositBannerText(l10n),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => paymentConfig.clearLatestEvent(),
                        child: Text(l10n.dismiss),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              l10n.payosCreateOrder,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [_amountFormatter],
                    onChanged: (value) {
                      final amount = _parseAmountFromInput(value);
                      context
                          .read<ExchangeRateProvider>()
                          .scheduleDepositPreview(amount);
                    },
                    decoration: CurrencyAmountInput.withCurrencySuffix(
                      context,
                      InputDecoration(
                        labelText: l10n.payosAmountLabel,
                        border: const OutlineInputBorder(),
                        hintText: l10n.payosMinAmountHintDynamic(
                          NumberFormat('#,###').format(
                            provider.effectivePayosMinAmountFiat,
                          ),
                        ),
                      ),
                      currencySymbol: 'VND',
                    ),
                  ),
                  if (usdtPriceVnd != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      l10n.payosUsdtMarketPrice(
                        FormatUtils.formatFiatIntegerDisplay(usdtPriceVnd),
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                    ),
                  ],
                  RatePreviewWidget(
                    preview: exchangeRateProvider.depositPreview,
                    isLoading: exchangeRateProvider.isLoadingPreview,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: provider.isCreatingLink
                        ? FilledButton(
                            onPressed: null,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            child: SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : FilledButton.icon(
                            onPressed: _isPollingAfterCheckout
                                ? null
                                : _handleDeposit,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            icon: const Icon(Icons.payments_outlined, size: 20),
                            label: Text(
                              _isPollingAfterCheckout
                                  ? l10n.payosWaitingWebhook
                                  : l10n.payosTopupVnd,
                            ),
                          ),
                  ),
                  if (_isPollingAfterCheckout) ...[
                    const SizedBox(height: 10),
                    const LinearProgressIndicator(),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.recentTransactions,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (provider.isLoading && provider.deposits.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.deposits.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  l10n.payosNoTransactions,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              )
            else
              ...provider.deposits.map((deposit) {
                final isPending =
                    deposit.status.toUpperCase() == 'PENDING';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isPending &&
                              deposit.checkoutUrl.isNotEmpty
                          ? () => _onTapPendingDeposit(
                                deposit.orderCode,
                                deposit.checkoutUrl,
                              )
                          : null,
                      borderRadius: BorderRadius.circular(10),
                      mouseCursor: isPending &&
                              deposit.checkoutUrl.isNotEmpty
                          ? SystemMouseCursors.click
                          : SystemMouseCursors.basic,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${FormatUtils.formatFiatIntegerDisplay(deposit.amount)} VND',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                _buildStatusBadge(context, deposit.status),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isPending
                                  ? '${l10n.payosOrderCode}: ${deposit.orderCode} • ${l10n.payosTapToOpenCheckout}'
                                  : '${l10n.payosOrderCode}: ${deposit.orderCode}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey.shade700,
                                    height: 1.35,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context);
    final upper = status.toUpperCase();
    late Color bgColor;
    late Color textColor;
    late String label;

    switch (upper) {
      case 'PAID':
        bgColor = const Color(0xFFEAF8F1);
        textColor = const Color(0xFF0F8A49);
        label = l10n.depositStatusPaid;
        break;
      case 'CANCELLED':
        bgColor = const Color(0xFFFDECEF);
        textColor = const Color(0xFFB3261E);
        label = l10n.depositStatusCancelled;
        break;
      case 'PENDING':
        bgColor = const Color(0xFFFFF6E8);
        textColor = const Color(0xFFB56900);
        label = l10n.depositStatusPending;
        break;
      default:
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
