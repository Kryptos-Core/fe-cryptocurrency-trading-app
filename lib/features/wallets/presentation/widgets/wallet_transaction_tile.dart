import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/features/wallets/domain/entities/wallet.dart';

/// Shared transaction tile widget for wallet ledger entries.
/// Provides consistent UI across all transaction types with i18n support,
/// dynamic icons, and colored amount display.
class WalletTransactionTile extends StatelessWidget {
  final WalletLedger ledger;
  final String? currencySymbol;
  final VoidCallback? onTap;

  const WalletTransactionTile({
    super.key,
    required this.ledger,
    this.currencySymbol,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isCredit = ledger.isCredit;
    final color = isCredit ? const Color(0xFF0F8A49) : const Color(0xFFB3261E);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon + type label
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getLedgerIcon(ledger.refType),
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Type label + ref ID
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getLedgerLabel(ledger.refType, l10n),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatRefId(ledger.refId),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              // Date + Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatDate(ledger.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isCredit ? '+' : '-'}${FormatUtils.formatDecimalAmountDisplay(ledger.amount)}${currencySymbol != null ? ' $currencySymbol' : ''}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getLedgerIcon(String refType) {
    switch (refType.toUpperCase()) {
      case 'DEPOSIT':
        return Icons.arrow_downward_rounded;
      case 'WITHDRAW':
        return Icons.arrow_upward_rounded;
      case 'TRADE':
        return Icons.swap_horiz_rounded;
      case 'ORDER':
        return Icons.shopping_cart_outlined;
      case 'TRANSFER':
        return Icons.people_outline_rounded;
      case 'ADJUST':
        return Icons.tune_rounded;
      case 'EXTERNAL_DEPOSIT':
        return Icons.cloud_download_outlined;
      case 'EXTERNAL_WITHDRAWAL':
        return Icons.cloud_upload_outlined;
      case 'EXTERNAL_SYNC':
        return Icons.sync_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _getLedgerLabel(String refType, AppLocalizations l10n) {
    switch (refType.toUpperCase()) {
      case 'DEPOSIT':
        return l10n.walletFilterDeposit;
      case 'WITHDRAW':
        return l10n.walletFilterWithdraw;
      case 'TRADE':
        return l10n.walletFilterTrade;
      case 'ORDER':
        return l10n.walletFilterOrder;
      case 'TRANSFER':
        return l10n.walletFilterTransfer;
      case 'ADJUST':
        return l10n.walletFilterAdjust;
      case 'EXTERNAL_DEPOSIT':
      case 'EXTERNAL_WITHDRAWAL':
      case 'EXTERNAL_SYNC':
        return l10n.walletFilterExternal;
      default:
        return refType;
    }
  }

  String _formatRefId(String refId) {
    if (refId.length <= 12) return refId;
    return '${refId.substring(0, 8)}...';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return DateFormat.Hm().format(date);
    } else if (diff.inDays == 1) {
      return 'Hôm qua';
    } else if (diff.inDays < 7) {
      return DateFormat.E('vi').format(date);
    } else {
      return DateFormat('dd/MM/yy').format(date);
    }
  }
}

/// Compact transaction row for use in tables (desktop/tablet layout).
/// Shows all columns: Date, Type, Amount, Reference.
class WalletTransactionRow extends StatelessWidget {
  final WalletLedger ledger;
  final String? currencySymbol;

  const WalletTransactionRow({
    super.key,
    required this.ledger,
    this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isCredit = ledger.isCredit;
    final color = isCredit ? const Color(0xFF0F8A49) : const Color(0xFFB3261E);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Date
          SizedBox(
            width: 130,
            child: Text(
              dateFormat.format(ledger.createdAt),
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
          // Type with icon
          SizedBox(
            width: 120,
            child: Row(
              children: [
                Icon(
                  _getRowIcon(ledger.refType),
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _getRowLabel(ledger.refType, l10n),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Amount
          Expanded(
            child: Text(
              '${isCredit ? '+' : '-'}${FormatUtils.formatDecimalAmountDisplay(ledger.amount)}${currencySymbol != null ? ' $currencySymbol' : ''}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          // Reference ID
          SizedBox(
            width: 160,
            child: Text(
              _formatRefId(ledger.refId),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Balance after
          SizedBox(
            width: 120,
            child: Text(
              l10n.walletBalanceAfter(FormatUtils.formatDecimalAmountDisplay(ledger.balanceAfter)),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRowIcon(String refType) {
    switch (refType.toUpperCase()) {
      case 'DEPOSIT':
        return Icons.arrow_downward_rounded;
      case 'WITHDRAW':
        return Icons.arrow_upward_rounded;
      case 'TRADE':
        return Icons.swap_horiz_rounded;
      case 'ORDER':
        return Icons.shopping_cart_outlined;
      case 'TRANSFER':
        return Icons.people_outline_rounded;
      case 'ADJUST':
        return Icons.tune_rounded;
      case 'EXTERNAL_DEPOSIT':
        return Icons.cloud_download_outlined;
      case 'EXTERNAL_WITHDRAWAL':
        return Icons.cloud_upload_outlined;
      case 'EXTERNAL_SYNC':
        return Icons.sync_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _getRowLabel(String refType, AppLocalizations l10n) {
    switch (refType.toUpperCase()) {
      case 'DEPOSIT':
        return l10n.walletFilterDeposit;
      case 'WITHDRAW':
        return l10n.walletFilterWithdraw;
      case 'TRADE':
        return l10n.walletFilterTrade;
      case 'ORDER':
        return l10n.walletFilterOrder;
      case 'TRANSFER':
        return l10n.walletFilterTransfer;
      case 'ADJUST':
        return l10n.walletFilterAdjust;
      case 'EXTERNAL_DEPOSIT':
      case 'EXTERNAL_WITHDRAWAL':
      case 'EXTERNAL_SYNC':
        return l10n.walletFilterExternal;
      default:
        return refType;
    }
  }

  String _formatRefId(String refId) {
    if (refId.length <= 12) return refId;
    return '${refId.substring(0, 8)}...';
  }
}
