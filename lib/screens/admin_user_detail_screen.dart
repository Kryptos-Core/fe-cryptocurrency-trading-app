import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/utils/amount_input_formatter.dart';
import 'package:crypto_trading_app/core/utils/currency_amount_input.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/core/utils/avatar_url_helper.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/domain/entities/admin_wallet_adjustment.dart';
import 'package:crypto_trading_app/domain/entities/currency.dart';
import 'package:crypto_trading_app/domain/entities/onchain_transaction.dart';
import 'package:crypto_trading_app/domain/entities/user.dart';
import 'package:crypto_trading_app/domain/entities/user_security_change.dart';
import 'package:crypto_trading_app/presentation/providers/admin_users_provider.dart';
import 'package:crypto_trading_app/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/presentation/providers/currencies_provider.dart';
import 'admin_user_list_screen.dart' show UserRoleChip, UserStatusBadge;

/// Platform cash currency symbol — must match PLATFORM_CASH_CURRENCY_SYMBOL on BE
const _kPlatformCashSymbol = 'USDT';

class AdminUserDetailScreen extends StatefulWidget {
  final User user;

  /// When embedded=true the screen is rendered inside a panel (no Scaffold).
  final bool embedded;

  const AdminUserDetailScreen({
    super.key,
    required this.user,
    this.embedded = false,
  });

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const int _tabCount = 5;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<AdminUsersProvider>();
      // In embedded (master-detail) mode the parent list screen already
      // called selectUser() before building this widget, so calling it
      // again here would fire an extra notifyListeners() burst during the
      // very first paint and trigger mouse-tracker assertion cascades.
      if (!widget.embedded) {
        provider.selectUser(widget.user);
      }
      final auth = context.read<AuthProvider>();
      if (auth.canManageWallets) {
        provider.fetchSelectedUserWallets();
        provider.fetchSelectedUserAdjustments();
      }
      provider.fetchSelectedUserOnchainTxs();
      provider.fetchSelectedUserOrders();
      if (auth.canReviewSecurityRequests) {
        provider.fetchSelectedUserSecurityChanges();
      }
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _lazyLoadTab(_tabController.index);
      }
    });
  }

  void _lazyLoadTab(int index) {
    final provider = context.read<AdminUsersProvider>();
    final auth = context.read<AuthProvider>();
    switch (index) {
      case 0:
        if (provider.selectedUserWallets.isEmpty && auth.canManageWallets) {
          provider.fetchSelectedUserWallets();
        }
      case 1:
        if (provider.adjustments.isEmpty && auth.canManageWallets) {
          provider.fetchSelectedUserAdjustments();
        }
      case 2:
        if (provider.userOrders.isEmpty) {
          provider.fetchSelectedUserOrders();
        }
      case 3:
        if (provider.onchainTxs.isEmpty) {
          provider.fetchSelectedUserOnchainTxs();
        }
      case 4:
        if (provider.securityChanges.isEmpty && auth.canReviewSecurityRequests) {
          provider.fetchSelectedUserSecurityChanges();
        }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final auth = context.read<AuthProvider>();
    final u = widget.user;

    final appBar = AppBar(
      title: Text(u.fullName, overflow: TextOverflow.ellipsis),
      automaticallyImplyLeading: !widget.embedded,
      actions: [
        if (auth.canManageWallets)
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: AppLocalizations.of(context).refresh,
            onPressed: () {
              final p = context.read<AdminUsersProvider>();
              p.fetchSelectedUserWallets();
              p.fetchSelectedUserAdjustments();
              p.fetchSelectedUserOnchainTxs();
              p.fetchSelectedUserOrders();
            },
          ),
      ],
      bottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        tabs: [
          Tab(icon: const Icon(Icons.account_balance_wallet_outlined), text: AppLocalizations.of(context).adminUserDetailTabWallets),
          Tab(icon: const Icon(Icons.swap_vert), text: AppLocalizations.of(context).adminUserDetailTabAdjust),
          Tab(icon: const Icon(Icons.list_alt_outlined), text: AppLocalizations.of(context).adminUserDetailTabOrders),
          Tab(icon: const Icon(Icons.link), text: AppLocalizations.of(context).adminUserDetailTabOnchain),
          Tab(icon: const Icon(Icons.history_edu), text: AppLocalizations.of(context).adminUserDetailTabSecurity),
        ],
      ),
    );

    final body = Column(
      children: [
        _buildUserHeader(theme, colorScheme, u, auth),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _WalletsTab(auth: auth, selectedUser: widget.user),
              _AdjustHistoryTab(),
              _UserOrdersTab(),
              _OnchainTxTab(),
              _SecurityChangesTab(auth: auth),
            ],
          ),
        ),
      ],
    );

    if (widget.embedded) {
      // AppBar is a PreferredSizeWidget — it expects Scaffold to honour its
      // preferredSize.height.  Without that, the Column gives it unbounded
      // height, its internal RenderFlex is never laid out, and every mouse
      // event fires a "Cannot hit test a render box with no size" assertion
      // that cascades into an app freeze on Windows desktop.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 0,
            child: SizedBox(
              height: appBar.preferredSize.height,
              child: appBar,
            ),
          ),
          Expanded(child: body),
        ],
      );
    }

    return Scaffold(appBar: appBar, body: body);
  }

  Widget _buildUserHeader(
      ThemeData theme, ColorScheme colorScheme, User u, AuthProvider auth) {
    final dateStr =
        DateFormat('dd/MM/yyyy').format(u.createdAt.toLocal());
    final avatarUrl = resolveAvatarUrl(u.avatarUrl);

    return Container(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl) : null,
                backgroundColor: colorScheme.primaryContainer,
                onBackgroundImageError:
                    avatarUrl != null ? (_, __) {} : null,
                child: avatarUrl == null
                    ? Text(
                        _initials(u),
                        style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u.email,
                        style: theme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        UserRoleChip(role: u.role),
                        const SizedBox(width: 8),
                        UserStatusBadge(status: u.status),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('${AppLocalizations.of(context).adminUserDetailCreatedAtLabel}: $dateStr',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          if (auth.canManageWallets) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.arrow_downward, size: 16),
                    label: const Text('Nạp tiền'),
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding:
                            const EdgeInsets.symmetric(vertical: 10)),
                    onPressed: () =>
                        _showAdjustSheet(context, u, 'DEPOSIT'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.arrow_upward, size: 16),
                    label: const Text('Rút tiền'),
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding:
                            const EdgeInsets.symmetric(vertical: 10)),
                    onPressed: () =>
                        _showAdjustSheet(context, u, 'WITHDRAW'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }

  void _showAdjustSheet(BuildContext context, User user, String initialType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AdjustBalanceBottomSheet(
        user: user,
        initialType: initialType,
        onSuccess: () {
          final p = context.read<AdminUsersProvider>();
          p.fetchSelectedUserAdjustments();
          p.fetchSelectedUserWallets();
          _tabController.animateTo(1);
        },
      ),
    );
  }

  String _initials(User u) {
    final first = u.firstName.trim();
    final last = u.lastName.trim();
    if (first.isNotEmpty && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    } else if (first.isNotEmpty) {
      return first[0].toUpperCase();
    } else if (u.email.isNotEmpty) {
      return u.email[0].toUpperCase();
    }
    return '?';
  }
}

// ── Tab: Ví ──────────────────────────────────────────────────────────────────

class _WalletsTab extends StatelessWidget {
  final AuthProvider auth;
  final User? selectedUser;

  const _WalletsTab({required this.auth, this.selectedUser});

  void _openAdjustForWallet(BuildContext context, AdminUserWalletItem wallet) {
    final user = selectedUser;
    if (user == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AdjustBalanceBottomSheet(
        user: user,
        initialType: 'DEPOSIT',
        initialCurrencyId: wallet.currencyId,
        onSuccess: () {
          final p = context.read<AdminUsersProvider>();
          p.fetchSelectedUserAdjustments();
          p.fetchSelectedUserWallets();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!auth.canManageWallets) {
      return const _PermissionDenied(
          message: 'Bạn không có quyền xem số dư ví người dùng');
    }

    return Consumer<AdminUsersProvider>(
      builder: (_, provider, __) {
        if (provider.isLoadingWallets) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.walletsError != null) {
          return _ErrorRetry(
            message: provider.walletsError!,
            onRetry: provider.fetchSelectedUserWallets,
          );
        }
        if (provider.selectedUserWallets.isEmpty) {
          return const Center(child: Text('Người dùng chưa có ví nào'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: provider.selectedUserWallets.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final w = provider.selectedUserWallets[i];
            final colorScheme = Theme.of(context).colorScheme;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: colorScheme.secondaryContainer,
                child: Text(w.symbol.isEmpty ? '?' : w.symbol[0],
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              title: Text('${w.symbol} — ${w.name}'),
              subtitle: Text(
                  'Khả dụng: ${FormatUtils.formatDecimalAmountDisplay(w.available)}  |  Đóng băng: ${FormatUtils.formatDecimalAmountDisplay(w.frozen)}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    FormatUtils.formatDecimalAmountDisplay(w.total),
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: w.hasBalance
                            ? Colors.green
                            : colorScheme.onSurfaceVariant),
                  ),
                  if (selectedUser != null) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline,
                          size: 20, color: colorScheme.primary),
                      tooltip: 'Nạp/Rút ${w.symbol}',
                      onPressed: () => _openAdjustForWallet(context, w),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Tab: Lịch sử Nạp/Rút ─────────────────────────────────────────────────────

class _AdjustHistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    if (!auth.canManageWallets) {
      return const _PermissionDenied(
          message: 'Bạn không có quyền xem lịch sử điều chỉnh');
    }

    return Consumer<AdminUsersProvider>(
      builder: (_, provider, __) {
        if (provider.isLoadingAdjustments) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.adjustmentsError != null) {
          return _ErrorRetry(
            message: provider.adjustmentsError!,
            onRetry: provider.fetchSelectedUserAdjustments,
          );
        }
        if (provider.adjustments.isEmpty) {
          return const Center(child: Text('Chưa có lịch sử điều chỉnh nào'));
        }

        return RefreshIndicator(
          onRefresh: provider.fetchSelectedUserAdjustments,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.adjustments.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) =>
                _AdjustmentTile(item: provider.adjustments[i]),
          ),
        );
      },
    );
  }
}

// ── Tab: Lệnh ────────────────────────────────────────────────────────────────

class _UserOrdersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AdminUsersProvider>(
      builder: (_, provider, __) {
        if (provider.isLoadingOrders) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.ordersError != null) {
          return _ErrorRetry(
            message: provider.ordersError!,
            onRetry: provider.fetchSelectedUserOrders,
          );
        }
        if (provider.userOrders.isEmpty) {
          return const Center(
              child: Text('Người dùng chưa có lệnh nào'));
        }

        return RefreshIndicator(
          onRefresh: provider.fetchSelectedUserOrders,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.userOrders.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) =>
                _OrderTile(order: provider.userOrders[i]),
          ),
        );
      },
    );
  }
}

// ── Tab: Giao dịch Onchain ────────────────────────────────────────────────────

class _OnchainTxTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AdminUsersProvider>(
      builder: (_, provider, __) {
        if (provider.isLoadingOnchainTxs) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.onchainTxsError != null) {
          return _ErrorRetry(
            message: provider.onchainTxsError!,
            onRetry: provider.fetchSelectedUserOnchainTxs,
          );
        }
        if (provider.onchainTxs.isEmpty) {
          return const Center(child: Text('Không có giao dịch onchain nào'));
        }

        return RefreshIndicator(
          onRefresh: provider.fetchSelectedUserOnchainTxs,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.onchainTxs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) =>
                _OnchainTxTile(tx: provider.onchainTxs[i]),
          ),
        );
      },
    );
  }
}

// ── Tab: Thay đổi Thông tin ───────────────────────────────────────────────────

class _SecurityChangesTab extends StatelessWidget {
  final AuthProvider auth;
  const _SecurityChangesTab({required this.auth});

  @override
  Widget build(BuildContext context) {
    if (!auth.canReviewSecurityRequests) {
      return const _PermissionDenied(
          message:
              'Bạn không có quyền xem lịch sử thay đổi thông tin');
    }

    return Consumer<AdminUsersProvider>(
      builder: (_, provider, __) {
        if (provider.isLoadingSecurityChanges) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.securityChangesError != null) {
          return _ErrorRetry(
            message: provider.securityChangesError!,
            onRetry: provider.fetchSelectedUserSecurityChanges,
          );
        }
        if (provider.securityChanges.isEmpty) {
          return const Center(
              child: Text('Không có lịch sử thay đổi nào'));
        }

        return RefreshIndicator(
          onRefresh: provider.fetchSelectedUserSecurityChanges,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.securityChanges.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) =>
                _SecurityChangeTile(item: provider.securityChanges[i]),
          ),
        );
      },
    );
  }
}

// ── Tile Widgets ──────────────────────────────────────────────────────────────

class _AdjustmentTile extends StatelessWidget {
  final AdminWalletAdjustment item;
  const _AdjustmentTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDeposit = item.isDeposit;
    final color = isDeposit ? Colors.green : Colors.red;
    final sign = isDeposit ? '+' : '-';
    final dateStr =
        DateFormat('dd/MM/yyyy HH:mm').format(item.createdAt.toLocal());

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(
          isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
          color: color,
          size: 20,
        ),
      ),
      title: Text(
        '$sign${FormatUtils.formatDecimalAmountDisplay(item.amount)} ${item.currencySymbol ?? item.currencyId}',
        style: TextStyle(fontWeight: FontWeight.w600, color: color),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.actorEmail != null)
            Text('Bởi: ${item.actorEmail}',
                style: const TextStyle(fontSize: 12)),
          if (item.note != null && item.note!.isNotEmpty)
            Text('Ghi chú: ${item.note}',
                style: const TextStyle(
                    fontSize: 12, fontStyle: FontStyle.italic)),
          Text(dateStr,
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      isThreeLine: true,
    );
  }
}

class _OrderTile extends StatelessWidget {
  final Map<String, dynamic> order;
  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final side = order['side']?.toString() ?? '';
    final status = order['status']?.toString() ?? '';
    final type = order['type']?.toString() ?? '';
    final amount = order['amount']?.toString() ?? '0';
    final price = order['price']?.toString();
    final pairSymbol = order['pair_symbol']?.toString() ??
        order['pairSymbol']?.toString() ??
        order['market_symbol']?.toString() ??
        '';
    final createdAtRaw = order['created_at'] ?? order['createdAt'];
    final createdAt = createdAtRaw != null
        ? DateTime.tryParse(createdAtRaw.toString())
        : null;
    final dateStr = createdAt != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(createdAt.toLocal())
        : '';

    final isBuy = side == 'BUY';
    final sideColor = isBuy ? Colors.green : Colors.red;
    final (statusColor, statusLabel) = _statusInfo(status);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: sideColor.withValues(alpha: 0.1),
        child: Icon(
          isBuy ? Icons.trending_up : Icons.trending_down,
          color: sideColor,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Text(
            '${isBuy ? 'MUA' : 'BÁN'} $pairSymbol',
            style: TextStyle(fontWeight: FontWeight.w600, color: sideColor),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                  fontSize: 10,
                  color: statusColor,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SL: ${FormatUtils.formatDecimalAmountDisplay(amount)}${price != null ? ' · Giá: ${FormatUtils.formatDecimalAmountDisplay(price)}' : ''} · $type',
            style: const TextStyle(fontSize: 12),
          ),
          if (dateStr.isNotEmpty)
            Text(dateStr,
                style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      isThreeLine: true,
    );
  }

  (Color, String) _statusInfo(String status) {
    switch (status) {
      case 'FILLED':
        return (Colors.green, 'Khớp xong');
      case 'PARTIAL':
        return (Colors.blue, 'Khớp một phần');
      case 'OPEN':
        return (Colors.orange, 'Đang mở');
      case 'CANCELLED':
        return (Colors.grey, 'Huỷ');
      case 'REJECTED':
        return (Colors.red, 'Từ chối');
      default:
        return (Colors.grey, status);
    }
  }
}

class _OnchainTxTile extends StatelessWidget {
  final OnchainTransaction tx;
  const _OnchainTxTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isDeposit = tx.isDeposit;
    final color = tx.isFailed
        ? Colors.red
        : isDeposit
            ? Colors.green
            : Colors.orange;
    final dateStr =
        DateFormat('dd/MM/yyyy HH:mm').format(tx.createdAt.toLocal());

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(
          tx.isFailed
              ? Icons.error_outline
              : isDeposit
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
          color: color,
          size: 20,
        ),
      ),
      title: Text(
        '${isDeposit ? '+' : '-'}${FormatUtils.formatDecimalAmountDisplay(tx.amount)}',
        style: TextStyle(fontWeight: FontWeight.w600, color: color),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${tx.chain} · ${_statusLabel(tx.status)}',
              style: const TextStyle(fontSize: 12)),
          if (tx.txHash != null)
            Text(
              'TX: ${tx.txHash!.length > 20 ? '${tx.txHash!.substring(0, 20)}...' : tx.txHash!}',
              style:
                  const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
          Text(dateStr,
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      isThreeLine: true,
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'COMPLETED':
        return 'Hoàn thành';
      case 'CONFIRMING':
        return 'Đang xác nhận';
      case 'PENDING':
        return 'Đang chờ';
      case 'FAILED':
        return 'Thất bại';
      default:
        return status;
    }
  }
}

class _SecurityChangeTile extends StatelessWidget {
  final UserSecurityChange item;
  const _SecurityChangeTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusLabel) = _statusInfo(item.status);
    final dateStr =
        DateFormat('dd/MM/yyyy HH:mm').format(item.requestedAt.toLocal());

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: statusColor.withValues(alpha: 0.1),
        child: Icon(
          item.changeType == 'EMAIL_CHANGE'
              ? Icons.email_outlined
              : Icons.lock_outline,
          color: statusColor,
          size: 20,
        ),
      ),
      title: Text(item.changeTypeLabel,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(statusLabel,
                    style: TextStyle(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          if (item.reviewNote != null && item.reviewNote!.isNotEmpty)
            Text('Ghi chú: ${item.reviewNote}',
                style: const TextStyle(
                    fontSize: 12, fontStyle: FontStyle.italic)),
          Text(dateStr,
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      isThreeLine: true,
    );
  }

  (Color, String) _statusInfo(String status) {
    switch (status) {
      case 'APPROVED':
        return (Colors.green, 'Đã duyệt');
      case 'REJECTED':
        return (Colors.red, 'Từ chối');
      default:
        return (Colors.orange, 'Chờ duyệt');
    }
  }
}

// ── Adjust Balance Bottom Sheet ───────────────────────────────────────────────

class AdjustBalanceBottomSheet extends StatefulWidget {
  final User user;
  final String initialType;

  /// Pre-select a specific currency by its ID (e.g. when tapping a wallet item).
  final String? initialCurrencyId;
  final VoidCallback? onSuccess;

  const AdjustBalanceBottomSheet({
    super.key,
    required this.user,
    this.initialType = 'DEPOSIT',
    this.initialCurrencyId,
    this.onSuccess,
  });

  @override
  State<AdjustBalanceBottomSheet> createState() =>
      _AdjustBalanceBottomSheetState();
}

class _AdjustBalanceBottomSheetState extends State<AdjustBalanceBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late String _selectedType;
  Currency? _selectedCurrency;
  bool _isLoadingCurrencies = true;
  List<Currency> _availableCurrencies = [];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAllCurrencies());
  }

  /// Loads all tradable currencies and ensures USDT (platform cash) is included.
  Future<void> _loadAllCurrencies() async {
    if (!mounted) return;
    final currProvider = context.read<CurrenciesProvider>();
    await currProvider.fetchTradableCurrencies();
    if (!mounted) return;

    final currencies = List<Currency>.from(currProvider.tradableCurrencies);

    // Ensure platform cash (USDT) is included even if not tradable
    final hasUsdt =
        currencies.any((c) => c.symbol.toUpperCase() == _kPlatformCashSymbol);
    if (!hasUsdt) {
      await currProvider.getCurrencyBySymbol(_kPlatformCashSymbol);
      if (!mounted) return;
      if (currProvider.selectedCurrency != null) {
        currencies.insert(0, currProvider.selectedCurrency!);
      }
    }

    setState(() {
      _availableCurrencies = currencies;
      _selectedCurrency = _resolveInitialCurrency(currencies);
      _isLoadingCurrencies = false;
    });
  }

  Currency? _resolveInitialCurrency(List<Currency> currencies) {
    if (currencies.isEmpty) return null;
    // Honor pre-selected currency (e.g. from tapping a wallet row)
    if (widget.initialCurrencyId != null) {
      final match = currencies
          .where((c) => c.currencyId == widget.initialCurrencyId)
          .firstOrNull;
      if (match != null) return match;
    }
    // Fall back to USDT, then first available
    return currencies.firstWhere(
      (c) => c.symbol.toUpperCase() == _kPlatformCashSymbol,
      orElse: () => currencies.first,
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCurrency == null) {
      showAppSnackBar(context,
          message: 'Vui lòng chọn loại coin', type: SnackBarType.warning);
      return;
    }

    final provider = context.read<AdminUsersProvider>();
    final success = await provider.adjustBalance(
      userId: widget.user.id,
      currencyId: _selectedCurrency!.currencyId,
      amount: parseAmountInput(_amountController.text),
      type: _selectedType,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      showAppSnackBar(
        context,
        message: _selectedType == 'DEPOSIT'
            ? 'Nạp ${_selectedCurrency!.symbol} thành công!'
            : 'Rút ${_selectedCurrency!.symbol} thành công!',
        type: SnackBarType.success,
      );
      widget.onSuccess?.call();
      Navigator.pop(context);
    } else {
      showAppSnackBar(
        context,
        message: provider.adjustError ?? 'Có lỗi xảy ra. Vui lòng thử lại.',
        type: SnackBarType.error,
      );
    }
  }

  void _showCurrencyPicker() {
    final userWallets = context.read<AdminUsersProvider>().selectedUserWallets;
    showDialog<Currency>(
      context: context,
      builder: (_) => _CurrencyPickerDialog(
        currencies: _availableCurrencies,
        userWallets: userWallets,
        selectedCurrencyId: _selectedCurrency?.currencyId,
      ),
    ).then((selected) {
      if (selected != null && mounted) {
        setState(() {
          _selectedCurrency = selected;
          _amountController.clear();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDeposit = _selectedType == 'DEPOSIT';

    // Live balance lookup for the selected currency
    final wallets = context.watch<AdminUsersProvider>().selectedUserWallets;
    final currentWallet = _selectedCurrency != null
        ? wallets
            .where((w) => w.currencyId == _selectedCurrency!.currencyId)
            .firstOrNull
        : null;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                isDeposit ? 'Nạp coin cho người dùng' : 'Rút coin từ người dùng',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                widget.user.email,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              // Deposit / Withdraw toggle
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                      value: 'DEPOSIT',
                      label: Text('Nạp coin'),
                      icon: Icon(Icons.arrow_downward)),
                  ButtonSegment(
                      value: 'WITHDRAW',
                      label: Text('Rút coin'),
                      icon: Icon(Icons.arrow_upward)),
                ],
                selected: {_selectedType},
                onSelectionChanged: (s) =>
                    setState(() => _selectedType = s.first),
                style: ButtonStyle(
                  iconColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return _selectedType == 'DEPOSIT'
                          ? Colors.green
                          : Colors.red;
                    }
                    return null;
                  }),
                ),
              ),
              const SizedBox(height: 16),
              // Currency picker
              if (_isLoadingCurrencies)
                const LinearProgressIndicator()
              else
                _CurrencyPickerTile(
                  selectedCurrency: _selectedCurrency,
                  currentWallet: currentWallet,
                  isDeposit: isDeposit,
                  onTap: _showCurrencyPicker,
                  colorScheme: colorScheme,
                  theme: theme,
                ),
              const SizedBox(height: 12),
              // Amount field
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [AmountInputFormatter()],
                decoration: CurrencyAmountInput.withCurrencySuffix(
                  context,
                  InputDecoration(
                    labelText: 'Số lượng',
                    hintText: '0.00',
                    prefixIcon: Icon(
                      isDeposit
                          ? Icons.add_circle_outline
                          : Icons.remove_circle_outline,
                      color: isDeposit ? Colors.green : Colors.red,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  currencySymbol: _selectedCurrency?.symbol ?? '',
                ),
                validator: (v) {
                  final raw = parseAmountInput(v ?? '');
                  if (raw.isEmpty) return 'Vui lòng nhập số lượng';
                  if (!RegExp(r'^\d+(\.\d{1,18})?$').hasMatch(raw)) {
                    return 'Số lượng không hợp lệ';
                  }
                  final num = double.tryParse(raw);
                  if (num == null || num <= 0) return 'Số lượng phải lớn hơn 0';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú (tuỳ chọn)',
                  hintText: 'Lý do điều chỉnh...',
                  prefixIcon: Icon(Icons.notes_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Consumer<AdminUsersProvider>(
                builder: (_, provider, __) => FilledButton.icon(
                  onPressed: (provider.isAdjusting || _selectedCurrency == null)
                      ? null
                      : _submit,
                  icon: provider.isAdjusting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(isDeposit
                          ? Icons.add_circle
                          : Icons.remove_circle),
                  label: Text(provider.isAdjusting
                      ? 'Đang xử lý...'
                      : (isDeposit ? 'Nạp coin' : 'Rút coin')),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: isDeposit ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Currency Picker Tile ──────────────────────────────────────────────────────

/// Tappable tile that shows the currently selected currency and its balance.
class _CurrencyPickerTile extends StatelessWidget {
  final Currency? selectedCurrency;
  final AdminUserWalletItem? currentWallet;
  final bool isDeposit;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _CurrencyPickerTile({
    required this.selectedCurrency,
    required this.currentWallet,
    required this.isDeposit,
    required this.onTap,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final hasBalance = currentWallet?.hasBalance == true;
    return InkWell(
      onTap: onTap,
      mouseCursor: SystemMouseCursors.click,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                selectedCurrency?.symbol.isNotEmpty == true
                    ? selectedCurrency!.symbol[0]
                    : '?',
                style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedCurrency != null
                        ? '${selectedCurrency!.symbol} — ${selectedCurrency!.name}'
                        : 'Chọn loại coin',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (currentWallet != null)
                    Text(
                      'Số dư khả dụng: ${FormatUtils.formatDecimalAmountDisplay(currentWallet!.available)} ${selectedCurrency?.symbol ?? ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: hasBalance
                              ? Colors.green
                              : colorScheme.onSurfaceVariant),
                    )
                  else if (selectedCurrency != null)
                    Text(
                      isDeposit
                          ? 'Người dùng chưa có ví — sẽ tự động tạo'
                          : 'Người dùng chưa có ví ${selectedCurrency!.symbol}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                ],
              ),
            ),
            Icon(Icons.swap_horiz, color: colorScheme.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Currency Picker Dialog ────────────────────────────────────────────────────

/// Search-and-select dialog for choosing which coin to deposit/withdraw.
/// Groups results into "existing wallets" (with balance) and "new wallets".
class _CurrencyPickerDialog extends StatefulWidget {
  final List<Currency> currencies;
  final List<AdminUserWalletItem> userWallets;
  final String? selectedCurrencyId;

  const _CurrencyPickerDialog({
    required this.currencies,
    required this.userWallets,
    this.selectedCurrencyId,
  });

  @override
  State<_CurrencyPickerDialog> createState() => _CurrencyPickerDialogState();
}

class _CurrencyPickerDialogState extends State<_CurrencyPickerDialog> {
  final _searchController = TextEditingController();
  List<Currency> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.currencies;
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase().trim();
    setState(() {
      _filtered = q.isEmpty
          ? widget.currencies
          : widget.currencies
              .where((c) =>
                  c.symbol.toLowerCase().contains(q) ||
                  c.name.toLowerCase().contains(q))
              .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final walletIds = widget.userWallets.map((w) => w.currencyId).toSet();
    final inWallet =
        _filtered.where((c) => walletIds.contains(c.currencyId)).toList();
    final notInWallet =
        _filtered.where((c) => !walletIds.contains(c.currencyId)).toList();

    return AlertDialog(
      title: const Text('Chọn loại coin'),
      contentPadding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
      content: SizedBox(
        width: 400,
        height: 420,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Tìm theo tên hoặc ký hiệu...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  if (inWallet.isNotEmpty) ...[
                    _SectionLabel(
                        label: 'VÍ HIỆN CÓ',
                        color: colorScheme.primary,
                        theme: theme),
                    ...inWallet.map((c) {
                      final wallet = widget.userWallets
                          .firstWhere((w) => w.currencyId == c.currencyId);
                      return _CurrencyListTile(
                        currency: c,
                        badge: FormatUtils.formatDecimalAmountDisplay(
                            wallet.available),
                        badgeColor: wallet.hasBalance ? Colors.green : null,
                        isSelected: c.currencyId == widget.selectedCurrencyId,
                        onTap: () => Navigator.pop(context, c),
                      );
                    }),
                    if (notInWallet.isNotEmpty) const Divider(height: 8),
                  ],
                  if (notInWallet.isNotEmpty) ...[
                    if (inWallet.isNotEmpty)
                      _SectionLabel(
                          label: 'TẠO VÍ MỚI',
                          color: colorScheme.onSurfaceVariant,
                          theme: theme),
                    ...notInWallet.map((c) => _CurrencyListTile(
                          currency: c,
                          badge: 'Chưa có ví',
                          badgeColor: null,
                          isSelected: c.currencyId == widget.selectedCurrencyId,
                          onTap: () => Navigator.pop(context, c),
                        )),
                  ],
                  if (_filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Không tìm thấy coin nào',
                          textAlign: TextAlign.center),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  final ThemeData theme;

  const _SectionLabel(
      {required this.label, required this.color, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(label,
          style: theme.textTheme.labelSmall
              ?.copyWith(color: color, letterSpacing: 0.8)),
    );
  }
}

class _CurrencyListTile extends StatelessWidget {
  final Currency currency;
  final String badge;
  final Color? badgeColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _CurrencyListTile({
    required this.currency,
    required this.badge,
    required this.badgeColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor:
            isSelected ? colorScheme.primary : colorScheme.primaryContainer,
        child: Text(
          currency.symbol.isNotEmpty ? currency.symbol[0] : '?',
          style: TextStyle(
            color: isSelected
                ? colorScheme.onPrimary
                : colorScheme.onPrimaryContainer,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text('${currency.symbol} — ${currency.name}'),
      subtitle: Text(badge,
          style: TextStyle(
              fontSize: 11,
              color: badgeColor ?? colorScheme.onSurfaceVariant)),
      trailing:
          isSelected ? Icon(Icons.check, color: colorScheme.primary) : null,
      onTap: onTap,
      mouseCursor: SystemMouseCursors.click,
      selected: isSelected,
      selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
    );
  }
}

// ── Shared Utility Widgets ────────────────────────────────────────────────────

class _PermissionDenied extends StatelessWidget {
  final String message;
  const _PermissionDenied({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline,
              size: 48, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}
