import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:reown_appkit/reown_appkit.dart';

import 'package:crypto_trading_app/app/di/injection_container.dart';
import 'package:crypto_trading_app/core/services/wallet_connect/reown_wallet_auth_config.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/core/utils/wallet_web_extension_auth.dart';
import 'package:crypto_trading_app/features/auth/domain/entities/wc_auth_results.dart';
import 'package:crypto_trading_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/wc_session_proposal.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/wc_session_status.dart';
import 'package:crypto_trading_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/features/treasury/presentation/providers/onchain_chain_picker_provider.dart';
import 'package:crypto_trading_app/features/blockchain/presentation/screens/widgets/wc_deeplink_launcher.dart';
import 'package:crypto_trading_app/features/blockchain/presentation/widgets/onchain_sandbox_operator_banner.dart';
import 'package:crypto_trading_app/features/blockchain/presentation/screens/widgets/wc_qr_session_card.dart';

/// Đăng nhập bằng ví:
/// - **Web:** TronLink extension; QR WalletConnect trong mục mở rộng.
/// - **Native:** **Reown AppKit** — URI/QR từ SDK + `personal_sign` + `/auth/wallet-verify`;
///   cần `WALLETCONNECT_PROJECT_ID` trong `.env` (cùng project Reown Cloud như backend).
///
/// [tronMobileQrEntry]: native/desktop/mobile — chỉ luồng QR WalletConnect relay cho Tron
/// (cùng backend `/auth/wallet/wc/*` như mục “Legacy QR”; UX giống tab liên kết ví / quét TronLink).
Future<bool?> showWalletConnectAuthLoginDialog({
  required BuildContext context,
  bool tronMobileQrEntry = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => WalletConnectAuthLoginDialog(tronMobileQrEntry: tronMobileQrEntry),
  );
}

class WalletConnectAuthLoginDialog extends StatefulWidget {
  const WalletConnectAuthLoginDialog({
    super.key,
    this.tronMobileQrEntry = false,
  });

  /// `true`: ẩn Reown EVM; mở thẳng luồng QR WC auth cho Tron (TronLink mobile quét).
  final bool tronMobileQrEntry;

  @override
  State<WalletConnectAuthLoginDialog> createState() =>
      _WalletConnectAuthLoginDialogState();
}

class _WalletConnectAuthLoginDialogState
    extends State<WalletConnectAuthLoginDialog> {
  final _addressCtrl = TextEditingController();
  final _signatureCtrl = TextEditingController();

  BlockchainNetwork _chain = BlockchainNetwork.bscChapel;
  WcAuthInitResult? _init;
  DateTime? _expiresAt;
  WcSessionStatus _status = WcSessionStatus.pending;
  bool _loadingInit = false;
  bool _verifying = false;
  String? _error;
  Timer? _pollTimer;
  bool _webExtensionBusy = false;

  /// Backend trả address + signature từ SignClient — ẩn form dán tay.
  bool _pollHasServerSignature = false;
  bool _wcAutoVerifyBusy = false;
  String? _wcAutoVerifyDedupeKey;

  ReownAppKitModal? _reownModal;
  bool _reownInitializing = false;
  String? _reownInitError;
  bool _reownAuthBusy = false;
  late void Function(ModalConnect) _reownConnectHandler;

  /// Không có Tron trong chain-picker → không thể QR TronLink.
  bool _tronQrEntryUnavailable = false;

  AuthRepository get _repo => sl<AuthRepository>();

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
    if (!kIsWeb &&
        ReownWalletAuthConfig.isRuntimeSupported &&
        !widget.tronMobileQrEntry) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _initReownModal());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final picker = context.read<OnchainChainPickerProvider>();
      await picker.ensureLoaded();
      if (!mounted) return;
      final wc = picker.walletConnectLinkNetworksFromApi;
      if (wc.isEmpty) return;

      final tronChoices = wc.where((c) => c.isTronFamily).toList();
      if (widget.tronMobileQrEntry && !kIsWeb) {
        if (tronChoices.isEmpty) {
          setState(() {
            _tronQrEntryUnavailable = true;
            if (!wc.contains(_chain)) _chain = wc.first;
          });
          return;
        }
        setState(() {
          _tronQrEntryUnavailable = false;
          _chain = tronChoices.contains(_chain) ? _chain : tronChoices.first;
        });
        // Không gọi [_createSession] ở đây: session đang mở sẽ khóa chip mạng
        // (`proposal != null` → onSelected = null). Trader chọn Nile/Shasta rồi bấm "Tạo mã QR".
        return;
      }

      setState(() {
        if (!wc.contains(_chain)) {
          _chain = wc.first;
        }
      });
    });
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

  /// Chuỗi EVM + CAIP-2 để gọi `personal_sign` (ưu tiên account đầu khớp enum app).
  (BlockchainNetwork, String)? _resolvedReownEvmAuth(
    ReownAppKitModalSession session,
  ) {
    final accounts = session.getAccounts(namespace: 'eip155');
    if (accounts != null) {
      for (final acc in accounts) {
        final parts = acc.split(':');
        if (parts.length >= 3 && parts[0] == 'eip155') {
          final caip = '${parts[0]}:${parts[1]}';
          final net = BlockchainNetworkX.tryFromEvmCaip2(caip);
          if (net != null) {
            return (net, caip);
          }
        }
      }
    }
    final rawId = session.chainId;
    final caip = rawId.startsWith('eip155:') ? rawId : 'eip155:$rawId';
    final net = BlockchainNetworkX.tryFromEvmCaip2(caip);
    if (net != null) {
      return (net, caip);
    }
    return null;
  }

  Future<void> _completeLoginAfterReownConnect() async {
    if (!mounted || _reownAuthBusy || _reownModal == null) return;
    final session = _reownModal!.session;
    final topic = session?.topic;
    if (topic == null || topic.isEmpty) return;
    if (session == null) return;

    final evm = _resolvedReownEvmAuth(session);
    if (evm == null) {
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

    final (chain, caip2) = evm;
    final address = session.getAddress('eip155');
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
      final nonceResult = await _repo.walletNonce(
        chain: chain.apiValue,
        address: address,
      );
      if (!mounted) return;
      final nonce = nonceResult.fold(
        (f) => throw Exception(f.message),
        (v) => v,
      );

      final hexMsg = _utf8MessageToHex0x(nonce.message);
      final sig = await _reownModal!.request(
        topic: topic,
        chainId: caip2,
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
        chain: chain.apiValue,
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
    final i = _init;
    if (i == null) return;
    final sid = i.sessionId;

    if (!i.relayPairing) {
      final exp = _expiresAt;
      if (exp != null) {
        final ms = exp.difference(DateTime.now()).inMilliseconds;
        if (ms <= 0) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _onSessionExpiredUi());
        } else {
          _pollTimer = Timer(Duration(milliseconds: ms), () {
            if (mounted) _onSessionExpiredUi();
          });
        }
      }
      return;
    }

    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      final r = await _repo.walletWcAuthStatus(sid);
      if (!mounted) return;
      r.fold(
        (_) {
          /* lỗi poll tạm — thử lại ở chu kỳ sau */
        },
        (data) {
          final hadAutoCreds = (data.signature ?? '').trim().isNotEmpty &&
              (data.address ?? '').trim().isNotEmpty;
          setState(() {
            _status = data.status;
            _pollHasServerSignature = hadAutoCreds;
            if (data.expiresAtMs != null) {
              _expiresAt =
                  DateTime.fromMillisecondsSinceEpoch(data.expiresAtMs!);
            }
          });
          if (data.status == WcSessionStatus.signed && hadAutoCreds) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _maybeAutoVerifyAfterPoll(data);
            });
          }
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
      _pollHasServerSignature = false;
      _wcAutoVerifyBusy = false;
      _wcAutoVerifyDedupeKey = null;
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
          _expiresAt = DateTime.now().add(Duration(seconds: data.expiresIn));
          _status = WcSessionStatus.pending;
        },
      );
    });
    if (_init != null) {
      _startPoll();
    }
  }

  void _onSessionExpiredUi() {
    _stopPoll();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _error = l10n.wcSessionExpiredCreateNew;
      _init = null;
      _expiresAt = null;
      _status = WcSessionStatus.expired;
    });
  }

  Future<void> _webTronLinkExtensionLogin() async {
    setState(() => _webExtensionBusy = true);
    try {
      await loginWithWebBrowserExtension(
        context,
        metaMask: false,
        fetchNonce: ({required chain, required address}) async {
          final r = await _repo.walletNonce(chain: chain, address: address);
          return r.fold((f) => throw Exception(f.message), (v) => v);
        },
        onSuccess: () {
          if (mounted) Navigator.of(context).pop(true);
        },
      );
    } finally {
      if (mounted) setState(() => _webExtensionBusy = false);
    }
  }

  Future<void> _maybeAutoVerifyAfterPoll(WcAuthStatusResult data) async {
    if (!mounted || _wcAutoVerifyBusy) return;
    if (data.status != WcSessionStatus.signed) return;
    final addr = data.address?.trim() ?? '';
    final sig = data.signature?.trim() ?? '';
    if (addr.isEmpty || sig.isEmpty) return;
    final dedupe = '${data.sessionId}|$addr|$sig';
    if (_wcAutoVerifyDedupeKey == dedupe) return;
    _wcAutoVerifyDedupeKey = dedupe;

    setState(() => _wcAutoVerifyBusy = true);
    _stopPoll();
    _addressCtrl.text = addr;
    _signatureCtrl.text = sig;

    final auth = context.read<AuthProvider>();
    final result = await auth.completeWalletConnectAuthLogin(
      sessionId: data.sessionId,
      chain: _chain.apiValue,
      address: addr,
      signature: sig,
    );
    if (!mounted) return;
    setState(() => _wcAutoVerifyBusy = false);
    result.fold(
      (f) {
        showAppSnackBar(
          context,
          message: f.message,
          type: SnackBarType.error,
        );
        setState(() {
          _wcAutoVerifyDedupeKey = null;
          _pollHasServerSignature = false;
        });
        _startPoll();
      },
      (_) {
        Navigator.of(context).pop(true);
      },
    );
  }

  Future<void> _verify() async {
    final i = _init;
    if (i == null) return;
    final address = _addressCtrl.text.trim();
    final sig = _signatureCtrl.text.trim();
    if (address.isEmpty || sig.isEmpty) {
      final l10n = AppLocalizations.of(context);
      showAppSnackBar(
        context,
        message: l10n.wcEnterAddressAndSignature,
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
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    WcSessionProposal? proposal,
    String signingMessage,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          kIsWeb ? l10n.wcManualFlowIntroWeb : l10n.wcManualFlowIntroNative,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.wcNetworkLabel,
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Consumer<OnchainChainPickerProvider>(
          builder: (context, picker, _) {
            final raw = picker.walletConnectLinkNetworksFromApi;
            final wcChains = widget.tronMobileQrEntry
                ? raw.where((c) => c.isTronFamily).toList()
                : raw;
            if (wcChains.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  l10n.requestFailed,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              );
            }
            if (!wcChains.contains(_chain)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                setState(() => _chain = wcChains.first);
              });
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: wcChains.map((c) {
                final selected = _chain == c;
                return ChoiceChip(
                  label: Text(
                    onchainNetworkFilterChipLabel(
                      c,
                      l10n.onchainSandboxShort,
                    ),
                  ),
                  selected: selected,
                  onSelected: _loadingInit
                      ? null
                      : proposal != null && !widget.tronMobileQrEntry
                          ? null
                          : (bool selectedTap) {
                              if (!selectedTap) return;
                              if (proposal != null && widget.tronMobileQrEntry) {
                                _stopPoll();
                                setState(() {
                                  _init = null;
                                  _expiresAt = null;
                                  _status = WcSessionStatus.pending;
                                  _pollHasServerSignature = false;
                                  _wcAutoVerifyDedupeKey = null;
                                  _wcAutoVerifyBusy = false;
                                  _chain = c;
                                });
                                return;
                              }
                              setState(() => _chain = c);
                            },
                );
              }).toList(),
            );
          },
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
            proposal == null ? l10n.wcCreateQr : l10n.wcCreateQrNew,
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
          if (!_init!.relayPairing) ...[
            Material(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.wcRelayDisabledBanner,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (_init!.relayPairing) ...[
            WcQrSessionCard(
              session: proposal,
              status: _status,
              qrFooterText: l10n.wcQrFooterLoginShort,
              onExpired: _onSessionExpiredUi,
              onRefresh: _createSession,
            ),
            if (_showDeepLinks) ...[
              const SizedBox(height: 12),
              WcDeepLinkLauncher(session: proposal),
            ],
          ],
          const SizedBox(height: 16),
          Text(
            l10n.wcMessageToSign,
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
                  message: l10n.wcMessageCopied,
                  type: SnackBarType.success,
                );
              },
              icon: const Icon(Icons.copy, size: 18),
              label: Text(l10n.wcCopyMessage),
            ),
          ),
          if (_pollHasServerSignature && _wcAutoVerifyBusy) ...[
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(
                    l10n.wcCompletingLogin,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (!_pollHasServerSignature) ...[
            if (widget.tronMobileQrEntry) ...[
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.wcReownQrDescription,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressCtrl,
                decoration: InputDecoration(
                  labelText: l10n.wcSignedWalletAddress,
                  border: const OutlineInputBorder(),
                  hintText: '0x… / Solana',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _signatureCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.wcSignatureField,
                  border: const OutlineInputBorder(),
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
                    : Text(l10n.wcVerifyAndLogin),
              ),
            ],
          ],
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
                  Icon(
                    widget.tronMobileQrEntry && !kIsWeb
                        ? Icons.link
                        : Icons.qr_code_2,
                    color: widget.tronMobileQrEntry && !kIsWeb
                        ? const Color(0xFFEF0027)
                        : theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.tronMobileQrEntry && !kIsWeb
                          ? l10n.desktopTronlinkDialogTitle
                          : (kIsWeb
                              ? l10n.wcLoginTitleWeb
                              : l10n.wcLoginTitleNative),
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
                    OnchainSandboxOperatorBanner(l10n: l10n),
                    if (widget.tronMobileQrEntry && !kIsWeb) ...[
                      if (_tronQrEntryUnavailable) ...[
                        Text(
                          l10n.requestFailed,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.wcWcSupportsEvmSolanaTron,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ] else ...[
                        _buildWcManualFlow(
                          context,
                          theme,
                          l10n,
                          proposal,
                          signingMessage,
                        ),
                      ],
                    ] else if (kIsWeb) ...[
                      Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l10n.wcWebRecommendExtension,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                onPressed: _webExtensionBusy
                                    ? null
                                    : _webTronLinkExtensionLogin,
                                icon: _webExtensionBusy
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.link),
                                label: Text(l10n.wcWebTronLinkExtension),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: Text(l10n.wcWebAdvancedWcTitle),
                        subtitle: Text(
                          l10n.wcWebAdvancedWcSubtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildWcManualFlow(
                              context,
                              theme,
                              l10n,
                              proposal,
                              signingMessage,
                            ),
                          ),
                        ],
                      ),
                    ] else if (!ReownWalletAuthConfig.isRuntimeSupported) ...[
                      _buildReownNativeSection(theme, l10n),
                      const SizedBox(height: 12),
                      _buildWcManualFlow(
                        context,
                        theme,
                        l10n,
                        proposal,
                        signingMessage,
                      ),
                    ] else if (!widget.tronMobileQrEntry) ...[
                      _buildReownNativeSection(theme, l10n),
                      const SizedBox(height: 12),
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        initiallyExpanded: false,
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
                              context,
                              theme,
                              l10n,
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
