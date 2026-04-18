import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/wc_session_proposal.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/wc_session_status.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'wc_session_status_l10n.dart';

/// WcQrSessionCard
///
/// Hiển thị QR Code của WalletConnect session kèm:
///  - Countdown timer (5 phút)
///  - Status indicator (pending → connected → signed)
///  - Copy URI button
///  - Nút refresh khi session hết hạn
///
/// Pattern: Composite Widget — kết hợp QR display + status + timer
class WcQrSessionCard extends StatefulWidget {
  final WcSessionProposal session;
  final WcSessionStatus status;
  final VoidCallback? onExpired;
  final VoidCallback? onRefresh;
  /// Override hint under QR (e.g. đăng nhập vs liên kết ví)
  final String? qrFooterText;

  const WcQrSessionCard({
    super.key,
    required this.session,
    required this.status,
    this.onExpired,
    this.onRefresh,
    this.qrFooterText,
  });

  @override
  State<WcQrSessionCard> createState() => _WcQrSessionCardState();
}

class _WcQrSessionCardState extends State<WcQrSessionCard>
    with SingleTickerProviderStateMixin {
  late Timer _countdownTimer;
  Duration _remaining = Duration.zero;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _remaining = widget.session.remainingTime;

    // Pulse animation cho status indicator khi connected
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final remaining = widget.session.remainingTime;
      setState(() => _remaining = remaining);

      if (remaining == Duration.zero) {
        _countdownTimer.cancel();
        widget.onExpired?.call();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String get _countdownText {
    final m = _remaining.inMinutes;
    final s = _remaining.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color _statusColor(WcSessionStatus status) {
    switch (status) {
      case WcSessionStatus.pending:
        return Colors.orange;
      case WcSessionStatus.connected:
        return Colors.blue;
      case WcSessionStatus.signed:
        return Colors.green;
      case WcSessionStatus.expired:
        return Colors.red;
      case WcSessionStatus.failed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(WcSessionStatus status) {
    switch (status) {
      case WcSessionStatus.pending:
        return Icons.qr_code_scanner;
      case WcSessionStatus.connected:
        return Icons.link;
      case WcSessionStatus.signed:
        return Icons.check_circle;
      case WcSessionStatus.expired:
        return Icons.timer_off;
      case WcSessionStatus.failed:
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isExpired = widget.status == WcSessionStatus.expired ||
        _remaining == Duration.zero;
    final isSigned = widget.status == WcSessionStatus.signed;
    final isConnected = widget.status == WcSessionStatus.connected;
    final statusColor = _statusColor(widget.status);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.5),
          width: 1.5,
        ),
        color: theme.colorScheme.surface,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Status Row ──
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (_, child) => Opacity(
                  opacity: isConnected ? _pulseAnimation.value : 1.0,
                  child: child,
                ),
                child: Icon(_statusIcon(widget.status),
                    color: statusColor, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.status.label(l10n),
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Countdown
              if (!isExpired && !isSigned)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _remaining.inSeconds < 60
                        ? Colors.red.withOpacity(0.15)
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _countdownText,
                    style: theme.textTheme.bodySmall!.copyWith(
                      fontFamily: 'monospace',
                      color: _remaining.inSeconds < 60
                          ? Colors.red
                          : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          // ── QR Code ──
          if (!isExpired && !isSigned)
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: QrImageView(
                    data: widget.session.wcUri,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.qrFooterText ??
                      (widget.session.chain.networkFamily ==
                              OnChainNetworkFamily.solana
                          ? l10n.wcQrScanHintSolana
                          : l10n.wcQrScanHintEvm),
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Copy URI button
                OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: widget.session.wcUri));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.wcQrUriCopied)),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 14),
                  label: Text(l10n.wcQrCopyUri),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),

          // ── Success State ──
          if (isSigned)
            Column(
              children: [
                const Icon(Icons.check_circle,
                    color: Colors.green, size: 64),
                const SizedBox(height: 12),
                Text(
                  l10n.wcQrWalletLinkedCard,
                  style: theme.textTheme.titleMedium!.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

          // ── Expired State ──
          if (isExpired && !isSigned)
            Column(
              children: [
                const Icon(Icons.timer_off, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(
                  l10n.wcSessionExpiredFiveMin,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: widget.onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.wcQrCreateNew),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
