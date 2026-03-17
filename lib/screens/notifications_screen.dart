import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:crypto_trading_app/domain/entities/notification_entity.dart';
import 'package:crypto_trading_app/presentation/providers/notification_provider.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (_, prov, __) {
              if (prov.unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: prov.markAllRead,
                child: const Text('Mark all read'),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, prov, _) {
          if (prov.isLoading && prov.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (prov.notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No notifications yet', style: TextStyle(color: Colors.grey)),
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
}

// ── Notification Tile ──────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bgColor = notification.isRead
        ? Colors.transparent
        : colorScheme.primaryContainer.withOpacity(0.15);

    final leading = _typeIcon(notification.type, colorScheme);
    final timeStr = _formatTime(notification.notificationCreatedAt);

    return ListTile(
      tileColor: bgColor,
      leading: CircleAvatar(
        backgroundColor: leading.$2.withOpacity(0.15),
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
        notification.body,
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
      onTap: onTap,
    );
  }

  (IconData, Color) _typeIcon(NotificationType type, ColorScheme cs) {
    switch (type) {
      case NotificationType.alert:
        return (Icons.warning_amber_outlined, Colors.orange);
      case NotificationType.promo:
        return (Icons.local_offer_outlined, Colors.green);
      case NotificationType.system:
        return (Icons.info_outline, cs.primary);
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dt);
  }
}

// ── Detail Bottom Sheet ────────────────────────────────────────────────────

class _NotificationDetailSheet extends StatelessWidget {
  final NotificationEntity notification;

  const _NotificationDetailSheet({required this.notification});

  @override
  Widget build(BuildContext context) {
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
                _typeBadge(notification.type, theme),
                const Spacer(),
                Text(dateStr, style: theme.textTheme.labelSmall),
              ],
            ),
            const SizedBox(height: 12),
            Text(notification.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(notification.body, style: theme.textTheme.bodyMedium),
            if (notification.data != null && notification.data!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text('Details', style: theme.textTheme.labelMedium),
              const SizedBox(height: 4),
              ...notification.data!.entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text('${e.key}: ', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
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

  Widget _typeBadge(NotificationType type, ThemeData theme) {
    final (label, color) = switch (type) {
      NotificationType.alert => ('Alert', Colors.orange),
      NotificationType.promo => ('Promo', Colors.green),
      NotificationType.system => ('System', theme.colorScheme.primary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
