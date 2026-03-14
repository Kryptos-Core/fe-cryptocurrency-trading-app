import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/deposits_provider.dart';
import 'package:crypto_trading_app/presentation/providers/wallets_provider.dart';

class DepositsScreen extends StatefulWidget {
  const DepositsScreen({super.key});

  @override
  State<DepositsScreen> createState() => _DepositsScreenState();
}

class _DepositsScreenState extends State<DepositsScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _isPollingAfterCheckout = false;

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

    final amount = double.tryParse(amountText);
    if (amount == null || amount < 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.payosInvalidAmountMin)),
      );
      return;
    }

    final provider = context.read<DepositsProvider>();
    final session = await provider.createDepositLink(amount);
    final checkoutUrl = session?.checkoutUrl;

    if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
      final uri = Uri.parse(checkoutUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        // When user returns to the app, we refresh their balance and deposit history.
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<WalletsProvider>().fetchWallets();
            provider.fetchMyDeposits();
          });

          await _pollForPaidStatus(
            orderCode: session?.orderCode,
            timeout: const Duration(seconds: 60),
            interval: const Duration(seconds: 5),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.payosOpenLinkFailed)),
          );
        }
      }
    } else {
      if (mounted && provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error!)),
        );
      }
    }
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
    while (mounted && DateTime.now().difference(startedAt) < timeout) {
      await Future<void>.delayed(interval);
      if (!mounted) break;

      await provider.fetchMyDeposits();

      final isPaid = orderCode != null
          ? provider.deposits.any(
              (d) => d.orderCode == orderCode && d.status == 'PAID',
            )
          : provider.deposits.any((d) => d.status == 'PAID');

      if (isPaid) {
        foundPaid = true;
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.payosDepositTitle),
        centerTitle: true,
      ),
      body: Padding(
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
                      decoration: InputDecoration(
                        labelText: l10n.payosAmountLabel,
                        border: const OutlineInputBorder(),
                        hintText: l10n.payosMinAmountHint,
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
                            return Card(
                              child: ListTile(
                                title: Text('${deposit.amount} VND'),
                                subtitle: Text(
                                    '${l10n.payosOrderCode}: ${deposit.orderCode}'),
                                trailing: _buildStatusBadge(deposit.status),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
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
