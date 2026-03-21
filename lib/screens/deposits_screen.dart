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
import 'package:crypto_trading_app/presentation/providers/wallets_provider.dart';
import 'package:crypto_trading_app/presentation/providers/payment_config_provider.dart';

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
      context.read<DepositsProvider>().fetchMyDeposits();
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

    final amount = _parseAmountFromInput(amountText);
    if (amount == null || amount < 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.payosInvalidAmountMin)),
      );
      return;
    }

    // Open a blank tab immediately on user click to reduce popup-blocker risk on web.
    final preopenedTab = kIsWeb ? preopenCheckoutTab() : null;

    final provider = context.read<DepositsProvider>();
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

    final updated = provider.deposits
        .where((d) => d.orderCode == orderCode)
        .firstOrNull;
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
    final paymentConfig = context.watch<PaymentConfigProvider>();

    final isPayosTransitioning = paymentConfig.isAnyTransitioning &&
        (paymentConfig.transitioningType == 'PAYOS' ||
            paymentConfig.transitioningType == null);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.payosDepositTitle),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (isPayosTransitioning)
            MaterialBanner(
              backgroundColor: Colors.orange.shade100,
              leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
              content: Text(
                l10n.payosTransitioningBanner(
                  paymentConfig.transitioningGraceMinsRemaining != null
                      ? l10n.payosTransitioningGraceMinutes(
                          paymentConfig.transitioningGraceMinsRemaining!,
                        )
                      : '',
                ),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              actions: [
                TextButton(
                  onPressed: () => paymentConfig.clearLatestEvent(),
                  child: Text(l10n.dismiss),
                ),
              ],
            ),
          Expanded(
        child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Deposit form
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      l10n.payosCreateOrder,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_amountFormatter],
                      decoration: CurrencyAmountInput.withCurrencySuffix(
                        context,
                        InputDecoration(
                          labelText: l10n.payosAmountLabel,
                          border: const OutlineInputBorder(),
                          hintText: l10n.payosMinAmountHint,
                        ),
                        currencySymbol: 'VND',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                        ),
                        onPressed:
                            (provider.isCreatingLink || _isPollingAfterCheckout)
                                ? null
                                : _handleDeposit,
                        child: provider.isCreatingLink
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : _isPollingAfterCheckout
                                ? Text(l10n.payosWaitingWebhook)
                                : Text(l10n.payosTopupVnd),
                      ),
                    ),
                    if (_isPollingAfterCheckout) ...[
                      const SizedBox(height: 10),
                      const LinearProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Deposit history
            Text(
              l10n.recentTransactions,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.deposits.isEmpty
                      ? Center(child: Text(l10n.payosNoTransactions))
                      : ListView.builder(
                          itemCount: provider.deposits.length,
                          itemBuilder: (context, index) {
                            final deposit = provider.deposits[index];
                            final isPending =
                                deposit.status.toUpperCase() == 'PENDING';
                            return Card(
                              child: ListTile(
                                onTap: isPending &&
                                        deposit.checkoutUrl.isNotEmpty
                                    ? () => _onTapPendingDeposit(
                                        deposit.orderCode,
                                        deposit.checkoutUrl,
                                      )
                                    : null,
                                title: Text(
                                  '${FormatUtils.formatFiatIntegerDisplay(deposit.amount)} VND',
                                ),
                                subtitle: Text(
                                  isPending
                                      ? '${l10n.payosOrderCode}: ${deposit.orderCode} • ${l10n.payosTapToOpenCheckout}'
                                      : '${l10n.payosOrderCode}: ${deposit.orderCode}',
                                ),
                                trailing: _buildStatusBadge(deposit.status),
                              ),
                            );
                          },
                        ),
            ),           // close inner Expanded (the list)
          ],             // close inner Column children
        ),               // close inner Column
      ),                 // close Padding
    ),                   // close outer Expanded
        ],               // close outer Column children
      ),                 // close outer Column
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor = Colors.white;

    switch (status) {
      case 'PAID':
        bgColor = Colors.green;
        break;
      case 'CANCELLED':
        bgColor = Colors.red;
        break;
      default:
        bgColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: textColor, fontSize: 12),
      ),
    );
  }
}
