import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/core/utils/onchain_tx_status_ui.dart';
import 'package:crypto_trading_app/core/widgets/app_dropdown_field.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/onchain_transaction.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/onchain_tx_status.dart';
import 'package:crypto_trading_app/features/blockchain/presentation/providers/blockchain_provider.dart';
import 'package:crypto_trading_app/features/managed_wallets/presentation/providers/managed_wallets_provider.dart';
import 'package:crypto_trading_app/features/treasury/presentation/widgets/treasury_chain_dropdown.dart';
import 'package:crypto_trading_app/features/treasury/presentation/providers/onchain_chain_picker_provider.dart';
import 'package:crypto_trading_app/features/admin/payment_config/presentation/providers/payment_config_provider.dart';
import 'package:crypto_trading_app/features/deposits/presentation/widgets/deposit_methods_card.dart';
import 'package:crypto_trading_app/features/blockchain/presentation/widgets/onchain_sandbox_operator_banner.dart';
import 'package:crypto_trading_app/features/blockchain/presentation/widgets/onchain_tx_filter_chip.dart';
import 'package:crypto_trading_app/features/deposits/presentation/screens/deposits_screen.dart';

class OnchainDepositScreen extends StatefulWidget {
  const OnchainDepositScreen({super.key});

  @override
  State<OnchainDepositScreen> createState() => _OnchainDepositScreenState();
}

class _OnchainDepositScreenState extends State<OnchainDepositScreen> {
  static final DateFormat _dateTimeFmt = DateFormat.yMMMd().add_Hms();
  static final DateFormat _dateTimeCompact = DateFormat('dd/MM/yy HH:mm');

  BlockchainNetwork? _txFilterNetwork;

  /// Default: chỉ lịch sử nạp tiền (DEPOSIT). FUND/SWEEP là quỹ nội bộ, không hiển thị ở API consumer.
  OnchainTxType? _txFilterType = OnchainTxType.deposit;
  bool _sortNewestFirst = true;
  Timer? _txListPoll;

  PaymentConfigProvider? _paymentConfigProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final picker = context.read<OnchainChainPickerProvider>();
      await picker.ensureLoaded();
      if (!mounted) return;
      _paymentConfigProvider = context.read<PaymentConfigProvider>();
      _paymentConfigProvider!.addListener(_onPaymentConfigChanged);
      _startDepositTxPolling();
    });
  }

  void _startDepositTxPolling() {
    _txListPoll?.cancel();
    if (!mounted) return;
    final prov = context.read<BlockchainProvider>();
    prov.fetchRecentTransactions();
    _txListPoll = Timer.periodic(const Duration(seconds: 25), (_) {
      if (!mounted) return;
      context.read<BlockchainProvider>().fetchRecentTransactions();
    });
  }

  void _onPaymentConfigChanged() {
    final event = _paymentConfigProvider?.latestEvent;
    if (event?.event == 'ACTIVATED' && mounted) {
      context.read<BlockchainProvider>().fetchRecentTransactions();
      context.read<ManagedWalletsProvider>().fetchDepositMethods();
    }
  }

  String _ellipsizeMiddle(String value, {int head = 10, int tail = 8}) {
    if (value.length <= head + tail + 1) return value;
    return '${value.substring(0, head)}…${value.substring(value.length - tail)}';
  }

  Future<void> _copyValue(String value) async {
    if (value.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    showAppSnackBar(
      context,
      message: AppLocalizations.of(context).depositDetailCopied,
      type: SnackBarType.success,
    );
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
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
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

  Widget _detailCopyBlock(
    AppLocalizations l10n, {
    required String label,
    required String value,
  }) {
    final hasValue = value.isNotEmpty;
    final display = hasValue ? value : l10n.onchainValueNotAvailable;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              letterSpacing: 0.15,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SelectableText(
                  display,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                    color: hasValue ? Colors.black87 : Colors.grey.shade600,
                  ),
                ),
              ),
              if (hasValue)
                IconButton(
                  tooltip: l10n.copyAddressTooltip,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => _copyValue(value),
                  icon: Icon(Icons.copy, size: 18, color: Colors.grey.shade700),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailPlainLine(
    AppLocalizations l10n, {
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, height: 1.25),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    AppLocalizations l10n,
    OnchainTransaction tx,
  ) {
    final hash = (tx.txHash ?? '').trim();
    final createdStr = _dateTimeFmt.format(tx.createdAt.toLocal());
    final createdShort = _dateTimeCompact.format(tx.createdAt.toLocal());
    final confirmedStr = tx.confirmedAt != null
        ? _dateTimeFmt.format(tx.confirmedAt!.toLocal())
        : l10n.onchainValueNotAvailable;

    final picker = context.read<OnchainChainPickerProvider>();
    final hashPreview = hash.isNotEmpty
        ? _ellipsizeMiddle(hash)
        : l10n.onchainValueNotAvailable;
    final subtitle =
        '${picker.displayLabelForNetwork(tx.chain)} · $hashPreview · $createdShort';

    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  '${_typeLabel(tx.type)} · ${FormatUtils.formatDecimalAmountDisplay(tx.amount)} ${tx.chain.nativeSymbol}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _txStatusBg(tx.status),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  onchainTxStatusUiLabel(l10n, tx.status),
                  style: TextStyle(
                    color: _txStatusFg(tx.status),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 3, right: 4),
            child: Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                height: 1.25,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          children: [
            if (tx.creditedAmount != null &&
                tx.conversionRate != null &&
                tx.conversionRate!.isNotEmpty) ...[
              SelectableText(
                l10n.onchainCreditConversionLine(
                  FormatUtils.formatDecimalAmountDisplay(tx.creditedAmount!),
                  tx.chain.nativeSymbol,
                  FormatUtils.formatDecimalAmountDisplay(tx.conversionRate!),
                ),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade800,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
            ] else if (tx.creditedAmount != null) ...[
              Text(
                '→ ${FormatUtils.formatDecimalAmountDisplay(tx.creditedAmount!)} USDT',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF0F8A49),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
            ],
            _detailPlainLine(
              l10n,
              label: l10n.networkLabel,
              value: picker.displayLabelForNetwork(tx.chain),
            ),
            _detailPlainLine(
              l10n,
              label: l10n.onchainFieldConfirmations,
              value: '${tx.confirmations}',
            ),
            _detailPlainLine(
              l10n,
              label: l10n.onchainFieldCreatedAt,
              value: createdStr,
            ),
            _detailPlainLine(
              l10n,
              label: l10n.onchainFieldConfirmedAt,
              value: confirmedStr,
            ),
            _detailCopyBlock(
              l10n,
              label: l10n.onchainFieldInternalId,
              value: tx.txId,
            ),
            _detailCopyBlock(
              l10n,
              label: l10n.transactionHashLabel,
              value: hash,
            ),
            _detailCopyBlock(
              l10n,
              label: l10n.onchainFieldFromAddress,
              value: tx.fromAddress,
            ),
            _detailCopyBlock(
              l10n,
              label: l10n.onchainFieldToAddress,
              value: tx.toAddress,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _txListPoll?.cancel();
    _paymentConfigProvider?.removeListener(_onPaymentConfigChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final paymentConfig = context.watch<PaymentConfigProvider>();
    final isBlockchainTransitioning = paymentConfig.isAnyTransitioning &&
        (paymentConfig.transitioningType == 'TRON' ||
            paymentConfig.transitioningType == 'ETH' ||
            paymentConfig.transitioningType == 'SOL' ||
            paymentConfig.transitioningType == null);

    return Consumer<BlockchainProvider>(
      builder: (context, provider, _) {
        final menuHeight = MediaQuery.sizeOf(context).height * 0.35;
        final networks = context
            .watch<OnchainChainPickerProvider>()
            .onchainDepositWithdrawNetworks;
        final filteredTransactions =
            _filteredTransactions(provider.recentTransactions);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isBlockchainTransitioning)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              paymentConfig
                                  .onchainTransitioningDepositBannerText(l10n),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade800),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.onchainAutoConfirmBanner,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Text(
                l10n.onchainDepositMonitorTitle,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.onchainDepositMonitorDesc,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              const DepositMethodsCard(),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FD),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF90B8F5)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Color(0xFF0A5DC2),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.depositOnchainHint,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF0A3A8A),
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        '${l10n.payosNeedFiatTitle} ${l10n.payosNeedFiatDesc}',
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.3,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const DepositsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.account_balance_wallet_outlined),
                      label: Text(l10n.payosTopupVnd),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              OnchainSandboxOperatorBanner(l10n: l10n),
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
              AppDropdownField<OnchainTxType?>(
                value: _txFilterType,
                labelText: l10n.type,
                hintText: l10n.allTypes,
                menuMaxHeight: menuHeight,
                items: [
                  DropdownMenuItem<OnchainTxType?>(
                    value: null,
                    child: Text(
                      l10n.allTypes,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DropdownMenuItem<OnchainTxType?>(
                    value: OnchainTxType.deposit,
                    child: Text(
                      l10n.txTypeDeposits,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DropdownMenuItem<OnchainTxType?>(
                    value: OnchainTxType.transfer,
                    child: Text(
                      l10n.txTypeTransfers,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _txFilterType = value);
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
                    onSelected: (_) => setState(() => _sortNewestFirst = true),
                  ),
                  const SizedBox(width: 6),
                  onchainTxFilterChip(
                    context: context,
                    label: l10n.sortOldest,
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
                    .take(20)
                    .map((tx) => _buildTransactionCard(context, l10n, tx)),
                if (filteredTransactions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: _buildEmptyState(
                      icon: provider.recentTransactions.isEmpty
                          ? Icons.receipt_long_outlined
                          : Icons.filter_alt_off_outlined,
                      title: provider.recentTransactions.isEmpty
                          ? l10n.noOnchainActivityTitle
                          : l10n.noTxMatchFilters,
                      message: provider.recentTransactions.isEmpty
                          ? l10n.noOnchainActivityDesc
                          : l10n.trySwitchingFiltersDeposit,
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}
