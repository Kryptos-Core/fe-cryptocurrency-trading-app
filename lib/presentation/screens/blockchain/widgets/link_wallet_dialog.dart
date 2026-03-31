import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/wc_session_proposal.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/blockchain_provider.dart';
import 'package:crypto_trading_app/core/services/wallet_signing/tronlink_web_bridge_stub.dart'
    if (dart.library.html) 'package:crypto_trading_app/core/services/wallet_signing/tronlink_web_bridge_web.dart';
import 'wc_qr_session_card.dart';
import 'wc_deeplink_launcher.dart';
import 'wc_session_poller.dart';

/// LinkWalletDialog — WalletConnect v2 First
///
/// Chiến lược (Strategy Pattern):
///  - Native (Windows/Mobile): WalletConnect QR Code
///  - Web với window.ethereum detected: Tab chọn WC hoặc Extension
///  - TronLink: giữ extension web flow (xử lý riêng)
///
/// Flow:
///  1. User chọn network (ETH Sepolia...)
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
  BlockchainNetwork _selectedChain = BlockchainNetwork.ethSepolia;
  WcSessionProposal? _session;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isCompleted = false;

  /// Chỉ hiện tab Extension khi chạy trên Web và có window.ethereum
  bool get _showExtensionTab => kIsWeb;

  /// Chỉ hiện deep link button khi chạy trên mobile native
  bool get _showDeepLink {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  bool get _hasPendingSession =>
      _session != null && !_session!.isExpired && !_isCompleted;

  bool get _isEvmChain =>
      _selectedChain == BlockchainNetwork.ethSepolia ||
      _selectedChain == BlockchainNetwork.solanaDevnet;

  Future<void> _initiateWcSession() async {
    final l10n = AppLocalizations.of(context);
    if (!_isEvmChain) {
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

  @override
  void dispose() {
    context.read<BlockchainProvider>().clearWcSession();
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
            theme.colorScheme.primary.withOpacity(0.12),
            theme.colorScheme.secondary.withOpacity(0.06),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.15),
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
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Network Selector ──
        if (!_hasPendingSession) _buildNetworkSelector(theme, l10n),

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

        // ── Connect Button ──
        if (!_hasPendingSession && !_isLoading)
          _buildConnectButton(theme, l10n),

        // ── Extension fallback (Web only) ──
        if (_showExtensionTab && !_hasPendingSession && !_isLoading) ...[
          const SizedBox(height: 16),
          _buildExtensionFallback(theme, l10n),
        ],

        const SizedBox(height: 8),

        // ── Info Footer ──
        _buildInfoFooter(theme, l10n),
      ],
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
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkSelector(ThemeData theme, AppLocalizations l10n) {
    // Chỉ hiện EVM chains cho WC
    final wcChains = [
      BlockchainNetwork.ethSepolia,
      BlockchainNetwork.solanaDevnet,
    ];
    final tronChains = [
      BlockchainNetwork.tronNile,
      BlockchainNetwork.tronShasta,
    ];
    final allChains = [
      ...wcChains,
      if (_showExtensionTab) ...tronChains,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          children: allChains.map((chain) {
            final isSelected = _selectedChain == chain;
            final isTron = tronChains.contains(chain);
            return ChoiceChip(
              label: Text(chain.label),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedChain = chain),
              avatar: isTron
                  ? const Icon(Icons.extension, size: 16)
                  : const Icon(Icons.qr_code, size: 16),
              tooltip: isTron
                  ? l10n.wcTooltipTronlinkChrome
                  : l10n.wcTooltipWalletConnect,
            );
          }).toList(),
        ),
        // Warning khi chọn Tron (chỉ hỗ trợ qua extension web)
        if (tronChains.contains(_selectedChain))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 14,
                    color: theme.colorScheme.primary.withOpacity(0.7)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.wcTronChromeExtensionWebOnly,
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: theme.colorScheme.primary.withOpacity(0.7),
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
    final isTron = _selectedChain == BlockchainNetwork.tronNile ||
        _selectedChain == BlockchainNetwork.tronShasta;

    if (isTron && !_showExtensionTab) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Text(
          l10n.wcTronChromeOnlyLong,
          style: theme.textTheme.bodySmall!.copyWith(color: Colors.orange),
          textAlign: TextAlign.center,
        ),
      );
    }

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

  Widget _buildExtensionFallback(ThemeData theme, AppLocalizations l10n) {
    final isTron = _selectedChain == BlockchainNetwork.tronNile ||
        _selectedChain == BlockchainNetwork.tronShasta;

    if (!isTron) return const SizedBox.shrink();

    return OutlinedButton.icon(
      onPressed: () async {
        // Trigger TronLink web signing (giữ lại flow cũ cho Tron trên web)
        final result = await tronLinkSignOnWeb(
          message: l10n.wcTronlinkSignMessage,
          expectedAddress: '',
        );
        if (!mounted) return;
        if (result.signature != null) {
          // Verify signature qua flow cũ
          final provider = context.read<BlockchainProvider>();
          final address = result.connectedAddress ?? '';
          if (address.isNotEmpty) {
            await provider.verifyWalletLink(
              chain: _selectedChain,
              address: address,
              signature: result.signature!,
            );
            if (!mounted) return;
            if (provider.error == null) {
              Navigator.of(context).pop(true);
            }
          }
        } else {
          setState(() {
            _errorMessage =
                result.message.isNotEmpty ? result.message : l10n.wcTronlinkSignFailed;
          });
        }
      },
      icon: const Icon(Icons.extension),
      label: Text(l10n.wcSignWithTronlinkExtension),
    );
  }

  Widget _buildErrorBanner(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.3),
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
              color: theme.colorScheme.onSurface.withOpacity(0.4)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              l10n.wcPrivateKeyStaysInWallet,
              style: theme.textTheme.bodySmall!.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
