import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/presentation/providers/withdrawal_management_provider.dart';
import 'package:crypto_trading_app/data/models/admin_withdrawal_model.dart';

class WithdrawalDetailScreen extends StatefulWidget {
  final String txId;

  const WithdrawalDetailScreen({super.key, required this.txId});

  @override
  State<WithdrawalDetailScreen> createState() => _WithdrawalDetailScreenState();
}

class _WithdrawalDetailScreenState extends State<WithdrawalDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WithdrawalManagementProvider>().loadDetail(widget.txId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.withdrawalDetailTitle),
      ),
      body: Consumer<WithdrawalManagementProvider>(
        builder: (_, p, __) {
          if (p.isLoading && p.selectedDetail == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (p.error != null && p.selectedDetail == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(p.error!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => p.loadDetail(widget.txId),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }
          final w = p.selectedDetail;
          if (w == null) {
            return Center(child: Text(l10n.withdrawalNotFound));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _UserInfoCard(withdrawal: w, l10n: l10n),
                const SizedBox(height: 16),
                _TransactionCard(withdrawal: w, l10n: l10n),
                const SizedBox(height: 16),
                _StatusTimeline(withdrawal: w, l10n: l10n),
                if (w.status == 'PENDING') ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: p.isSubmitting
                              ? null
                              : () async {
                                  final ok = await p.approve(w.txId);
                                  if (mounted) {
                                    if (ok) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(l10n.withdrawalApprovedSnack)),
                                      );
                                    } else if (p.error != null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(p.error!)),
                                      );
                                    }
                                  }
                                },
                          icon: const Icon(Icons.check_circle_outline),
                          label: Text(l10n.withdrawalApproveButton),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: p.isSubmitting
                              ? null
                              : () => _showRejectDialog(context, p, w),
                          icon: const Icon(Icons.cancel_outlined),
                          label: Text(l10n.withdrawalRejectButton),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _showRejectDialog(
    BuildContext context,
    WithdrawalManagementProvider p,
    AdminWithdrawalModel w,
  ) {
    final l10n = AppLocalizations.of(context);
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.withdrawalRejectDialogTitle),
        content: TextField(
          controller: reasonController,
          decoration: InputDecoration(
            hintText: l10n.withdrawalRejectReasonHint,
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await p.reject(w.txId, reason: reasonController.text.trim());
              if (mounted) {
                if (ok) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.withdrawalRejectedSnack)),
                  );
                } else if (p.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(p.error!)),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.withdrawalRejectButton),
          ),
        ],
      ),
    );
  }
}

class _UserInfoCard extends StatelessWidget {
  final AdminWithdrawalModel withdrawal;
  final AppLocalizations l10n;

  const _UserInfoCard({required this.withdrawal, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.withdrawalUserInfoTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    (withdrawal.userDisplayName.isNotEmpty
                            ? withdrawal.userDisplayName[0]
                            : '?')
                        .toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        withdrawal.userDisplayName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (withdrawal.userEmail != null)
                        Text(
                          withdrawal.userEmail!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      if (withdrawal.userWalletBalance != null)
                        Text(
                          '${l10n.withdrawalBalanceLabel}: ${FormatUtils.formatDecimalAmountDisplay(withdrawal.userWalletBalance!)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final AdminWithdrawalModel withdrawal;
  final AppLocalizations l10n;

  const _TransactionCard({required this.withdrawal, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.withdrawalTransactionTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _Row(label: l10n.withdrawalNetworkLabel, value: withdrawal.chain),
            _Row(label: l10n.withdrawalAmountLabel, value: FormatUtils.formatDecimalAmountDisplay(withdrawal.amount)),
            _Row(label: l10n.withdrawalDestinationLabel, value: withdrawal.toAddress),
            _Row(label: l10n.withdrawalTimeLabel, value: DateFormat('dd/MM/yyyy HH:mm').format(withdrawal.createdAt.toLocal())),
            if (withdrawal.txHash != null && withdrawal.txHash!.isNotEmpty)
              _Row(label: l10n.withdrawalTxHashLabel, value: withdrawal.txHash!),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final AdminWithdrawalModel withdrawal;
  final AppLocalizations l10n;

  const _StatusTimeline({required this.withdrawal, required this.l10n});

  @override
  Widget build(BuildContext context) {
    // REQUESTED → APPROVED/REJECTED → SENT → COMPLETED
    final steps = [l10n.withdrawalStatusRequested, l10n.withdrawalStatusApproved, l10n.withdrawalStatusSent, l10n.withdrawalStatusCompleted];
    int current = 0;
    bool rejected = false;
    switch (withdrawal.status) {
      case 'PENDING':
        current = 0; // at REQUESTED
        break;
      case 'CONFIRMING':
        current = 2; // at SENT
        break;
      case 'COMPLETED':
        current = 3;
        break;
      case 'FAILED':
        rejected = true;
        current = 1; // rejected at approval step
        break;
      default:
        current = 0;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.withdrawalStatusLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...List.generate(steps.length, (i) {
              final done = i < current || (i == current && !rejected) || rejected;
              final isRejectedStep = rejected && i == 1;
              return Row(
                children: [
                  Icon(
                    done
                        ? (isRejectedStep ? Icons.cancel : Icons.check_circle)
                        : Icons.radio_button_unchecked,
                    size: 20,
                    color: done
                        ? (isRejectedStep ? Colors.red : Colors.green)
                        : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isRejectedStep ? l10n.withdrawalStatusRejected : steps[i],
                    style: TextStyle(
                      color: isRejectedStep ? Colors.red : (done ? null : Colors.grey),
                      fontWeight: i == current ? FontWeight.w600 : null,
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
