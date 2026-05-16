import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/admin/withdrawal_management/presentation/providers/withdrawal_management_provider.dart';
import 'package:crypto_trading_app/features/admin/withdrawal_management/data/models/admin_withdrawal_model.dart';

/// Shared reconciliation action widget for CONFIRMING / FAILED withdrawals.
/// Used by both the bottom-sheet (_WithdrawalDetailSheet in withdrawal_management_screen.dart)
/// and the full-screen detail view (withdrawal_detail_screen.dart).
class WithdrawalReconcileButtons extends StatefulWidget {
  final AdminWithdrawalModel withdrawal;
  final AppLocalizations l10n;
  final bool isFailed;
  final void Function({required bool success, String? errorMessage}) onActionResult;

  const WithdrawalReconcileButtons({
    super.key,
    required this.withdrawal,
    required this.l10n,
    this.isFailed = false,
    required this.onActionResult,
  });

  @override
  State<WithdrawalReconcileButtons> createState() => WithdrawalReconcileButtonsState();
}

enum WithdrawalReconcileActionState { idle, loading, success, error }

class WithdrawalReconcileButtonsState extends State<WithdrawalReconcileButtons> {
  WithdrawalReconcileActionState _state = WithdrawalReconcileActionState.idle;
  String? _lastError;
  String? _pendingAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isBusy = _state == WithdrawalReconcileActionState.loading;

    if (widget.isFailed) {
      return _buildFailedActions(scheme, isBusy);
    }
    return _buildConfirmingActions(scheme, isBusy);
  }

  Widget _buildFailedActions(ColorScheme scheme, bool isBusy) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(
          top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.errorContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: scheme.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Giao dịch thất bại. Nếu người dùng đã bị trừ tiền nhưng blockchain tx không thành công, hãy dùng hành động Hoàn tiền.',
                      style: TextStyle(fontSize: 12, color: scheme.error),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              child: FilledButton.icon(
                onPressed: isBusy ? null : () => _showReconcileDialog(context, 'force_refund'),
                icon: _state == WithdrawalReconcileActionState.loading && _pendingAction == 'force_refund'
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.replay),
                label: Text(widget.l10n.withdrawalForceRefundLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmingActions(ColorScheme scheme, bool isBusy) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(
          top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Giao dịch đang bị stuck ở trạng thái chờ xác nhận blockchain. Hãy kiểm tra txHash trên blockchain và chọn hành động phù hợp.',
                      style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: isBusy ? null : () => _showReconcileDialog(context, 'settle'),
                      icon: _state == WithdrawalReconcileActionState.loading && _pendingAction == 'settle'
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.sync, size: 18),
                      label: Text(widget.l10n.withdrawalReconcileSettleLabel, style: const TextStyle(fontSize: 13)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: FilledButton.icon(
                      onPressed: isBusy ? null : () => _showReconcileDialog(context, 'force_complete'),
                      icon: _state == WithdrawalReconcileActionState.loading && _pendingAction == 'force_complete'
                          ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: scheme.onPrimary))
                          : const Icon(Icons.check_circle_outline, size: 18),
                      label: Text(widget.l10n.withdrawalForceCompleteLabel, style: const TextStyle(fontSize: 13)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                onPressed: isBusy ? null : () => _showReconcileDialog(context, 'force_fail'),
                icon: _state == WithdrawalReconcileActionState.loading && _pendingAction == 'force_fail'
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.cancel_outlined, size: 18),
                style: OutlinedButton.styleFrom(foregroundColor: scheme.error),
                label: Text(widget.l10n.withdrawalForceFailLabel, style: const TextStyle(fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReconcileDialog(BuildContext context, String action) {
    final l10n = widget.l10n;
    String title;
    String content;
    String confirmLabel;

    switch (action) {
      case 'settle':
        title = l10n.withdrawalReconcileSettleTitle;
        content = l10n.withdrawalReconcileSettleContent;
        confirmLabel = l10n.confirm;
        break;
      case 'force_complete':
        title = l10n.withdrawalForceCompleteTitle;
        content = l10n.withdrawalForceCompleteContent;
        confirmLabel = l10n.confirm;
        break;
      case 'force_fail':
        title = l10n.withdrawalForceFailTitle;
        content = l10n.withdrawalForceFailContent;
        confirmLabel = l10n.withdrawalForceFailConfirmAction;
        break;
      case 'force_refund':
        title = l10n.withdrawalForceRefundTitle;
        content = l10n.withdrawalForceRefundContent;
        confirmLabel = l10n.confirm;
        break;
      default:
        return;
    }

    final reasonCtrl = TextEditingController();
    final isForceAction = action == 'force_fail' || action == 'force_refund';

    showDialog(
      context: context,
      barrierDismissible: _state != WithdrawalReconcileActionState.loading,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final isLoading = _state == WithdrawalReconcileActionState.loading && _pendingAction == action;
          return AlertDialog(
            title: Row(
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    action == 'force_fail'
                        ? Icons.cancel_outlined
                        : action == 'force_refund'
                            ? Icons.replay
                            : Icons.sync,
                    color: action == 'force_fail' || action == 'force_refund'
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                const SizedBox(width: 10),
                Expanded(child: Text(title)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(content),
                if (isForceAction) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: reasonCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.withdrawalRejectReasonLabel,
                      hintText: l10n.withdrawalRejectReasonHint,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    enabled: !isLoading,
                  ),
                ],
                if (_lastError != null && _pendingAction == action) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Theme.of(context).colorScheme.error,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_lastError!, style: const TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              if (!isLoading)
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.cancel),
                ),
              FilledButton(
                onPressed: isLoading ? null : () => _handleReconcile(ctx, action, reasonCtrl.text.trim()),
                style: action == 'force_fail' || action == 'force_refund'
                    ? FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                      )
                    : null,
                child: Text(confirmLabel),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleReconcile(
    BuildContext dialogContext,
    String action,
    String reason,
  ) async {
    Navigator.pop(dialogContext);

    setState(() {
      _state = WithdrawalReconcileActionState.loading;
      _lastError = null;
      _pendingAction = action;
    });

    final p = context.read<WithdrawalManagementProvider>();
    final result = await p.reconcile(
      widget.withdrawal.txId,
      action,
      reason: reason.isNotEmpty ? reason : null,
    );

    if (!mounted) return;

    if (result.success) {
      setState(() => _state = WithdrawalReconcileActionState.success);
      widget.onActionResult(success: true);
    } else {
      setState(() {
        _state = WithdrawalReconcileActionState.error;
        _lastError = result.error;
      });
      widget.onActionResult(success: false, errorMessage: result.error);
    }
  }
}
