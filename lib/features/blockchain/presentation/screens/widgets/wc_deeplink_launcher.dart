import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/wc_session_proposal.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';

/// WcDeepLinkLauncher
///
/// Nút mở wallet app thông qua deep link (cho mobile platforms)
/// Nếu deep link thất bại (app chưa cài), hiển thị gợi ý tải về
///
/// Hỗ trợ: Trust Wallet, MetaMask Mobile
/// Fallback: Hướng dẫn cài từ App Store / Play Store
class WcDeepLinkLauncher extends StatefulWidget {
  final WcSessionProposal session;

  const WcDeepLinkLauncher({super.key, required this.session});

  @override
  State<WcDeepLinkLauncher> createState() => _WcDeepLinkLauncherState();
}

class _WcDeepLinkLauncherState extends State<WcDeepLinkLauncher> {
  bool _trustWalletFailed = false;
  bool _metaMaskFailed = false;
  bool _isLaunching = false;

  bool get _isMobile {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<void> _launchTrustWallet() async {
    setState(() => _isLaunching = true);
    final opened = await _tryLaunch(widget.session.trustWalletDeepLink);
    if (!opened) {
      setState(() => _trustWalletFailed = true);
    }
    setState(() => _isLaunching = false);
  }

  Future<void> _launchMetaMask() async {
    setState(() => _isLaunching = true);
    final opened = await _tryLaunch(widget.session.metamaskDeepLink);
    if (!opened) {
      setState(() => _metaMaskFailed = true);
    }
    setState(() => _isLaunching = false);
  }

  Future<bool> _tryLaunch(String url) async {
    try {
      final uri = Uri.parse(url);
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  Future<void> _openStore(String storeUrl) async {
    await _tryLaunch(storeUrl);
  }

  String _storeName(AppLocalizations l10n) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return l10n.wcStoreGooglePlay;
    }
    return l10n.wcStoreAppStore;
  }

  String get _trustWalletStoreUrl {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'https://play.google.com/store/apps/details?id=com.wallet.crypto.trustapp';
    }
    return 'https://apps.apple.com/app/trust-crypto-bitcoin-wallet/id1288339409';
  }

  String get _metaMaskStoreUrl {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'https://play.google.com/store/apps/details?id=io.metamask';
    }
    return 'https://apps.apple.com/app/metamask-blockchain-wallet/id1438144202';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isMobile) {
      // Không hiển thị deep link trên desktop/web — dùng QR thay thế
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final storeLabel = _storeName(l10n);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.wcOpenWalletOnPhone,
          style: theme.textTheme.titleSmall!.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // Trust Wallet
        _WalletDeepLinkButton(
          l10n: l10n,
          name: 'Trust Wallet',
          iconColor: const Color(0xFF3375BB),
          icon: Icons.account_balance_wallet,
          onPressed: _isLaunching ? null : _launchTrustWallet,
          failed: _trustWalletFailed,
          storeUrl: _trustWalletStoreUrl,
          storeName: storeLabel,
          onOpenStore: _openStore,
        ),

        const SizedBox(height: 8),

        // MetaMask
        _WalletDeepLinkButton(
          l10n: l10n,
          name: 'MetaMask',
          iconColor: const Color(0xFFE8820C),
          icon: Icons.account_balance_wallet_outlined,
          onPressed: _isLaunching ? null : _launchMetaMask,
          failed: _metaMaskFailed,
          storeUrl: _metaMaskStoreUrl,
          storeName: storeLabel,
          onOpenStore: _openStore,
        ),
      ],
    );
  }
}

class _WalletDeepLinkButton extends StatelessWidget {
  final AppLocalizations l10n;
  final String name;
  final Color iconColor;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool failed;
  final String storeUrl;
  final String storeName;
  final Future<void> Function(String) onOpenStore;

  const _WalletDeepLinkButton({
    required this.l10n,
    required this.name,
    required this.iconColor,
    required this.icon,
    required this.onPressed,
    required this.failed,
    required this.storeUrl,
    required this.storeName,
    required this.onOpenStore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (failed) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.wcWalletNotInstalled(name),
              style: theme.textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 6),
            TextButton.icon(
              onPressed: () => onOpenStore(storeUrl),
              icon: const Icon(Icons.download, size: 14),
              label: Text(l10n.wcDownloadFromStore(storeName)),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(fontSize: 12),
                foregroundColor: Colors.orange,
              ),
            ),
          ],
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: iconColor, size: 20),
      label: Text(l10n.wcOpenWalletNamed(name)),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        side: BorderSide(color: iconColor.withOpacity(0.6)),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
