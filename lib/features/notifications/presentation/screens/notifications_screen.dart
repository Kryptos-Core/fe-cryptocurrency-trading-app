import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:crypto_trading_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:crypto_trading_app/features/notifications/presentation/providers/notification_provider.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/services/notification_sound_service.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/app/router/app_routes.dart';

/// Notification history screen.
/// Lists all user notifications; unread items have a tinted background.
/// Tapping a tile marks it as read and shows a detail bottom sheet.
/// AppBar action: "Mark all as read".
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadMore(page: 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        actions: [
          Consumer<NotificationProvider>(
            builder: (_, prov, __) {
              if (prov.unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: prov.markAllRead,
                child: Text(l10n.notificationsMarkAllRead),
              );
            },
          ),
          IconButton(
            tooltip: l10n.notificationSoundSettings,
            icon: Icon(
              NotificationSoundService.instance.globallyEnabled
                  ? Icons.volume_up
                  : Icons.volume_off,
            ),
            onPressed: () => _showSoundSettingsSheet(context),
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, prov, _) {
          if (prov.isLoading && prov.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (prov.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(l10n.notificationsEmpty, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => prov.loadMore(page: 1),
            child: ListView.separated(
              itemCount: prov.notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notif = prov.notifications[index];
                return _NotificationTile(
                  notification: notif,
                  onTap: () => _onTileTap(context, prov, notif),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _onTileTap(
    BuildContext context,
    NotificationProvider prov,
    NotificationEntity notif,
  ) {
    if (!notif.isRead) {
      prov.markRead(notif.notificationId);
    }

    // Navigate to withdrawal management screen if withdrawal notification
    if (notif.type == NotificationType.withdrawalRequest ||
        notif.type == NotificationType.withdrawalApproved ||
        notif.type == NotificationType.withdrawalRejected) {
      context.push(AppRoutes.adminWithdrawals);
      return;
    }

    _showDetailSheet(context, notif);
  }

  void _showDetailSheet(BuildContext context, NotificationEntity notif) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _NotificationDetailSheet(notification: notif),
    );
  }

  void _showSoundSettingsSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final soundService = NotificationSoundService.instance;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                const Icon(Icons.volume_up),
                const SizedBox(width: 12),
                Text(l10n.notificationSoundSettings,
                    style: Theme.of(ctx).textTheme.titleMedium),
                const Spacer(),
                Switch(
                  value: soundService.globallyEnabled,
                  onChanged: (v) async {
                    await soundService.setGloballyEnabled(v);
                    setSheetState(() {});
                  },
                ),
              ],
            ),
            const Divider(),
            Text(l10n.notificationSoundPerType,
                style: Theme.of(ctx).textTheme.titleSmall),
            const SizedBox(height: 12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: NotificationSoundType.values.map((st) {
                  final setting = soundService.settings[st]!;
                  return SwitchListTile(
                    secondary: IconButton(
                      icon: const Icon(Icons.play_arrow, size: 20),
                      tooltip: 'Preview',
                      onPressed: () =>
                          soundService.playForSoundType(st),
                    ),
                    title: Text(_soundTypeLabel(st, l10n)),
                    subtitle: Text(_soundTypeAsset(st)),
                    value: setting.enabled,
                    dense: true,
                    onChanged: soundService.globallyEnabled
                        ? (v) async {
                            await soundService.setEnabled(st, v);
                            setSheetState(() {});
                          }
                        : null,
                  );
                }).toList(),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  String _soundTypeLabel(NotificationSoundType st, AppLocalizations l10n) {
    return switch (st) {
      NotificationSoundType.systemDefault => l10n.notificationSoundSystemDefault,
      NotificationSoundType.withdrawalRequest => l10n.notificationSoundWithdrawalRequest,
      NotificationSoundType.withdrawalApproved => l10n.notificationSoundWithdrawalApproved,
      NotificationSoundType.withdrawalRejected => l10n.notificationSoundWithdrawalRejected,
      NotificationSoundType.alert => l10n.notificationSoundAlert,
      NotificationSoundType.promo => l10n.notificationSoundPromo,
    };
  }

  String _soundTypeAsset(NotificationSoundType st) =>
      st.assetPath.split('/').last.replaceAll(RegExp(r'\.(mp3|wav|aiff)$'), '');
}

// ── Notification Tile ──────────────────────────────────────────────────────

String _buildLocalizedBody(NotificationEntity notif, AppLocalizations l10n) {
  final data = notif.data;
  if (data == null) return notif.body;

  final i18nKey = data['i18nKey'] as String?;
  if (i18nKey == null) return notif.body;

  final rawAmount = data['amount'] as String?;
  final symbol = (data['assetSymbol'] as String?) ?? (data['asset'] as String?) ?? '';
  final chain = (data['chain'] as String?) ?? '';

  final formattedAmount = rawAmount != null && rawAmount.isNotEmpty
      ? FormatUtils.formatDecimalAmountDisplay(rawAmount)
      : '';

  switch (i18nKey) {
    case 'notifWithdrawalRequest':
      return l10n.notifWithdrawalRequest(formattedAmount, symbol, chain);
    case 'notifWithdrawalApproved':
      return l10n.notifWithdrawalApproved(formattedAmount, symbol, chain);
    case 'notifWithdrawalRejected': {
      final reason = data['reason'] as String?;
      return l10n.notifWithdrawalRejected(
        formattedAmount,
        symbol,
        chain,
        reason ?? 'undefined',
      );
    }
    default:
      return notif.body;
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bgColor = notification.isRead
        ? Colors.transparent
        : colorScheme.primaryContainer.withValues(alpha: 0.15);

    final leading = _typeIcon(notification.type, colorScheme);
    final timeStr = _formatTime(notification.notificationCreatedAt, l10n);

    return ListTile(
      tileColor: bgColor,
      leading: CircleAvatar(
        backgroundColor: leading.$2.withValues(alpha: 0.15),
        child: Icon(leading.$1, color: leading.$2, size: 20),
      ),
      title: Text(
        notification.title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _buildLocalizedBody(notification, l10n),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(timeStr, style: theme.textTheme.labelSmall),
          if (!notification.isRead) ...[
            const SizedBox(height: 4),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
      mouseCursor: SystemMouseCursors.click,
      onTap: onTap,
    );
  }

  (IconData, Color) _typeIcon(NotificationType type, ColorScheme cs) {
    switch (type) {
      case NotificationType.alert:
        return (Icons.warning_amber_outlined, Colors.orange);
      case NotificationType.promo:
        return (Icons.local_offer_outlined, Colors.green);
      case NotificationType.withdrawalRequest:
        return (Icons.output_outlined, Colors.blue);
      case NotificationType.withdrawalApproved:
        return (Icons.check_circle_outline, Colors.green);
      case NotificationType.withdrawalRejected:
        return (Icons.cancel_outlined, Colors.red);
      case NotificationType.system:
        return (Icons.info_outline, cs.primary);
    }
  }

  String _formatTime(DateTime dt, AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return l10n.notificationsJustNow;
    if (diff.inHours < 1) return l10n.notificationsMinAgo(diff.inMinutes);
    if (diff.inDays < 1) return l10n.notificationsHourAgo(diff.inHours);
    if (diff.inDays < 7) return l10n.notificationsDayAgo(diff.inDays);
    return DateFormat('MMM d').format(dt);
  }
}

// ── Detail Bottom Sheet ────────────────────────────────────────────────────

class _NotificationDetailSheet extends StatelessWidget {
  final NotificationEntity notification;

  const _NotificationDetailSheet({required this.notification});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final dateStr = DateFormat('MMM d, yyyy – HH:mm').format(notification.notificationCreatedAt);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _typeBadge(notification.type, theme, l10n),
                const Spacer(),
                Text(dateStr, style: theme.textTheme.labelSmall),
              ],
            ),
            const SizedBox(height: 12),
            Text(notification.title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_buildLocalizedBody(notification, l10n), style: theme.textTheme.bodyMedium),
            if (notification.data != null && notification.data!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(l10n.notificationsDetails, style: theme.textTheme.labelMedium),
              const SizedBox(height: 4),
              ...notification.data!.entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text('${e.key}: ',
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                      Expanded(child: Text(e.value.toString(), style: theme.textTheme.bodySmall)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _typeBadge(NotificationType type, ThemeData theme, AppLocalizations l10n) {
    final (label, color) = switch (type) {
      NotificationType.alert => (l10n.notificationsTypeAlert, Colors.orange),
      NotificationType.promo => (l10n.notificationsTypePromo, Colors.green),
      NotificationType.withdrawalRequest =>
        (l10n.notificationsTypeWithdrawalRequest, Colors.blue),
      NotificationType.withdrawalApproved =>
        (l10n.notificationsTypeWithdrawalApproved, Colors.green),
      NotificationType.withdrawalRejected =>
        (l10n.notificationsTypeWithdrawalRejected, Colors.red),
      NotificationType.system => (l10n.notificationsTypeSystem, theme.colorScheme.primary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
