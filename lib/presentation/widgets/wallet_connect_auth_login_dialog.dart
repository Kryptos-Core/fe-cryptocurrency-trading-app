import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:reown_appkit/reown_appkit.dart';

import 'package:crypto_trading_app/core/di/injection_container.dart';
import 'package:crypto_trading_app/core/services/wallet_connect/reown_wallet_auth_config.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/core/utils/wallet_web_extension_auth.dart';
import 'package:crypto_trading_app/data/datasources/auth_remote_datasource.dart';
import 'package:crypto_trading_app/data/repositories/auth_repository_impl.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/wc_session_proposal.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/wc_session_status.dart';
import 'package:crypto_trading_app/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/presentation/screens/blockchain/widgets/wc_deeplink_launcher.dart';
import 'package:crypto_trading_app/presentation/screens/blockchain/widgets/wc_qr_session_card.dart';

/// Đăng nhập bằng ví:
/// - **Web:** extension MetaMask/TronLink (nonce + ký); mục «Nâng cao» = QR server cũ.
/// - **Native:** **Reown AppKit** — URI/QR từ SDK + `personal_sign` + `/auth/wallet-verify`;
///   cần `WALLETCONNECT_PROJECT_ID` trong `.env` (cùng project Reown Cloud như backend).
Future<bool?> showWalletConnectAuthLoginDialog({
  required BuildContext context,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => const WalletConnectAuthLoginDialog(),
  );
}

class WalletConnectAuthLoginDialog extends StatefulWidget {
  const WalletConnectAuthLoginDialog({super.key});

  @override
  State<WalletConnectAuthLoginDialog> createState() =>
      _WalletConnectAuthLoginDialogState();
}

class _WalletConnectAuthLoginDialogState
    extends State<WalletConnectAuthLoginDialog> {
  static const _wcChains = [
    BlockchainNetwork.ethSepolia,
    BlockchainNetwork.solanaDevnet,
  ];

  final _addressCtrl = TextEditingController();
  final _signatureCtrl = TextEditingController();

  BlockchainNetwork _chain = BlockchainNetwork.ethSepolia;
  WcAuthInitResult? _init;
  DateTime? _expiresAt;
  WcSessionStatus _status = WcSessionStatus.pending;
  bool _loadingInit = false;
  bool _verifying = false;
  String? _error;
  Timer? _pollTimer;
  bool _webExtensionBusy = false;

  ReownAppKitModal? _reownModal;
  bool _reownInitializing = false;
  String? _reownInitError;
  bool _reownAuthBusy = false;
  late void Function(ModalConnect) _reownConnectHandler;

  AuthRepository get _repo => sl<AuthRepository>();
  AuthRemoteDataSource get _authDs => sl<AuthRemoteDataSource>();

  bool get _showDeepLinks {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  void initState() {
    super.initState();
    _reownConnectHandler =
        (_) => Future<void>(() => _completeLoginAfterReownConnect());
    if (!kIsWeb && ReownWalletAuthConfig.isRuntimeSupported) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _initReownModal());
    }
  }

  String _utf8MessageToHex0x(String message) {
    final bytes = utf8.encode(message);
    return '0x${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';
  }

  Future<void> _initReownModal() async {
    if (!mounted || kIsWeb || !ReownWalletAuthConfig.isRuntimeSupported) return;
    final pid = ReownWalletAuthConfig.projectId;
    if (pid == null) {
      final l10n = AppLocalizations.of(context);
      setState(() {
        _reownInitError = l10n.wcReownMissingProjectId;
      });
      return;
    }
    setState(() {
      _reownInitializing = true;
      _reownInitError = null;
    });
    try {
      final modal = ReownWalletAuthConfig.createModal(context, projectId: pid);
      await modal.init();
      if (!mounted) {
        await modal.dispose();
        return;
      }
      modal.onModalConnect.subscribe(_reownConnectHandler);
      setState(() {
        _reownModal = modal;
        _reownInitializing = false;
      });
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        setState(() {
          _reownInitializing = false;
          _reownInitError = l10n.wcReownInitFailed(e.toString());
        });
      }
    }
  }

  Future<void> _completeLoginAfterReownConnect() async {
    if (!mounted || _reownAuthBusy || _reownModal == null) return;
    final session = _reownModal!.session;
    final topic = session?.topic;
    if (topic == null || topic.isEmpty) return;

    final address = session!.getAddress('eip155');
    if (address == null || address.isEmpty) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        showAppSnackBar(
          context,
          message: l10n.wcReownSessionNoEvmAddress,
          type: SnackBarType.warning,
        );
      }
      return;
    }

    setState(() => _reownAuthBusy = true);
    try {
      final nonce = await _authDs.walletNonce(
        chain: BlockchainNetwork.ethSepolia.apiValue,
        address: address,
      );
      if (!mounted) return;

      final hexMsg = _utf8MessageToHex0x(nonce.message);
      final sig = await _reownModal!.request(
        topic: topic,
        chainId: ReownWalletAuthConfig.sepoliaCaip2,
        request: SessionRequestParams(
          method: 'personal_sign',
          params: [hexMsg, address],
        ),
      );

      if (!mounted) return;
      final sigStr = sig?.toString().trim() ?? '';
      if (sigStr.isEmpty) {
        final l10n = AppLocalizations.of(context);
        showAppSnackBar(
          context,
          message: l10n.wcReownNoSignature,
          type: SnackBarType.error,
        );
        return;
      }

      final auth = context.read<AuthProvider>();
      final result = await auth.loginWithWallet(
        chain: BlockchainNetwork.ethSepolia.apiValue,
        address: address,
        signature: sigStr,
      );
      if (!mounted) return;
      result.fold(
        (f) => showAppSnackBar(
          context,
          message: f.message,
          type: SnackBarType.error,
        ),
        (_) {
          _reownModal?.closeModal();
          Navigator.of(context).pop(true);
        },
      );
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        showAppSnackBar(
          context,
          message: l10n.wcReownLoginError(e.toString()),
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _reownAuthBusy = false);
    }
  }

  Future<void> _openReownQr() async {
    final m = _reownModal;
    if (m == null) return;
    await m.openModalView(const ReownAppKitModalQRCodePage());
  }

  Widget _buildReownNativeSection(ThemeData theme, AppLocalizations l10n) {
    if (!ReownWalletAuthConfig.isRuntimeSupported) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.wcReownDesktopUnsupportedBody,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }
    if (_reownInitializing) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_reownInitError != null) {
      return Text(
        _reownInitError!,
        style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
      );
    }
    if (_reownModal == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.wcReownQrDescription,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _reownAuthBusy ? null : _openReownQr,
          icon: _reownAuthBusy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.qr_code_scanner),
          label: Text(l10n.wcReownOpenQrButton),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _stopPoll();
    _reownModal?.onModalConnect.unsubscribe(_reownConnectHandler);
    unawaited(_reownModal?.dispose() ?? Future.value());
    _reownModal = null;
    _addressCtrl.dispose();
    _signatureCtrl.dispose();
    super.dispose();
  }

  WcSessionProposal? get _proposal {
    final i = _init;
    final exp = _expiresAt;
    if (i == null || exp == null) return null;
    return WcSessionProposal(
      sessionId: i.sessionId,
      wcUri: i.wcUri,
      expiresAt: exp,
      chain: _chain,
      caip2Chain: i.caip2Chain,
    );
  }

  void _stopPoll() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void _startPoll() {
    _stopPoll();
    final sid = _init?.sessionId;
    if (sid == null) return;
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      final r = await _repo.walletWcAuthStatus(sid);
      if (!mounted) return;
      r.fold(
        (_) {
          /* lỗi poll tạm — thử lại ở chu kỳ sau */
        },
        (data) {
          setState(() {
            _status = data.status;
            if (data.expiresAtMs != null) {
              _expiresAt =
                  DateTime.fromMillisecondsSinceEpoch(data.expiresAtMs!);
            }
          });
          if (data.status == WcSessionStatus.expired ||
              data.status == WcSessionStatus.failed) {
            _stopPoll();
          }
        },
      );
    });
  }

  Future<void> _createSession() async {
    setState(() {
      _loadingInit = true;
      _error = null;
      _init = null;
      _expiresAt = null;
      _status = WcSessionStatus.pending;
    });
    _stopPoll();
    final r = await _repo.walletWcAuthInit(chain: _chain.apiValue);
    if (!mounted) return;
    setState(() {
      _loadingInit = false;
      r.fold(
        (f) => _error = f.message,
        (data) {
          _init = data;
          _expiresAt =
              DateTime.now().add(Duration(seconds: data.expiresIn));
          _status = WcSessionStatus.pending;
        },
      );
    });
    if (_init != null) _startPoll();
  }

  void _onSessionExpiredUi() {
    _stopPoll();
    if (!mounted) return;
    setState(() {
      _error = 'Phiên đã hết hạn. Tạo mã QR mới.';
      _init = null;
      _expiresAt = null;
      _status = WcSessionStatus.expired;
    });
  }

  Future<void> _webExtensionLogin({required bool metaMask}) async {
    setState(() => _webExtensionBusy = true);
    try {
      await loginWithWebBrowserExtension(
        context,
        metaMask: metaMask,
        datasource: _authDs,
        onSuccess: () {
          if (mounted) Navigator.of(context).pop(true);
        },
      );
    } finally {
      if (mounted) setState(() => _webExtensionBusy = false);
    }
  }

  Future<void> _verify() async {
    final i = _init;
    if (i == null) return;
    final address = _addressCtrl.text.trim();
    final sig = _signatureCtrl.text.trim();
    if (address.isEmpty || sig.isEmpty) {
      showAppSnackBar(
        context,
        message: 'Nhập địa chỉ ví và chữ ký.',
        type: SnackBarType.warning,
      );
      return;
    }
    setState(() => _verifying = true);
    final auth = context.read<AuthProvider>();
    final result = await auth.completeWalletConnectAuthLogin(
      sessionId: i.sessionId,
      chain: _chain.apiValue,
      address: address,
      signature: sig,
    );
    if (!mounted) return;
    setState(() => _verifying = false);
    result.fold(
      (f) => showAppSnackBar(
        context,
        message: f.message,
        type: SnackBarType.error,
      ),
      (_) {
        _stopPoll();
        Navigator.of(context).pop(true);
      },
    );
  }

  Widget _buildWcManualFlow(
    ThemeData theme,
    WcSessionProposal? proposal,
    String signingMessage,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          kIsWeb
              ? 'Luồng server: QR + message từ `/auth/wallet/wc/init`, '
                  'ký đúng message, gửi `/auth/wallet/wc/verify`.'
              : 'Không cần tài khoản trước. Quét QR bằng ví trên điện thoại, '
                  'ký đúng message do server trả về, rồi dán địa chỉ và chữ ký bên dưới.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Mạng',
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _wcChains.map((c) {
            final selected = _chain == c;
            return ChoiceChip(
              label: Text(c.label),
              selected: selected,
              onSelected: _loadingInit || proposal != null
                  ? null
                  : (_) => setState(() => _chain = c),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _loadingInit ? null : _createSession,
          icon: _loadingInit
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh, size: 20),
          label: Text(
            proposal == null ? 'Tạo mã QR' : 'Tạo mã QR mới',
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: TextStyle(
              color: theme.colorScheme.error,
              fontSize: 13,
            ),
          ),
        ],
        if (proposal != null) ...[
          const SizedBox(height: 20),
          WcQrSessionCard(
            session: proposal,
            status: _status,
            qrFooterText:
                'Quét QR bằng ví (MetaMask / Trust / Phantom…). '
                'Ký đúng message hiển thị bên dưới.',
            onExpired: _onSessionExpiredUi,
            onRefresh: _createSession,
          ),
          if (_showDeepLinks) ...[
            const SizedBox(height: 12),
            WcDeepLinkLauncher(session: proposal),
          ],
          const SizedBox(height: 16),
          Text(
            'Message cần ký',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          SelectableText(
            signingMessage,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: signingMessage));
                showAppSnackBar(
                  context,
                  message: 'Đã copy message',
                  type: SnackBarType.success,
                );
              },
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('Copy message'),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressCtrl,
            decoration: const InputDecoration(
              labelText: 'Địa chỉ ví đã ký',
              border: OutlineInputBorder(),
              hintText: '0x… hoặc địa chỉ Solana',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _signatureCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Chữ ký (signature)',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _verifying ? null : _verify,
            child: _verifying
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Xác thực & đăng nhập'),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final proposal = _proposal;
    final signingMessage = _init?.message ?? '';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: Row(
                children: [
                  Icon(Icons.qr_code_2, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      kIsWeb ? l10n.wcLoginTitleWeb : l10n.wcLoginTitleNative,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (kIsWeb) ...[
                      Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Khuyến nghị: dùng extension — ký tự động, không cần QR hay dán chữ ký.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                onPressed: _webExtensionBusy
                                    ? null
                                    : () => _webExtensionLogin(metaMask: true),
                                icon: _webExtensionBusy
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.account_balance_wallet_outlined),
                                label: const Text('MetaMask (Chrome extension)'),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: _webExtensionBusy
                                    ? null
                                    : () => _webExtensionLogin(metaMask: false),
                                icon: const Icon(Icons.link),
                                label: const Text('TronLink (Chrome extension)'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: const Text('Nâng cao: QR WalletConnect / dán signature'),
                        subtitle: Text(
                          'Desktop, ví mobile, hoặc khi không dùng extension',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildWcManualFlow(
                              theme,
                              proposal,
                              signingMessage,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      _buildReownNativeSection(theme, l10n),
                      const SizedBox(height: 12),
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        initiallyExpanded:
                            !ReownWalletAuthConfig.isRuntimeSupported,
                        title: Text(l10n.wcAdvancedLegacyQrTitle),
                        subtitle: Text(
                          l10n.wcAdvancedLegacyQrSubtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildWcManualFlow(
                              theme,
                              proposal,
                              signingMessage,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
