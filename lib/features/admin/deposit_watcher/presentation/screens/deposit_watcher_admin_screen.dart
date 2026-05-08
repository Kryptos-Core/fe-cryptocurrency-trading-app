import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/admin/deposit_watcher/presentation/providers/deposit_watcher_provider.dart';

class DepositWatcherAdminScreen extends StatefulWidget {
  const DepositWatcherAdminScreen({super.key});

  @override
  State<DepositWatcherAdminScreen> createState() => _DepositWatcherAdminScreenState();
}

class _DepositWatcherAdminScreenState extends State<DepositWatcherAdminScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DepositWatcherProvider>().loadCursors();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.depositWatcherTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DepositWatcherProvider>().loadCursors(),
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: Consumer<DepositWatcherProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.cursors.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.cursors.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  FilledButton.tonalIcon(
                    onPressed: provider.loadCursors,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          final cursors = provider.cursors;

          if (cursors.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 64, color: theme.colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      l10n.depositWatcherNoCursorsFound,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.depositWatcherNoCursorsDesc,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.depositWatcherHowItWorks,
                              style: theme.textTheme.labelLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(l10n.depositWatcherStep1),
                            Text(l10n.depositWatcherStep2),
                            Text(l10n.depositWatcherStep3),
                            Text(l10n.depositWatcherStep4),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.tonalIcon(
                      onPressed: provider.loadCursors,
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.refresh),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadCursors,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cursors.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Text(
                          l10n.depositWatcherCursorsCount(cursors.length),
                          style: theme.textTheme.titleMedium,
                        ),
                        const Spacer(),
                        OutlinedButton.icon(
                          onPressed: provider.isLoading
                              ? null
                              : () => _confirmResetAll(context, provider),
                          icon: const Icon(Icons.restart_alt, size: 18),
                          label: Text(l10n.depositWatcherResetAll),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final cursor = cursors[index - 1];
                final dt = cursor.cursorAsDateTime;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(cursor.chain),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kind: ${cursor.cursorKind}'),
                        Text(
                          'Value: ${cursor.cursorValue}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                        if (dt != null)
                          Text(
                            'Last scan: ${dt.toLocal()}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Reset cursor',
                      onPressed: provider.isLoading
                          ? null
                          : () => _confirmResetOne(context, provider, cursor.chain),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmResetOne(
    BuildContext context,
    DepositWatcherProvider provider,
    String chain,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.depositWatcherResetAll),
        content: Text('Reset cursor for "$chain"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.depositWatcherResetAll),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final success = await provider.resetCursor(chain);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? l10n.depositWatcherResetSuccess(chain)
            : l10n.depositWatcherResetAllFailed),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _confirmResetAll(
    BuildContext context,
    DepositWatcherProvider provider,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.depositWatcherResetAll),
        content: Text(l10n.depositWatcherResetAllConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.depositWatcherResetAll),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final success = await provider.resetAllCursors();
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? l10n.depositWatcherResetAllSuccess
            : l10n.depositWatcherResetAllFailed),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}
