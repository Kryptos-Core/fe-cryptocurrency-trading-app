import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/wc_session_status.dart';
import 'package:crypto_trading_app/presentation/providers/blockchain_provider.dart';

/// WcSessionPoller
///
/// Widget vô hình — poll BE mỗi 2 giây để kiểm tra trạng thái WC session.
/// Khi status = signed → gọi [onSigned] để trigger submit signature flow.
/// Khi status = expired → gọi [onExpired].
///
/// Pattern: Observer Pattern — lắng nghe thay đổi từ BE
class WcSessionPoller extends StatefulWidget {
  final String sessionId;
  final VoidCallback? onSigned;
  final VoidCallback? onExpired;
  final Widget child;

  const WcSessionPoller({
    super.key,
    required this.sessionId,
    required this.child,
    this.onSigned,
    this.onExpired,
  });

  @override
  State<WcSessionPoller> createState() => _WcSessionPollerState();
}

class _WcSessionPollerState extends State<WcSessionPoller> {
  Timer? _pollTimer;
  bool _isPolling = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (_isPolling || !mounted) return;
      _isPolling = true;

      try {
        final provider =
            Provider.of<BlockchainProvider>(context, listen: false);
        final status =
            await provider.pollWcSessionStatus(widget.sessionId);

        if (!mounted) return;

        if (status == WcSessionStatus.signed) {
          _stopPolling();
          widget.onSigned?.call();
        } else if (status == WcSessionStatus.expired ||
            status == WcSessionStatus.failed) {
          _stopPolling();
          widget.onExpired?.call();
        }
      } finally {
        _isPolling = false;
      }
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
