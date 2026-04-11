import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/utils/blockchain_public_error_localization.dart';
import 'package:crypto_trading_app/core/utils/currency_amount_input.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_dtos.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/onchain_transaction.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/onchain_tx_status.dart';
import 'package:crypto_trading_app/presentation/constants/treasury_chains.dart';
import 'package:crypto_trading_app/presentation/providers/blockchain_provider.dart';
import 'package:crypto_trading_app/presentation/providers/onchain_chain_picker_provider.dart';
import 'package:crypto_trading_app/presentation/providers/payment_config_provider.dart';
import 'package:crypto_trading_app/presentation/widgets/app_dropdown_field.dart';
import 'package:crypto_trading_app/presentation/widgets/deposit_address_empty_placeholder.dart';
import 'package:crypto_trading_app/presentation/widgets/deposit_methods_card.dart';
import 'package:crypto_trading_app/presentation/widgets/onchain_network_dropdown_menu_child.dart';
import 'package:crypto_trading_app/presentation/widgets/onchain_sandbox_operator_banner.dart';
import 'package:crypto_trading_app/presentation/widgets/onchain_tx_filter_chip.dart';
import 'package:crypto_trading_app/screens/deposits_screen.dart';

class OnchainDepositScreen extends StatefulWidget {
  const OnchainDepositScreen({super.key});

  @override
  State<OnchainDepositScreen> createState() => _OnchainDepositScreenState();
}

class _OnchainDepositScreenState extends State<OnchainDepositScreen> {
  /// Banner sandbox đã giải thích testnet — bỏ nhãn “Sandbox” trong dropdown.
  bool get _suppressSandboxInNetworkDropdown =>
      dotenv.isInitialized &&
      parseOnChainOperatorMode(dotenv.env) == OnChainOperatorMode.sandbox;

  final _formKey = GlobalKey<FormState>();
  final _txHashController = TextEditingController();
  final _amountController = TextEditingController();
  late BlockchainNetwork _selectedNetwork;
  BlockchainNetwork? _txFilterNetwork;
  OnchainTxType? _txFilterType;
  bool _sortNewestFirst = true;
  DepositAddressResponse? _depositAddress;
  DepositPreviewResponse? _depositPreview;
  bool _showFullDepositAddress = false;
  bool _isAutofillingAmount = false;
  bool _amountTouchedByUser = false;
  Timer? _txPreviewDebounce;

  PaymentConfigProvider? _paymentConfigProvider;

  @override
  void initState() {
    super.initState();
    _selectedNetwork = onchainDepositWithdrawNetworksForCurrentEnv().first;
    _txHashController.addListener(_onTxHashChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final picker = context.read<OnchainChainPickerProvider>();
      await picker.ensureLoaded();
      if (!mounted) return;
      final nets = picker.onchainDepositWithdrawNetworks;
      if (nets.isNotEmpty && !nets.contains(_selectedNetwork)) {
        setState(() {
          _selectedNetwork = nets.first;
          _depositAddress = null;
        });
      }
      _loadDepositAddress();
      _paymentConfigProvider = context.read<PaymentConfigProvider>();
      _paymentConfigProvider!.addListener(_onPaymentConfigChanged);
    });
  }

  void _onPaymentConfigChanged() {
    final event = _paymentConfigProvider?.latestEvent;
    if (event?.event == 'ACTIVATED' && mounted) {
      // Auto-refresh deposit address and QR code when new config activates
      _loadDepositAddress();
    }
  }

  void _onTxHashChanged() {
    _txPreviewDebounce?.cancel();
    final txHash = _txHashController.text.trim();

    if (txHash.length < 16) {
      if (_depositPreview != null && mounted) {
        setState(() {
          _depositPreview = null;
        });
      }
      return;
    }

    _txPreviewDebounce = Timer(const Duration(milliseconds: 700), () async {
      final provider = context.read<BlockchainProvider>();
      final preview = await provider.previewDeposit(_selectedNetwork, txHash);
      if (!mounted) return;

      setState(() {
        _depositPreview = preview;
      });

      if (preview != null && !_amountTouchedByUser && !_isAutofillingAmount) {
        _isAutofillingAmount = true;
        _amountController.text = preview.onchainAmount;
        _isAutofillingAmount = false;
      }
    });
  }

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
  void dispose() {
    _txPreviewDebounce?.cancel();
    _txHashController.removeListener(_onTxHashChanged);
    _txHashController.dispose();
    _amountController.dispose();
    _paymentConfigProvider?.removeListener(_onPaymentConfigChanged);
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_depositPreview != null && !_depositPreview!.senderLinked) {
      showAppSnackBar(
        context,
        message: AppLocalizations.of(context).senderWalletNotLinkedError,
        type: SnackBarType.error,
      );
      return;
    }

    final provider = context.read<BlockchainProvider>();
    final ok = await provider.submitDeposit(
      chain: _selectedNetwork,
      txHash: _txHashController.text.trim(),
      amount: _amountController.text.trim(),
    );

    if (!mounted) return;

    showAppSnackBar(
      context,
      message: ok
          ? AppLocalizations.of(context).depositSubmittedSuccess
          : localizeBlockchainDepositUserMessage(
              AppLocalizations.of(context),
              code: provider.blockchainApiErrorCode,
              serverMessage: provider.error,
            ),
      type: ok ? SnackBarType.success : SnackBarType.error,
    );

    if (ok) {
      _txHashController.clear();
      _amountController.clear();
      _amountTouchedByUser = false;
      _depositPreview = null;
      await provider.fetchRecentTransactions();
    }
  }

  Future<void> _loadDepositAddress({bool forceRefresh = false}) async {
    final provider = context.read<BlockchainProvider>();
    final response = await provider.fetchDepositAddress(
      _selectedNetwork,
      forceRefresh: forceRefresh,
    );

    if (!mounted) return;
    setState(() {
      _depositAddress = response;
    });

    if (response == null &&
        provider.error != null &&
        !suppressDepositAddressUnavailableSnackBar(
          code: provider.blockchainApiErrorCode,
          serverMessage: provider.error,
        )) {
      showAppSnackBar(
        context,
        message: localizeBlockchainDepositUserMessage(
          AppLocalizations.of(context),
          code: provider.blockchainApiErrorCode,
          serverMessage: provider.error,
        ),
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _copyDepositAddress() async {
    final address = _depositAddress?.depositAddress ?? '';
    if (address.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: address));
    if (!mounted) return;

    showAppSnackBar(
      context,
      message: AppLocalizations.of(context).depositAddressCopied,
      type: SnackBarType.success,
    );
  }

  Widget _depositAddressEmptyPlaceholder(
    BlockchainProvider provider,
    AppLocalizations l10n,
  ) {
    final hasErrorOrCode =
        provider.error != null || provider.blockchainApiErrorCode != null;
    final message = hasErrorOrCode
        ? localizeBlockchainDepositUserMessage(
            l10n,
            code: provider.blockchainApiErrorCode,
            serverMessage: provider.error,
          )
        : l10n.couldNotLoadDepositAddress;
    final kind = resolveDepositAddressEmptyKind(
      hasErrorOrCode: hasErrorOrCode,
      code: provider.blockchainApiErrorCode,
      serverMessage: provider.error,
    );
    return DepositAddressEmptyPlaceholder(
      message: message,
      kind: kind,
    );
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
        final networks = context
            .watch<OnchainChainPickerProvider>()
            .onchainDepositWithdrawNetworks;
        final filteredTransactions =
            _filteredTransactions(provider.recentTransactions);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
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
                                    .onchainTransitioningDepositBannerText(
                                        l10n),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Text(
                  l10n.submitOnchainDeposit,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.onchainDepositDesc,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                const DepositMethodsCard(),
                const SizedBox(height: 12),
                // ── FX Conversion Hint ──
                // Giải thích cho user: coin nạp sẽ được quy đổi → USDT vào Ví Tiền
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
                        _depositAddress = null;
                      });
                      _loadDepositAddress();
                    }
                  },
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            l10n.platformDepositAddress,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: provider.isFetchingDepositAddress
                                ? null
                                : () => _loadDepositAddress(forceRefresh: true),
                            tooltip: l10n.refreshAddress,
                            icon: const Icon(Icons.refresh, size: 18),
                          ),
                        ],
                      ),
                      Text(
                        l10n.sendAssetsToAddress(_selectedNetwork.label),
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7E6),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFF2C46D)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                size: 16, color: Color(0xFFB56900)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.onlyTransferSelectedChain,
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF7A4A00)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (provider.isFetchingDepositAddress &&
                          (_depositAddress?.depositAddress ?? '').isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        )
                      else if ((_depositAddress?.depositAddress ?? '')
                          .isNotEmpty) ...[
                        SelectableText(
                          _showFullDepositAddress
                              ? _depositAddress!.depositAddress
                              : _formatAddress(_depositAddress!.depositAddress),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            SizedBox(
                              width: 92,
                              height: 92,
                              child: QrImageView(
                                data: _depositAddress!.depositAddress,
                                version: QrVersions.auto,
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.all(6),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FilledButton.icon(
                                    onPressed: _copyDepositAddress,
                                    icon: const Icon(Icons.copy, size: 16),
                                    label: Text(l10n.copyAddress),
                                  ),
                                  const SizedBox(height: 8),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _showFullDepositAddress =
                                            !_showFullDepositAddress;
                                      });
                                    },
                                    icon: Icon(
                                      _showFullDepositAddress
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 16,
                                    ),
                                    label: Text(
                                      _showFullDepositAddress
                                          ? l10n.hideFullAddress
                                          : l10n.showFullAddress,
                                    ),
                                  ),
                                  if ((_depositAddress?.note ?? '')
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      _depositAddress!.note!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ] else
                        _depositAddressEmptyPlaceholder(provider, l10n),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _txHashController,
                  decoration: InputDecoration(
                    labelText: l10n.transactionHashLabel,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? l10n.txHashRequired
                      : null,
                ),
                if (_depositPreview != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _depositPreview!.senderLinked
                          ? const Color(0xFFEAF8F1)
                          : const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _depositPreview!.senderLinked
                            ? const Color(0xFFB8E6CC)
                            : const Color(0xFFF5C2C7),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.depositPreviewLabel(_depositPreview!.status,
                              _depositPreview!.onchainAmount),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _depositPreview!.senderLinked
                              ? l10n.depositPreviewLinked
                              : l10n.depositPreviewNotLinked,
                          style: TextStyle(
                            fontSize: 12,
                            color: _depositPreview!.senderLinked
                                ? const Color(0xFF0F8A49)
                                : const Color(0xFFB3261E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  onChanged: (_) {
                    if (!_isAutofillingAmount) {
                      _amountTouchedByUser = true;
                    }
                  },
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
                    onPressed: provider.isSubmitting ||
                            (_depositPreview != null &&
                                !_depositPreview!.senderLinked)
                        ? null
                        : _submit,
                    icon: const Icon(Icons.upload_file),
                    label: Text(provider.isSubmitting
                        ? l10n.submitting
                        : l10n.submitOnchainDeposit),
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
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${tx.type.apiValue} · ${FormatUtils.formatDecimalAmountDisplay(tx.amount)} ${tx.chain.nativeSymbol}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        // Hiển thị số USDT được credit nếu là deposit đã quy đổi
                                        if (tx.hasFxConversion) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            '→ ${FormatUtils.formatDecimalAmountDisplay(tx.creditedAmount ?? '0')} USDT',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF0F8A49),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ],
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
                            ? Icons.receipt_long_outlined
                            : Icons.filter_alt_off_outlined,
                        title: provider.recentTransactions.isEmpty
                            ? l10n.noOnchainActivityTitle
                            : l10n.noTxMatchFilters,
                        message: provider.recentTransactions.isEmpty
                            ? l10n.noOnchainActivityDesc
                            : l10n.trySwitchingFilters,
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
