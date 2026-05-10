import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/core/utils/onchain_tx_status_ui.dart';
import 'package:crypto_trading_app/core/widgets/app_empty_state.dart';
import 'package:crypto_trading_app/core/widgets/app_dropdown_field.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/blockchain_dtos.dart';
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

  // ── Manual txHash submit form ──────────────────────────────────────────────
  final _txHashController = TextEditingController();
  bool _showManualForm = false;
  DepositPreviewResponse? _pendingPreview;
  String? _previewError;
  bool _isSubmittingDeposit = false;

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

  // ── Manual txHash submit handlers ─────────────────────────────────────────

  void _resetManualForm() {
    setState(() {
      _txHashController.clear();
      _pendingPreview = null;
      _previewError = null;
      _showManualForm = false;
    });
  }

  Future<void> _previewDepositTx() async {
    final txHash = _txHashController.text.trim();
    if (txHash.isEmpty) {
      setState(() {
        _previewError = AppLocalizations.of(context).txHashRequired;
        _pendingPreview = null;
      });
      return;
    }

    final prov = context.read<BlockchainProvider>();
    final selectedChain = _txFilterNetwork ?? BlockchainNetwork.tronNile;

    final preview = await prov.previewDeposit(selectedChain, txHash);
    if (!mounted) return;

    setState(() {
      if (preview != null) {
        _pendingPreview = preview;
        _previewError = null;
      } else {
        _pendingPreview = null;
        _previewError = prov.error ?? AppLocalizations.of(context).txHashRequired;
      }
    });
  }

  Future<void> _submitDepositTx() async {
    final preview = _pendingPreview;
    if (preview == null) return;

    setState(() => _isSubmittingDeposit = true);

    final ok = await context.read<BlockchainProvider>().submitDeposit(
          chain: preview.chain,
          txHash: preview.txHash,
          amount: preview.onchainAmount,
        );

    if (!mounted) return;
    setState(() => _isSubmittingDeposit = false);

    showAppSnackBar(
      context,
      message: ok
          ? AppLocalizations.of(context).depositSubmittedSuccess
          : (context.read<BlockchainProvider>().error ??
              AppLocalizations.of(context).depositFailed),
      type: ok ? SnackBarType.success : SnackBarType.error,
    );

    if (ok) {
      _resetManualForm();
      context.read<BlockchainProvider>().fetchRecentTransactions();
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
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
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

  Widget _detailCopyBlock(
    AppLocalizations l10n, {
    required String label,
    required String value,
  }) {
    final hasValue = value.isNotEmpty;
    final display = hasValue ? value : l10n.onchainValueNotAvailable;
    final scheme = Theme.of(context).colorScheme;

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
              color: scheme.onSurfaceVariant,
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
                    color: hasValue ? scheme.onSurface : scheme.onSurfaceVariant,
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
                  icon: Icon(Icons.copy, size: 18, color: scheme.primary),
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
    final scheme = Theme.of(context).colorScheme;

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
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12, height: 1.25, color: scheme.onSurface),
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
    final scheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: scheme.outlineVariant),
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
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    height: 1.2,
                    color: scheme.onSurface,
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
                color: scheme.onSurfaceVariant,
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
                  color: scheme.onSurface,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
            ] else if (tx.creditedAmount != null) ...[
              Text(
                '→ ${FormatUtils.formatDecimalAmountDisplay(tx.creditedAmount!)} USDT',
                style: TextStyle(
                  fontSize: 11.5,
                  color: scheme.primary,
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
    _txHashController.dispose();
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
              const SizedBox(height: 12),

              // ── Manual txHash submit form ───────────────────────────────────
              if (_showManualForm)
                _ManualDepositFormWidget(
                  txHashController: _txHashController,
                  preview: _pendingPreview,
                  previewError: _previewError,
                  isSubmitting: _isSubmittingDeposit,
                  isLoadingPreview: provider.isLoading,
                  onPreview: _previewDepositTx,
                  onSubmit: _submitDepositTx,
                  onCancel: _resetManualForm,
                  l10n: l10n,
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _showManualForm = true),
                    icon: const Icon(Icons.qr_code_scanner, size: 18),
                    label: Text(l10n.submitOnchainDeposit),
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

// ── Manual txHash submit form widget ──────────────────────────────────────────

class _ManualDepositFormWidget extends StatelessWidget {
  final TextEditingController txHashController;
  final DepositPreviewResponse? preview;
  final String? previewError;
  final bool isSubmitting;
  final bool isLoadingPreview;
  final VoidCallback onPreview;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  final AppLocalizations l10n;

  const _ManualDepositFormWidget({
    required this.txHashController,
    required this.preview,
    required this.previewError,
    required this.isSubmitting,
    required this.isLoadingPreview,
    required this.onPreview,
    required this.onSubmit,
    required this.onCancel,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = previewError != null && preview == null;
    final hasPreview = preview != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF90B8F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.qr_code_scanner, size: 20, color: Color(0xFF0A5DC2)),
              const SizedBox(width: 8),
              Text(
                l10n.submitOnchainDeposit,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Color(0xFF0A3A8A),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: onCancel,
                visualDensity: VisualDensity.compact,
                tooltip: l10n.close,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // TxHash input
          TextField(
            controller: txHashController,
            decoration: InputDecoration(
              labelText: l10n.transactionHashLabel,
              hintText: 'e.g. abc123def456...',
              border: const OutlineInputBorder(),
              isDense: true,
              errorText: hasError ? previewError : null,
            ),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            maxLines: 1,
          ),
          const SizedBox(height: 10),

          // Preview / Submit buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoadingPreview ? null : onPreview,
                  child: isLoadingPreview
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Preview'),
                ),
              ),
              if (hasPreview) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: isSubmitting ? null : onSubmit,
                    child: isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(l10n.submit),
                  ),
                ),
              ],
            ],
          ),

          // Preview result card
          if (hasPreview) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.depositPreviewLabel(preview!.status, preview!.onchainAmount),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF0F8A49),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _PreviewRow(label: l10n.networkLabel, value: preview!.chain.label),
                  _PreviewRow(
                    label: l10n.transactionHashLabel,
                    value: preview!.txHash.length > 20
                        ? '${preview!.txHash.substring(0, 12)}...${preview!.txHash.substring(preview!.txHash.length - 8)}'
                        : preview!.txHash,
                  ),
                  if (preview!.fromAddress.isNotEmpty)
                    _PreviewRow(label: 'From', value: preview!.fromAddress),
                  _PreviewRow(label: 'To', value: preview!.toAddress),
                  const SizedBox(height: 4),
                  if (!preview!.senderLinked)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber,
                              size: 14, color: Color(0xFFB56900)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              l10n.depositPreviewNotLinked,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFB56900),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],

          if (hasError) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFDECEF),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      size: 16, color: Color(0xFFB3261E)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      previewError!,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFFB3261E)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
