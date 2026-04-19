import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/wc_session_proposal.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/blockchain/presentation/providers/blockchain_provider.dart';
import 'package:crypto_trading_app/features/treasury/domain/entities/chain_network_catalog_item_model.dart';
import 'package:crypto_trading_app/features/treasury/presentation/providers/onchain_chain_picker_provider.dart';
import 'package:crypto_trading_app/features/blockchain/presentation/widgets/onchain_sandbox_operator_banner.dart';
import 'package:crypto_trading_app/core/services/wallet_signing/tronlink_web_bridge_stub.dart'
    if (dart.library.html) 'package:crypto_trading_app/core/services/wallet_signing/tronlink_web_bridge_web.dart';
import 'wc_qr_session_card.dart';
import 'wc_deeplink_launcher.dart';
import 'wc_session_poller.dart';

/// LinkWalletDialog — WalletConnect v2 First
///
/// Chiến lược (Strategy Pattern):
///  - Native (Windows/Mobile): WalletConnect QR — Tron qua namespace `tron` (scan TronLink mobile)
///  - Web: EVM/Solana WC QR; Tron = TronLink extension flow (challenge / paste hoặc auto-sign)
///
/// Flow:
///  1. User chọn network (BSC Chapel / Solana / Tron…)
///  2. App gọi BE /wc/init → nhận wcUri
///  3. Hiển thị QR / deep link
///  4. Poller kiểm tra status mỗi 2s
///  5. Khi status = signed → auto complete → wallet được liên kết
class LinkWalletDialog extends StatefulWidget {
  const LinkWalletDialog({super.key});

  @override
  State<LinkWalletDialog> createState() => _LinkWalletDialogState();
}

class _LinkWalletDialogState extends State<LinkWalletDialog>
    with SingleTickerProviderStateMixin {
  late BlockchainNetwork _selectedChain;
  BlockchainNetwork? _selectedTronNetwork;
  BlockchainProvider? _blockchainProvider;
  WcSessionProposal? _session;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isCompleted = false;

  final TextEditingController _tronAddressController = TextEditingController();
  final TextEditingController _tronSigController = TextEditingController();
  String? _tronChallengeMessage;
  bool _tronFlowBusy = false;

  /// Chỉ hiện deep link button khi chạy trên mobile native
  bool get _showDeepLink {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  bool get _hasPendingSession =>
      _session != null && !_session!.isExpired && !_isCompleted;

  bool _isSandboxMode(OnchainChainPickerProvider picker) {
    return picker.rawOptions?.operatorMode.toLowerCase() == 'sandbox';
  }

  BlockchainNetwork _defaultTronNetwork(OnchainChainPickerProvider picker) {
    final tronNetworks = _tronNetworksForPicker(picker);
    final rawDefault = picker.rawOptions?.tronDefaultNetwork;
    final parsedDefault = rawDefault == null
        ? null
        : BlockchainNetworkX.tryFromApiValue(rawDefault);
    if (parsedDefault != null && tronNetworks.contains(parsedDefault)) {
      return parsedDefault;
    }
    if (tronNetworks.isNotEmpty) {
      return tronNetworks.first;
    }
    return BlockchainNetwork.tronMainnet;
  }

  List<BlockchainNetwork> _tronNetworksForPicker(
    OnchainChainPickerProvider picker,
  ) {
    final source = kIsWeb
        ? picker.tronExtensionLinkNetworksFromApi
        : picker.walletConnectLinkNetworksFromApi
            .where((network) => network.isTronFamily)
            .toList(growable: false);
    if (source.isNotEmpty) return source;
    return const [
      BlockchainNetwork.tronNile,
      BlockchainNetwork.tronShasta,
    ];
  }

  ChainNetworkCatalogItemModel? _catalogItemFor(
    OnchainChainPickerProvider picker,
    BlockchainNetwork network,
  ) {
    final code = network.apiValue;
    for (final item in picker.networkCatalog) {
      if (item.code == code) return item;
    }
    return null;
  }

  String _blockchainGroupKey(
    OnchainChainPickerProvider picker,
    BlockchainNetwork network,
  ) {
    final item = _catalogItemFor(picker, network);
    final groupKey = item?.blockchainKey.trim();
    if (groupKey != null && groupKey.isNotEmpty) return groupKey;
    final iconKey = item?.iconKey.trim();
    if (iconKey != null && iconKey.isNotEmpty) return iconKey;
    return network.networkFamily.name;
  }

  String _blockchainFamilyLabel(
    OnchainChainPickerProvider picker,
    BlockchainNetwork network,
  ) {
    final item = _catalogItemFor(picker, network);
    final label = item?.blockchainLabel.trim();
    if (label != null && label.isNotEmpty) return label;
    return network.label;
  }

  String _networkOptionLabel(
    OnchainChainPickerProvider picker,
    BlockchainNetwork network,
  ) {
    final item = _catalogItemFor(picker, network);
    final label = item?.networkLabel.trim();
    if (label != null && label.isNotEmpty) return label;
    return network.label;
  }

  @override
  void initState() {
    super.initState();
    // Default until [OnchainChainPickerProvider] resolves BE order (matches nạp/rút).
    _selectedChain = BlockchainNetwork.bscChapel;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final picker = context.read<OnchainChainPickerProvider>();
      await picker.ensureLoaded();
      if (!mounted) return;
      final wc = picker.walletConnectLinkNetworksFromApi;
      final tron = _tronNetworksForPicker(picker);
      final all = [...wc, ...tron];
      if (all.isEmpty) return;
      setState(() {
        if (!wc.contains(_selectedChain) && !tron.contains(_selectedChain)) {
          _selectedChain = wc.isNotEmpty ? wc.first : tron.first;
        }
        if (_selectedChain.isTronFamily) {
          _selectedTronNetwork ??= _defaultTronNetwork(picker);
          if (_isSandboxMode(picker)) {
            _selectedChain = _selectedTronNetwork!;
          } else {
            _selectedChain = BlockchainNetwork.tronMainnet;
          }
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _blockchainProvider ??= context.read<BlockchainProvider>();
  }

  bool get _supportsWalletConnectRelay {
    final c = _selectedChain;
    if (c.isTronFamily) {
      // Web: Tron dùng luồng extension / challenge; native: WC QR + TronLink mobile.
      return !kIsWeb;
    }
    if (c.networkFamily == OnChainNetworkFamily.solana) return true;
    return c.evmCaip2 != null;
  }

  Future<void> _initiateWcSession() async {
    final l10n = AppLocalizations.of(context);
    if (!_supportsWalletConnectRelay) {
      setState(() {
        _errorMessage = l10n.wcWcSupportsEvmSolanaTron;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _session = null;
    });

    final provider = context.read<BlockchainProvider>();
    final proposal = await provider.initiateWcSession(chain: _selectedChain);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (proposal != null) {
        _session = proposal;
      } else {
        _errorMessage = provider.error ?? l10n.wcSessionCreateFailed;
      }
    });
  }

  void _handleSessionExpired() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _errorMessage = l10n.wcSessionExpiredNewQr;
      _session = null;
    });
    context.read<BlockchainProvider>().clearWcSession();
  }

  void _handleSessionFailed() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _errorMessage = l10n.wcSessionWcFailedRetry;
      _session = null;
    });
    context.read<BlockchainProvider>().clearWcSession();
  }

  void _handleSessionSigned() {
    if (!mounted) return;
    setState(() => _isCompleted = true);
    // Auto-close sau 1.5s
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) Navigator.of(context).pop(true);
    });
  }

  void _resetTronLinkFlow() {
    _tronChallengeMessage = null;
    _tronSigController.clear();
    _tronAddressController.clear();
  }

  @override
  void dispose() {
    _tronAddressController.dispose();
    _tronSigController.dispose();
    // clearWcSession → notifyListeners() cannot run during unmount (widget tree locked).
    final bc = _blockchainProvider;
    if (bc != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) => bc.clearWcSession());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──
            _buildHeader(theme, l10n),

            // ── Body ──
            Flexible(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: _buildBody(theme, l10n),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha:0.12),
            theme.colorScheme.secondary.withValues(alpha:0.06),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha:0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.account_balance_wallet,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.wcLinkDialogTitle,
                  style: theme.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  l10n.wcLinkDialogSubtitle,
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(false),
            icon: const Icon(Icons.close),
            tooltip: l10n.close,
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme, AppLocalizations l10n) {
    // ── Completed ──
    if (_isCompleted) {
      return _buildCompletedState(theme, l10n);
    }

    return Consumer<OnchainChainPickerProvider>(
      builder: (context, picker, _) {
        final sandboxMode = _isSandboxMode(picker);
        final tronNetworks = _tronNetworksForPicker(picker);
        final hasTronSupport = tronNetworks.isNotEmpty;

        if (_selectedChain.isTronFamily) {
          if (sandboxMode) {
            _selectedTronNetwork ??= _defaultTronNetwork(picker);
            if (_selectedChain != _selectedTronNetwork) {
              _selectedChain = _selectedTronNetwork!;
            }
          } else if (_selectedChain != BlockchainNetwork.tronMainnet) {
            _selectedChain = BlockchainNetwork.tronMainnet;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Network Selector ──
            if (!_hasPendingSession) _buildNetworkSelector(theme, l10n, picker),

            if (!_hasPendingSession) const SizedBox(height: 20),

            // ── Error ──
            if (_errorMessage != null) ...[
              _buildErrorBanner(theme),
              const SizedBox(height: 16),
            ],

            // ── Loading ──
            if (_isLoading) ...[
              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(l10n.wcCreatingSession),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Active WC Session ──
            if (_hasPendingSession && _session != null)
              _buildWcSessionView(theme, l10n),

            // ── Connect: WC QR or TronLink extension challenge flow (web only) ──
            if (!_hasPendingSession && !_isLoading)
              (kIsWeb && _selectedChain.isTronFamily)
                  ? _buildTronLinkFlow(theme, l10n)
                  : _buildConnectButton(theme, l10n),

            const SizedBox(height: 8),

            // ── Info Footer ──
            _buildInfoFooter(theme, l10n),
          ],
        );
      },
    );
  }

  Widget _buildCompletedState(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 72),
          const SizedBox(height: 16),
          Text(
            l10n.walletLinkedSuccess,
            style: theme.textTheme.titleLarge!.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.wcLinkedWalletAddedToList,
            style: theme.textTheme.bodyMedium!.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha:0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkSelector(
    ThemeData theme,
    AppLocalizations l10n,
    OnchainChainPickerProvider picker,
  ) {
    final wcChains = picker.walletConnectLinkNetworksFromApi;
    final tronChains = _tronNetworksForPicker(picker);
    final allChains = <BlockchainNetwork>[];
    final seenChainCodes = <String>{};
    for (final chain in [...wcChains, ...tronChains]) {
      if (seenChainCodes.add(chain.apiValue)) {
        allChains.add(chain);
      }
    }

    if (allChains.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnchainSandboxOperatorBanner(l10n: l10n),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              l10n.requestFailed,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      );
    }

    final blockchainOptions = <BlockchainNetwork>[];
    final seenGroups = <String>{};
    for (final chain in allChains) {
      final groupKey = _blockchainGroupKey(picker, chain);
      if (seenGroups.add(groupKey)) {
        blockchainOptions.add(chain);
      }
    }

    final selectedGroupKey = _blockchainGroupKey(picker, _selectedChain);
    final selectedBlockchain = blockchainOptions.firstWhere(
      (chain) => _blockchainGroupKey(picker, chain) == selectedGroupKey,
      orElse: () => blockchainOptions.first,
    );
    final selectedNetworks = allChains
        .where((chain) => _blockchainGroupKey(picker, chain) == selectedGroupKey)
        .toList(growable: false);
    final selectedNetwork = selectedNetworks.firstWhere(
      (chain) => chain == _selectedChain,
      orElse: () => selectedNetworks.first,
    );

    if (!allChains.contains(_selectedChain)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _selectedChain = allChains.first;
          _selectedTronNetwork = _selectedChain.isTronFamily ? _selectedChain : null;
        });
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnchainSandboxOperatorBanner(l10n: l10n),
        Text(
          l10n.wcLinkChooseBlockchain,
          style: theme.textTheme.labelLarge!.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: blockchainOptions.map((chain) {
            final chainGroupKey = _blockchainGroupKey(picker, chain);
            final isSelected = _blockchainGroupKey(picker, selectedBlockchain) ==
                chainGroupKey;
            return ChoiceChip(
              label: Text(_blockchainFamilyLabel(picker, chain)),
              selected: isSelected,
              onSelected: (_) {
                final nextNetworks = allChains
                    .where((network) =>
                        _blockchainGroupKey(picker, network) == chainGroupKey)
                    .toList(growable: false);
                if (nextNetworks.isEmpty) return;
                final nextChain = nextNetworks.first;
                setState(() {
                  if (_selectedChain != nextChain) {
                    _resetTronLinkFlow();
                  }
                  _selectedChain = nextChain;
                  _selectedTronNetwork = nextChain.isTronFamily ? nextChain : null;
                });
              },
              avatar: Icon(
                chain.isTronFamily ? Icons.extension : Icons.qr_code,
                size: 16,
              ),
              tooltip: l10n.wcTooltipWalletConnect,
            );
          }).toList(),
        ),
        if (selectedNetworks.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            l10n.wcNetworkLabel,
            style: theme.textTheme.labelLarge!.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedNetworks.map((network) {
              final isSelected = selectedNetwork == network;
              return ChoiceChip(
                label: Text(_networkOptionLabel(picker, network)),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    if (_selectedChain != network) {
                      _resetTronLinkFlow();
                    }
                    _selectedChain = network;
                    _selectedTronNetwork = network.isTronFamily ? network : null;
                  });
                },
                avatar: const Icon(Icons.qr_code, size: 16),
                tooltip: l10n.wcTooltipWalletConnect,
              );
            }).toList(),
          ),
        ],
        if (!kIsWeb && selectedBlockchain.isTronFamily)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: theme.colorScheme.primary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.tronLinkNativePlatformHint,
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: theme.colorScheme.primary.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
  Widget _buildWcSessionView(ThemeData theme, AppLocalizations l10n) {
    return Consumer<BlockchainProvider>(
      builder: (ctx, provider, _) {
        return WcSessionPoller(
          sessionId: _session!.sessionId,
          onSigned: _handleSessionSigned,
          onExpired: _handleSessionExpired,
          onFailed: _handleSessionFailed,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // QR Card
              WcQrSessionCard(
                session: _session!,
                status: provider.wcSessionStatus,
                onExpired: _handleSessionExpired,
                onRefresh: () {
                  setState(() => _session = null);
                  _initiateWcSession();
                },
              ),
              const SizedBox(height: 16),

              // Deep link button (mobile only)
              if (_showDeepLink) ...[
                WcDeepLinkLauncher(session: _session!),
                const SizedBox(height: 12),
              ],

              // Cancel button
              TextButton(
                onPressed: () {
                  setState(() => _session = null);
                  provider.clearWcSession();
                },
                child: Text(l10n.wcCancelReselect),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConnectButton(ThemeData theme, AppLocalizations l10n) {
    return ElevatedButton.icon(
      onPressed: _initiateWcSession,
      icon: const Icon(Icons.qr_code),
      label: Text(l10n.wcCreateQrButton),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _fetchTronChallenge() async {
    final l10n = AppLocalizations.of(context);
    final provider = context.read<BlockchainProvider>();
    final addr = _tronAddressController.text.trim();
    if (addr.isEmpty) {
      setState(() => _errorMessage = l10n.tronLinkAddressRequired);
      return;
    }
    setState(() {
      _tronFlowBusy = true;
      _errorMessage = null;
      _tronChallengeMessage = null;
    });
    final res = await provider.initiateWalletLink(
      chain: _selectedChain,
      address: addr,
      label: 'TronLink',
    );
    if (!mounted) return;
    setState(() {
      _tronFlowBusy = false;
      if (res != null && res.message.isNotEmpty) {
        _tronChallengeMessage = res.message;
      } else {
        _errorMessage = provider.error ?? l10n.requestFailed;
      }
    });
  }

  Future<void> _verifyTronLink() async {
    final l10n = AppLocalizations.of(context);
    final provider = context.read<BlockchainProvider>();
    final addr = _tronAddressController.text.trim();
    final sig = _tronSigController.text.trim();
    if (addr.isEmpty) {
      setState(() => _errorMessage = l10n.tronLinkAddressRequired);
      return;
    }
    if (sig.isEmpty) {
      setState(() => _errorMessage = l10n.tronLinkSignatureRequired);
      return;
    }
    setState(() {
      _tronFlowBusy = true;
      _errorMessage = null;
    });
    final ok = await provider.verifyWalletLink(
      chain: _selectedChain,
      address: addr,
      signature: sig,
    );
    if (!mounted) return;
    setState(() => _tronFlowBusy = false);
    if (ok) {
      _handleSessionSigned();
    } else {
      setState(() => _errorMessage = provider.error ?? l10n.requestFailed);
    }
  }

  Future<void> _tronAutoSignOnWeb() async {
    if (!kIsWeb) return;
    final l10n = AppLocalizations.of(context);
    final provider = context.read<BlockchainProvider>();

    var addr = _tronAddressController.text.trim();
    if (addr.isEmpty) {
      addr = (await tronLinkGetAddressOnWeb())?.trim() ?? '';
      if (!mounted) return;
      if (addr.isNotEmpty) {
        _tronAddressController.text = addr;
      }
    }
    if (addr.isEmpty) {
      setState(() => _errorMessage = l10n.tronLinkAddressRequired);
      return;
    }

    setState(() {
      _tronFlowBusy = true;
      _errorMessage = null;
    });

    if (_tronChallengeMessage == null || _tronChallengeMessage!.isEmpty) {
      final res = await provider.initiateWalletLink(
        chain: _selectedChain,
        address: addr,
        label: 'TronLink',
      );
      if (!mounted) return;
      if (res != null && res.message.isNotEmpty) {
        setState(() => _tronChallengeMessage = res.message);
      } else {
        setState(() {
          _tronFlowBusy = false;
          _errorMessage = provider.error ?? l10n.requestFailed;
        });
        return;
      }
    }

    final msg = _tronChallengeMessage ?? '';
    final result = await tronLinkSignOnWeb(
      message: msg,
      expectedAddress: addr,
    );
    if (!mounted) return;

    if (result.signature != null && result.signature!.isNotEmpty) {
      final ok = await provider.verifyWalletLink(
        chain: _selectedChain,
        address: addr,
        signature: result.signature!,
      );
      setState(() => _tronFlowBusy = false);
      if (!mounted) return;
      if (ok) {
        _handleSessionSigned();
      } else {
        setState(() => _errorMessage = provider.error ?? l10n.wcTronlinkSignFailed);
      }
    } else {
      setState(() {
        _tronFlowBusy = false;
        _errorMessage =
            result.message.isNotEmpty ? result.message : l10n.wcTronlinkSignFailed;
      });
    }
  }

  Widget _buildTronLinkFlow(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _tronAddressController,
          enabled: !_tronFlowBusy,
          decoration: InputDecoration(
            labelText: l10n.tronLinkAddressLabel,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _tronFlowBusy ? null : _fetchTronChallenge,
          child: Text(l10n.tronLinkGetChallenge),
        ),
        if (_tronChallengeMessage != null) ...[
          const SizedBox(height: 16),
          Text(
            l10n.tronLinkChallengeTitle,
            style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          SelectableText(
            _tronChallengeMessage!,
            style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                tooltip: l10n.copyAddressTooltip,
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: _tronChallengeMessage!),
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.depositDetailCopied)),
                  );
                },
                icon: const Icon(Icons.copy, size: 20),
              ),
              Expanded(
                child: Text(
                  l10n.tronLinkChallengeHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                  ),
                ),
              ),
            ],
          ),
          if (kIsWeb) ...[
          const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _tronFlowBusy ? null : _tronAutoSignOnWeb,
              icon: const Icon(Icons.extension_outlined),
              label: Text(l10n.tronLinkExtensionAutoSign),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _tronSigController,
            enabled: !_tronFlowBusy,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.tronLinkSignatureLabel,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _tronFlowBusy ? null : _verifyTronLink,
            child: Text(l10n.tronLinkVerify),
          ),
        ],
        if (_tronFlowBusy) ...[
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      ],
    );
  }

  Widget _buildErrorBanner(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha:0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha:0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline,
              color: theme.colorScheme.error, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: theme.textTheme.bodySmall!.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 14),
            onPressed: () => setState(() => _errorMessage = null),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: theme.colorScheme.error,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoFooter(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(Icons.shield_outlined,
              size: 14,
              color: theme.colorScheme.onSurface.withValues(alpha:0.4)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              l10n.wcPrivateKeyStaysInWallet,
              style: theme.textTheme.bodySmall!.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha:0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
















