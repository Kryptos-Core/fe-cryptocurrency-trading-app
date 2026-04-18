import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/features/notifications/domain/repositories/notification_repository.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';

/// Admin-only screen to broadcast a system notification to all users.
/// Accessible from the Drawer → Admin section.
class BroadcastNotificationScreen extends StatefulWidget {
  const BroadcastNotificationScreen({super.key});

  @override
  State<BroadcastNotificationScreen> createState() =>
      _BroadcastNotificationScreenState();
}

class _BroadcastNotificationScreenState
    extends State<BroadcastNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  String _selectedType = 'system';
  bool _isSending = false;

  static const _types = [
    ('system', Icons.info_outline),
    ('alert', Icons.warning_amber_outlined),
    ('promo', Icons.local_offer_outlined),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {
      final repo = context.read<NotificationRepository>();
      final result = await repo.broadcastNotification(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        type: _selectedType,
      );

      if (!mounted) return;

      result.fold(
        (f) {
          _showToast(context, f.message, isError: true);
        },
        (_) {
          _formKey.currentState!.reset();
          _titleController.clear();
          _bodyController.clear();
          setState(() => _selectedType = 'system');
          if (!mounted) return;
          _showToast(
            context,
            AppLocalizations.of(context).broadcastSuccess,
            isError: false,
          );
        },
      );
    } catch (_) {
      if (!mounted) return;
      _showToast(
        context,
        AppLocalizations.of(context).broadcastFailedTryAgain,
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showToast(BuildContext context, String message, {required bool isError}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Flexible(child: Text(message)),
            ],
          ),
          backgroundColor: isError ? Colors.redAccent : Colors.green,
          behavior: SnackBarBehavior.floating,
          // Constrain width and anchor to bottom-right
          margin: const EdgeInsets.only(bottom: 16, left: 240, right: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.broadcastNotificationTitle),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Info banner ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.campaign_outlined,
                        color: colorScheme.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.broadcastInfoBanner,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: colorScheme.onPrimaryContainer),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Type selector ────────────────────────────────────────
              Text(l10n.broadcastTypeLabel, style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Row(
                children: _types.map((t) {
                  final (value, icon) = t;
                  final selected = _selectedType == value;
                  final label = _typeLabel(value, l10n);
                  final color = switch (value) {
                    'alert' => Colors.orange,
                    'promo' => Colors.green,
                    _ => colorScheme.primary,
                  };
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        mouseCursor: SystemMouseCursors.click,
                        onTap: () => setState(() => _selectedType = value),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selected
                              ? color.withValues(alpha: 0.15)
                                : colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected ? color : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icon,
                                  color: selected ? color : colorScheme.outline,
                                  size: 20),
                              const SizedBox(height: 4),
                              Text(
                                label,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color:
                                      selected ? color : colorScheme.outline,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // ── Title ────────────────────────────────────────────────
              Text(l10n.broadcastTitleLabel, style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                maxLength: 255,
                decoration: InputDecoration(
                  hintText: l10n.broadcastTitleHint,
                  border: const OutlineInputBorder(),
                  counterText: '',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return l10n.broadcastTitleRequired;
                  }
                  if (v.trim().length < 3) return l10n.broadcastTitleTooShort;
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // ── Body ─────────────────────────────────────────────────
              Text(l10n.broadcastMessageLabel, style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bodyController,
                maxLines: 5,
                maxLength: 1000,
                decoration: InputDecoration(
                  hintText: l10n.broadcastMessageHint,
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return l10n.broadcastMessageRequired;
                  }
                  if (v.trim().length < 5) return l10n.broadcastMessageTooShort;
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // ── Send button ──────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSending ? null : _send,
                  icon: _isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_outlined),
                  label: Text(
                    _isSending
                        ? l10n.broadcastSending
                        : l10n.broadcastSendAllUsers,
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _typeLabel(String value, AppLocalizations l10n) {
    switch (value) {
      case 'alert':
        return l10n.broadcastTypeAlert;
      case 'promo':
        return l10n.broadcastTypePromo;
      default:
        return l10n.broadcastTypeSystem;
    }
  }
}
