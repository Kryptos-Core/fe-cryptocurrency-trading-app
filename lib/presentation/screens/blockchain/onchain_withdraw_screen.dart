import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/utils/currency_amount_input.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/core/utils/onchain_tx_status_ui.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/linked_wallet_status.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/onchain_transaction.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/onchain_tx_status.dart';
import 'package:crypto_trading_app/presentation/constants/treasury_chains.dart';
import 'package:crypto_trading_app/presentation/providers/blockchain_provider.dart';
import 'package:crypto_trading_app/presentation/providers/onchain_chain_picker_provider.dart';
import 'package:crypto_trading_app/presentation/widgets/app_dropdown_field.dart';
import 'package:crypto_trading_app/presentation/widgets/onchain_network_dropdown_menu_child.dart';
import 'package:crypto_trading_app/presentation/widgets/onchain_sandbox_operator_banner.dart';
import 'package:crypto_trading_app/presentation/widgets/onchain_tx_filter_chip.dart';

class OnchainWithdrawScreen extends StatefulWidget {
  const OnchainWithdrawScreen({super.key});

  @override
  State<OnchainWithdrawScreen> createState() => _OnchainWithdrawScreenState();
}

class _OnchainWithdrawScreenState extends State<OnchainWithdrawScreen> {
  bool get _suppressSandboxInNetworkDropdown =>
      dotenv.isInitialized &&
      parseOnChainOperatorMode(dotenv.env) == OnChainOperatorMode.sandbox;

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  late BlockchainNetwork _selectedNetwork;
  String? _selectedWalletId;
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
      case OnchainTxStatus.unknown:
        return const Color(0xFFF1F5F9);
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
      case OnchainTxStatus.unknown:
        return const Color(0xFF64748B);
    }
  }

  List<OnchainTransaction> _filteredTransactions(
    List<OnchainTransaction> source,
  ) {
    final filtered = source.where((tx) {
      final byNetwork =
          _txFilterNetwork == null || tx.chain == _txFilterNetwork;
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
    final l10n = AppLocalizations.of(context);
    if (type == null) return l10n.allTypes;
    switch (type) {
      case OnchainTxType.deposit:
        return l10n.txTypeDeposits;
      case OnchainTxType.withdrawal:
        return l10n.txTypeWithdrawals;
      case OnchainTxType.transfer:
        return l10n.txTypeTransfers;
      case OnchainTxType.fund:
        return l10n.txTypeFund;
      case OnchainTxType.sweep:
        return l10n.txTypeSweep;
      case OnchainTxType.unknown:
        return l10n.txTypeUnknown;
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
  void initState() {
    super.initState();
    _selectedNetwork = onchainDepositWithdrawNetworksForCurrentEnv().first;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final picker = context.read<OnchainChainPickerProvider>();
      await picker.ensureLoaded();
      if (!mounted) return;
      final nets = picker.onchainDepositWithdrawNetworks;
      if (nets.isNotEmpty && !nets.contains(_selectedNetwork)) {
        setState(() {
          _selectedNetwork = nets.first;
          _selectedWalletId = null;
        });
      }
      context.read<BlockchainProvider>().fetchLinkedWallets();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWalletId == null) {
      showAppSnackBar(
        context,
        message: AppLocalizations.of(context).selectDestinationWallet,
        type: SnackBarType.warning,
      );
      return;
    }

    final provider = context.read<BlockchainProvider>();
    final ok = await provider.requestWithdrawal(
      chain: _selectedNetwork,
      linkedWalletId: _selectedWalletId!,
      amount: _amountController.text.trim(),
    );

    if (!mounted) return;

    showAppSnackBar(
      context,
      message: ok
          ? AppLocalizations.of(context).withdrawalRequestSubmitted
          : (provider.error ?? AppLocalizations.of(context).requestFailed),
      type: ok ? SnackBarType.success : SnackBarType.error,
    );

    if (ok) {
      _amountController.clear();
      await provider.fetchRecentTransactions();
    }
  }

  @override
  Widget build(BuildContext outerContext) {
    return Consumer<BlockchainProvider>(
      builder: (context, provider, _) {
        final l10n = AppLocalizations.of(context);
        final networks = context
            .watch<OnchainChainPickerProvider>()
            .onchainDepositWithdrawNetworks;
        final wallets = provider.linkedWallets
            .where(
              (wallet) =>
                  wallet.chain == _selectedNetwork &&
                  wallet.status == LinkedWalletStatus.verified,
            )
            .toList();
        final filteredTransactions =
            _filteredTransactions(provider.recentTransactions);

        if (_selectedWalletId != null &&
            wallets.every((wallet) => wallet.linkId != _selectedWalletId)) {
          _selectedWalletId = null;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.requestOnchainWithdrawal,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(l10n.withdrawalDestinationDesc),
                const SizedBox(height: 16),
                OnchainSandboxOperatorBanner(l10n: l10n),
                AppDropdownField<BlockchainNetwork>(
                  value: _selectedNetwork,
                  menuMaxHeight: 300,
                  labelText: l10n.networkLabel,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  items: networks
                      .map(
                        (network) => DropdownMenuItem(
                          value: network,
                          child: OnchainNetworkDropdownMenuChild(
                            network: network,
                            l10n: l10n,
                            suppressSandboxSuffix:
                                _suppressSandboxInNetworkDropdown,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedNetwork = value;
                        _selectedWalletId = null;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                AppDropdownField<String>(
                  value: _selectedWalletId,
                  menuMaxHeight: 300,
                  labelText: l10n.linkedWalletDropdownLabel,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  items: wallets
                      .map(
                        (wallet) => DropdownMenuItem<String>(
                          value: wallet.linkId,
                          child: Text(
                            _formatAddress(wallet.address),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: wallets.isEmpty
                      ? null
                      : (value) => setState(() => _selectedWalletId = value),
                ),
                if (wallets.isEmpty) ...[
                  const SizedBox(height: 8),
                  _buildEmptyState(
                    icon: Icons.account_balance_wallet_outlined,
                    title: l10n.noVerifiedWalletTitle,
                    message: l10n.noVerifiedWalletDesc,
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: CurrencyAmountInput.withCurrencySuffix(
                    context,
                    InputDecoration(
                      labelText: l10n.amount,
                      border: const OutlineInputBorder(),
                    ),
                    currencySymbol: _selectedNetwork.nativeSymbol,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.amountRequired;
                    }
                    final n = double.tryParse(value.trim());
                    if (n == null || n <= 0) {
                      return l10n.amountMustBePositive;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: provider.isSubmitting ? null : _submit,
                    icon: const Icon(Icons.call_made),
                    label: Text(provider.isSubmitting
                        ? l10n.submitting
                        : l10n.requestWithdrawalAction),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.recentTransactions,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    onchainTxFilterChip(
                      context: context,
                      label: l10n.allNetworks,
                      selected: _txFilterNetwork == null,
                      onSelected: (_) =>
                          setState(() => _txFilterNetwork = null),
                    ),
                    ...networks.map(
                      (network) => onchainTxFilterChip(
                        context: context,
                        label: onchainRecentTxNetworkChipLabel(network),
                        selected: _txFilterNetwork == network,
                        onSelected: (_) =>
                            setState(() => _txFilterNetwork = network),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    onchainTxFilterChip(
                      context: context,
                      label: l10n.allTypes,
                      selected: _txFilterType == null,
                      onSelected: (_) => setState(() => _txFilterType = null),
                    ),
                    ...OnchainTxType.values
                        .where((t) => t != OnchainTxType.unknown)
                        .map(
                          (type) => onchainTxFilterChip(
                            context: context,
                            label: _typeLabel(type),
                            selected: _txFilterType == type,
                            onSelected: (_) =>
                                setState(() => _txFilterType = type),
                          ),
                        ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      l10n.txResultCount(filteredTransactions.length),
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const Spacer(),
                    onchainTxFilterChip(
                      context: context,
                      label: l10n.sortNewest,
                      selected: _sortNewestFirst,
                      onSelected: (_) =>
                          setState(() => _sortNewestFirst = true),
                    ),
                    const SizedBox(width: 6),
                    onchainTxFilterChip(
                      context: context,
                      label: l10n.sortOldest,
                      selected: !_sortNewestFirst,
                      onSelected: (_) =>
                          setState(() => _sortNewestFirst = false),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (provider.isLoading)
                  _buildRecentSkeleton()
                else ...[
                  ...filteredTransactions.take(10).map(
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
                                      '${_typeLabel(tx.type)} · ${FormatUtils.formatDecimalAmountDisplay(tx.amount)}',
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
                                      onchainTxStatusUiLabel(l10n, tx.status),
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
                              Text(
                                  '${tx.chain.label} · ${_formatAddress(tx.txHash ?? tx.txId)}'),
                              const SizedBox(height: 4),
                              Text(l10n
                                  .txToAddress(_formatAddress(tx.toAddress))),
                            ],
                          ),
                        ),
                      ),
                  if (filteredTransactions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: _buildEmptyState(
                        icon: provider.recentTransactions.isEmpty
                            ? Icons.call_made_outlined
                            : Icons.filter_alt_off_outlined,
                        title: provider.recentTransactions.isEmpty
                            ? l10n.noWithdrawalActivityTitle
                            : l10n.noTxMatchFilters,
                        message: provider.recentTransactions.isEmpty
                            ? l10n.noWithdrawalActivityDesc
                            : l10n.tryAnotherFilter,
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
