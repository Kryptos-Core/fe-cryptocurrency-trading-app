import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/onchain_transaction.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/onchain_tx_status.dart';
import 'package:crypto_trading_app/presentation/providers/blockchain_provider.dart';

class OnchainDepositScreen extends StatefulWidget {
  const OnchainDepositScreen({super.key});

  @override
  State<OnchainDepositScreen> createState() => _OnchainDepositScreenState();
}

class _OnchainDepositScreenState extends State<OnchainDepositScreen> {
  final _formKey = GlobalKey<FormState>();
  final _txHashController = TextEditingController();
  final _amountController = TextEditingController();
  BlockchainNetwork _selectedNetwork = BlockchainNetwork.ethSepolia;
  BlockchainNetwork? _txFilterNetwork;
  OnchainTxType? _txFilterType;
  bool _sortNewestFirst = true;

  String _formatAddress(String value) {
    if (value.length <= 14) return value;
    return '${value.substring(0, 8)}...${value.substring(value.length - 6)}';
  }

  Color _txStatusBg(OnchainTxStatus status) {
    switch (status) {
      case OnchainTxStatus.completed:
        return const Color(0xFFEAF8F1);
      case OnchainTxStatus.confirming:
        return const Color(0xFFEAF2FD);
      case OnchainTxStatus.pending:
        return const Color(0xFFFFF6E8);
      case OnchainTxStatus.failed:
        return const Color(0xFFFDECEF);
    }
  }

  Color _txStatusFg(OnchainTxStatus status) {
    switch (status) {
      case OnchainTxStatus.completed:
        return const Color(0xFF0F8A49);
      case OnchainTxStatus.confirming:
        return const Color(0xFF0A5DC2);
      case OnchainTxStatus.pending:
        return const Color(0xFFB56900);
      case OnchainTxStatus.failed:
        return const Color(0xFFB3261E);
    }
  }

  List<OnchainTransaction> _filteredTransactions(
    List<OnchainTransaction> source,
  ) {
    final filtered = source.where((tx) {
      final byNetwork = _txFilterNetwork == null || tx.chain == _txFilterNetwork;
      final byType = _txFilterType == null || tx.type == _txFilterType;
      return byNetwork && byType;
    }).toList();

    filtered.sort(
      (left, right) => _sortNewestFirst
          ? right.createdAt.compareTo(left.createdAt)
          : left.createdAt.compareTo(right.createdAt),
    );

    return filtered;
  }

  String _typeLabel(OnchainTxType? type) {
    if (type == null) return 'All types';
    switch (type) {
      case OnchainTxType.deposit:
        return 'Deposits';
      case OnchainTxType.withdrawal:
        return 'Withdrawals';
      case OnchainTxType.transfer:
        return 'Transfers';
    }
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: Colors.blueGrey.shade400),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade700),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSkeleton() {
    return Column(
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 220,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 160,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _txHashController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<BlockchainProvider>();
    final ok = await provider.submitDeposit(
      chain: _selectedNetwork,
      txHash: _txHashController.text.trim(),
      amount: _amountController.text.trim(),
    );

    if (!mounted) return;

    showAppSnackBar(
      context,
      message: ok ? 'Deposit submitted successfully' : (provider.error ?? 'Submit failed'),
      type: ok ? SnackBarType.success : SnackBarType.error,
    );

    if (ok) {
      _txHashController.clear();
      _amountController.clear();
      await provider.fetchRecentTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BlockchainProvider>(
      builder: (context, provider, _) {
        final filteredTransactions = _filteredTransactions(provider.recentTransactions);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Submit on-chain deposit',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'After sending tokens from your wallet to exchange deposit address, paste tx hash here.',
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<BlockchainNetwork>(
                  initialValue: _selectedNetwork,
                  decoration: const InputDecoration(
                    labelText: 'Network',
                    border: OutlineInputBorder(),
                  ),
                  items: BlockchainNetwork.values
                      .map(
                        (network) => DropdownMenuItem(
                          value: network,
                          child: Text(network.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedNetwork = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _txHashController,
                  decoration: const InputDecoration(
                    labelText: 'Transaction hash',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Tx hash is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Amount is required';
                    }
                    final n = double.tryParse(value.trim());
                    if (n == null || n <= 0) {
                      return 'Amount must be > 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: provider.isSubmitting ? null : _submit,
                    icon: const Icon(Icons.upload_file),
                    label: Text(provider.isSubmitting ? 'Submitting...' : 'Submit Deposit'),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Recent transactions',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('All networks'),
                      selected: _txFilterNetwork == null,
                      onSelected: (_) => setState(() => _txFilterNetwork = null),
                    ),
                    ...BlockchainNetwork.values.map(
                      (network) => ChoiceChip(
                        label: Text(network.label),
                        selected: _txFilterNetwork == network,
                        onSelected: (_) => setState(() => _txFilterNetwork = network),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('All types'),
                      selected: _txFilterType == null,
                      onSelected: (_) => setState(() => _txFilterType = null),
                    ),
                    ...OnchainTxType.values.map(
                      (type) => ChoiceChip(
                        label: Text(_typeLabel(type)),
                        selected: _txFilterType == type,
                        onSelected: (_) => setState(() => _txFilterType = type),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      '${filteredTransactions.length} result${filteredTransactions.length == 1 ? '' : 's'}',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const Spacer(),
                    ChoiceChip(
                      label: const Text('Newest'),
                      selected: _sortNewestFirst,
                      onSelected: (_) => setState(() => _sortNewestFirst = true),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Oldest'),
                      selected: !_sortNewestFirst,
                      onSelected: (_) => setState(() => _sortNewestFirst = false),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (provider.isLoading)
                  _buildRecentSkeleton()
                else ...[
                  ...filteredTransactions
                      .take(10)
                      .map(
                        (tx) => Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${tx.type.apiValue} · ${tx.amount}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _txStatusBg(tx.status),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      tx.status.apiValue,
                                      style: TextStyle(
                                        color: _txStatusFg(tx.status),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text('${tx.chain.label} · ${_formatAddress(tx.txHash ?? tx.txId)}'),
                              const SizedBox(height: 4),
                              Text('To: ${_formatAddress(tx.toAddress)}'),
                            ],
                          ),
                        ),
                      ),
                  if (filteredTransactions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: _buildEmptyState(
                        icon: provider.recentTransactions.isEmpty
                            ? Icons.receipt_long_outlined
                            : Icons.filter_alt_off_outlined,
                        title: provider.recentTransactions.isEmpty
                            ? 'No on-chain activity yet'
                            : 'No transactions match these filters',
                        message: provider.recentTransactions.isEmpty
                            ? 'Deposits you submit will appear here so users can review status and confirmations.'
                            : 'Try switching network, type, or sort to surface the transactions you need.',
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
