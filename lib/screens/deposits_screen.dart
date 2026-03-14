import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount.')),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount < 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid amount. Minimum is 10,000 VND.')),
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
            const SnackBar(content: Text('Could not open payment link.')),
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
          const SnackBar(
            content: Text(
                'Thanh toán thành công. Số dư và lịch sử đã được cập nhật.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Đơn đang xử lý. Hệ thống sẽ tự cập nhật khi PayOS gửi webhook.'),
          ),
        );
      }

      setState(() {
        _isPollingAfterCheckout = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DepositsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nạp tiền VND (PayOS)'),
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
                    const Text(
                      'Tạo đơn nạp tiền',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Số tiền (VND)',
                        border: OutlineInputBorder(),
                        hintText: 'Tối thiểu 10,000',
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
                                ? const Text('Đang chờ webhook PayOS...')
                                : const Text('Nạp tiền'),
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
            const Text(
              'Lịch sử nạp tiền',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.deposits.isEmpty
                      ? const Center(
                          child: Text('Chưa có giao dịch nạp tiền nào.'))
                      : ListView.builder(
                          itemCount: provider.deposits.length,
                          itemBuilder: (context, index) {
                            final deposit = provider.deposits[index];
                            return Card(
                              child: ListTile(
                                title: Text('${deposit.amount} VND'),
                                subtitle: Text('Mã đơn: ${deposit.orderCode}'),
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
