import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/utils/currency_amount_input.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/core/utils/onchain_tx_status_ui.dart';
import 'package:crypto_trading_app/core/widgets/app_empty_state.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/linked_wallet_status.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/onchain_transaction.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/onchain_tx_status.dart';
import 'package:crypto_trading_app/features/treasury/presentation/widgets/treasury_chain_dropdown.dart';
import 'package:crypto_trading_app/features/blockchain/presentation/providers/blockchain_provider.dart';
import 'package:crypto_trading_app/features/treasury/presentation/providers/onchain_chain_picker_provider.dart';
import 'package:crypto_trading_app/features/treasury/presentation/providers/treasury_provider.dart';
import 'package:crypto_trading_app/core/widgets/app_dropdown_field.dart';
import 'package:crypto_trading_app/features/blockchain/presentation/widgets/onchain_network_dropdown_menu_child.dart';
import 'package:crypto_trading_app/features/blockchain/presentation/widgets/onchain_sandbox_operator_banner.dart';
import 'package:crypto_trading_app/features/blockchain/presentation/widgets/onchain_tx_filter_chip.dart';
import 'package:crypto_trading_app/features/treasury/presentation/constants/treasury_chains.dart';

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

  BlockchainNetwork? _selectedNetwork;
  String? _selectedWalletId;
  BlockchainNetwork? _txFilterNetwork;
  OnchainTxType _txFilterType = OnchainTxType.withdrawal;
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
      case OnchainTxStatus.txBroadcast:
        return const Color(0xFFEAF2FD);
      case OnchainTxStatus.pending:
        return const Color(0xFFFFF6E8);
      case OnchainTxStatus.failed:
        return const Color(0xFFFDECEF);
      case OnchainTxStatus.unmatched:
        return const Color(0xFFFFF6E8);
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
      case OnchainTxStatus.txBroadcast:
        return const Color(0xFF0A5DC2);
      case OnchainTxStatus.pending:
        return const Color(0xFFB56900);
      case OnchainTxStatus.failed:
        return const Color(0xFFB3261E);
      case OnchainTxStatus.unmatched:
        return const Color(0xFFB56900);
      case OnchainTxStatus.unknown:
        return const Color(0xFF64748B);
    }
  }

  List<OnchainTransaction> _filteredTransactions(
    List<OnchainTransaction> source,
  ) {
    final filtered = source.where((tx) {
      final byType = tx.type == _txFilterType;
      final byNetwork =
          _txFilterNetwork == null || tx.chain == _txFilterNetwork;
      return byType && byNetwork;
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
    return AppEmptyState(
      message: message,
      icon: icon,
      title: title,
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
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 220,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 160,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final chainPicker = context.read<OnchainChainPickerProvider>();
      final treasuryProvider = context.read<TreasuryProvider>();
      await chainPicker.ensureLoaded();
      await treasuryProvider.loadWallets();

      if (!mounted) return;
      context.read<BlockchainProvider>().fetchLinkedWallets();

      final networks = chainPicker.onchainDepositWithdrawNetworks;
      final treasuryWallets = treasuryProvider.wallets;
      final withdrawalWalletChains = treasuryWallets
          .where((w) =>
              w.isActive &&
              (w.purpose == 'WITHDRAWAL' || w.purpose == 'BOTH'))
          .map((w) => w.chain)
          .toSet()
          .toList();
      final withdrawalNetworks = networks
          .where((network) => withdrawalWalletChains.contains(network.apiValue))
          .toList();

      if (withdrawalNetworks.isNotEmpty) {
        setState(() {
          _selectedNetwork = withdrawalNetworks.first;
        });
      }
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

    final selectedNetwork = _selectedNetwork;
    if (selectedNetwork == null) {
      showAppSnackBar(
        context,
        message: AppLocalizations.of(context).selectNetworkFirst,
        type: SnackBarType.warning,
      );
      return;
    }

    final provider = context.read<BlockchainProvider>();
    final ok = await provider.requestWithdrawal(
      chain: selectedNetwork,
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
    return Consumer2<BlockchainProvider, TreasuryProvider>(
      builder: (context, provider, treasuryProvider, _) {
        final l10n = AppLocalizations.of(context);
        final menuHeight = MediaQuery.sizeOf(context).height * 0.35;
        final allNetworks = context
            .watch<OnchainChainPickerProvider>()
            .onchainDepositWithdrawNetworks;

        final treasuryWallets = treasuryProvider.wallets;
        final withdrawalWalletChains = treasuryWallets
            .where((w) =>
                w.isActive &&
                (w.purpose == 'WITHDRAWAL' || w.purpose == 'BOTH'))
            .map((w) => w.chain)
            .toSet()
            .toList();

        final withdrawalNetworks = allNetworks
            .where((network) => withdrawalWalletChains.contains(network.apiValue))
            .toList();

        if (withdrawalNetworks.isEmpty) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.requestOnchainWithdrawal,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                OnchainSandboxOperatorBanner(l10n: l10n),
                const SizedBox(height: 16),
                _buildEmptyState(
                  icon: Icons.account_balance_wallet_outlined,
                  title: l10n.noVerifiedWalletTitle,
                  message: l10n.noVerifiedWalletDesc,
                ),
              ],
            ),
          );
        }

        final networks = withdrawalNetworks;

        final effectiveNetwork = networks.contains(_selectedNetwork)
            ? _selectedNetwork!
            : networks.isNotEmpty
                ? networks.first
                : null;

        final wallets = provider.linkedWallets
            .where(
              (wallet) =>
                  wallet.chain == effectiveNetwork &&
                  wallet.status == LinkedWalletStatus.verified,
            )
            .toList();
        final filteredTransactions =
            _filteredTransactions(provider.recentTransactions);

        if (_selectedWalletId != null &&
            wallets.every((wallet) => wallet.linkId != _selectedWalletId)) {
          _selectedWalletId = null;
        }

        if (effectiveNetwork == null) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.requestOnchainWithdrawal,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                OnchainSandboxOperatorBanner(l10n: l10n),
                const SizedBox(height: 16),
                _buildEmptyState(
                  icon: Icons.account_balance_wallet_outlined,
                  title: l10n.noVerifiedWalletTitle,
                  message: l10n.noVerifiedWalletDesc,
                ),
              ],
            ),
          );
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
                if (!treasuryChainsUseMainnetOnly)
                  AppDropdownField<BlockchainNetwork>(
                    value: effectiveNetwork,
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
                    currencySymbol: effectiveNetwork.withdrawSymbol,
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
                const SizedBox(height: 6),
                TreasuryChainDropdown(
                  chains: networks.map((n) => n.apiValue).toList(),
                  value: _txFilterNetwork?.apiValue,
                  allowAllOption: true,
                  labelText: l10n.networkLabel,
                  hintText: l10n.allNetworks,
                  allOptionLabel: l10n.allNetworks,
                  menuMaxHeight: menuHeight,
                  onChanged: (value) {
                    setState(
                      () => _txFilterNetwork = value == null
                          ? null
                          : BlockchainNetworkX.tryFromApiValue(value),
                    );
                  },
                ),
                const SizedBox(height: 8),
                AppDropdownField<OnchainTxType>(
                  value: _txFilterType,
                  labelText: l10n.type,
                  hintText: l10n.txTypeWithdrawals,
                  menuMaxHeight: menuHeight,
                  items: [
                    DropdownMenuItem<OnchainTxType>(
                      value: OnchainTxType.withdrawal,
                      child: Text(
                        l10n.txTypeWithdrawals,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropdownMenuItem<OnchainTxType>(
                      value: OnchainTxType.transfer,
                      child: Text(
                        l10n.txTypeTransfers,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _txFilterType = value);
                    }
                  },
                ),
                const SizedBox(height: 8),
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
                        (tx) {
                          final scheme = Theme.of(context).colorScheme;
                          final formattedAmount = FormatUtils.formatDecimalAmountDisplay(tx.amount);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Material(
                              color: scheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () => _WithdrawalDetailSheet.show(context, tx),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: scheme.outlineVariant),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${_typeLabel(tx.type)} · $formattedAmount',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: scheme.onSurface,
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
                                          '${context.read<OnchainChainPickerProvider>().displayLabelForNetwork(tx.chain)} · ${_formatAddress(tx.txHash ?? tx.txId)}',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color: scheme.onSurfaceVariant,
                                          )),
                                      const SizedBox(height: 4),
                                      Text(l10n
                                          .txToAddress(_formatAddress(tx.toAddress)),
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color: scheme.onSurfaceVariant,
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
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

// ── _WithdrawalDetailSheet ───────────────────────────────────────────────────

class _WithdrawalDetailSheet extends StatelessWidget {
  final OnchainTransaction tx;

  const _WithdrawalDetailSheet({required this.tx});

  static void show(BuildContext context, OnchainTransaction tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _WithdrawalDetailSheet(tx: tx),
    );
  }

  (Color, String) _statusInfo(AppLocalizations l10n, String s) {
    switch (s) {
      case 'COMPLETED':
        return (Colors.green, l10n.onchainTxStatusCompleted);
      case 'CONFIRMING':
        return (Colors.blue, l10n.onchainTxStatusConfirming);
      case 'PENDING':
        return (Colors.orange, l10n.onchainTxStatusPending);
      case 'FAILED':
        return (Colors.red, l10n.onchainTxStatusFailed);
      default:
        return (Colors.grey, s);
    }
  }

  String _typeLabel(AppLocalizations l10n, OnchainTxType type) {
    switch (type) {
      case OnchainTxType.withdrawal:
        return l10n.txTypeWithdrawals;
      case OnchainTxType.deposit:
        return l10n.txTypeDeposits;
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final chainPicker = context.read<OnchainChainPickerProvider>();

    final (statusColor, statusLabel) = _statusInfo(l10n, tx.status.apiValue);
    final networkLabel = chainPicker.displayLabelForNetwork(tx.chain);
    final formattedAmount = FormatUtils.formatDecimalAmountDisplay(tx.amount);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.red.withValues(alpha: 0.12),
                  child: const Icon(Icons.call_made, color: Colors.red, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.withdrawalDetailTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(16),
              children: [
                // Type + Amount card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _typeLabel(l10n, tx.type),
                                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '-$formattedAmount',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            networkLabel,
                            style: TextStyle(
                              color: cs.onPrimaryContainer,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Detail rows card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.withdrawalDetailInfoTitle,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        _DetailRow(
                          label: l10n.withdrawalDetailStatus,
                          value: statusLabel,
                          valueColor: statusColor,
                        ),
                        _DetailRow(
                          label: l10n.withdrawalDetailChain,
                          value: networkLabel,
                        ),
                        _DetailRow(
                          label: l10n.withdrawalDetailToAddress,
                          value: tx.toAddress,
                          isAddress: true,
                        ),
                        if (tx.txHash != null && tx.txHash!.isNotEmpty)
                          _DetailRow(
                            label: l10n.withdrawalDetailTxHash,
                            value: tx.txHash!,
                            isAddress: true,
                          ),
                        _DetailRow(
                          label: l10n.withdrawalDetailCreatedAt,
                          value: DateFormat('dd/MM/yyyy HH:mm').format(tx.createdAt.toLocal()),
                        ),
                        if (tx.confirmedAt != null)
                          _DetailRow(
                            label: l10n.withdrawalDetailUpdatedAt,
                            value: DateFormat('dd/MM/yyyy HH:mm').format(tx.confirmedAt!.toLocal()),
                          ),
                        if (tx.confirmations > 0)
                          _DetailRow(
                            label: l10n.withdrawalDetailConfirmations,
                            value: tx.confirmations.toString(),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isAddress;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isAddress = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                fontFamily: isAddress ? 'monospace' : null,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: valueColor ?? cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
