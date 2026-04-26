import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/admin/payment_config/data/models/treasury_e2e_config_model.dart';
import 'package:crypto_trading_app/features/admin/payment_config/presentation/providers/treasury_e2e_config_provider.dart';

class TreasuryE2EConfigTabView extends StatelessWidget {
  const TreasuryE2EConfigTabView({
    super.key,
    required this.onCreate,
    required this.onEdit,
    required this.onActivate,
    required this.onDeactivate,
    required this.onArchive,
  });

  final VoidCallback onCreate;
  final void Function(TreasuryE2EConfigModel config) onEdit;
  final void Function(TreasuryE2EConfigModel config) onActivate;
  final void Function(TreasuryE2EConfigModel config) onDeactivate;
  final void Function(TreasuryE2EConfigModel config) onArchive;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<TreasuryE2EConfigProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.configs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.error != null && provider.configs.isEmpty) {
          return Center(child: Text(provider.error!));
        }
        return RefreshIndicator(
          onRefresh: () => provider.loadConfigs(force: true),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.treasuryE2eTabTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: onCreate,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.treasuryE2eAddAction),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...provider.configs.map(
                (config) => Card(
                  child: ListTile(
                    title: Text(config.displayName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('${config.environment} • ${config.chain}'),
                        Text(config.apiBaseUrl),
                        Text(
                          l10n.treasuryE2eListSummary(
                            config.allowSkip ? 'true' : 'false',
                            config.healthFailOnCritical ? 'true' : 'false',
                            config.linkedWalletId ?? '-',
                          ),
                        ),
                        if (config.traderBearerTokenMasked != null || config.riskBearerTokenMasked != null)
                          Text(
                            l10n.treasuryE2eListTokens(
                              config.traderBearerTokenMasked ?? '-',
                              config.riskBearerTokenMasked ?? '-',
                            ),
                          ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit(config);
                            break;
                          case 'activate':
                            onActivate(config);
                            break;
                          case 'deactivate':
                            onDeactivate(config);
                            break;
                          case 'archive':
                            onArchive(config);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'edit', child: Text(l10n.treasuryE2eEditAction)),
                        if (!config.isActive)
                          PopupMenuItem(value: 'activate', child: Text(l10n.treasuryE2eActivateAction)),
                        if (config.isActive)
                          PopupMenuItem(value: 'deactivate', child: Text(l10n.treasuryE2eDeactivateAction)),
                        if (!config.isArchived)
                          PopupMenuItem(value: 'archive', child: Text(l10n.treasuryE2eArchiveAction)),
                      ],
                    ),
                    leading: _StatusChip(status: config.status),
                  ),
                ),
              ),
              if (provider.configs.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(child: Text(l10n.treasuryE2eEmptyState)),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'ACTIVE':
        color = Colors.green;
        break;
      case 'ARCHIVED':
        color = Colors.grey;
        break;
      default:
        color = Colors.orange;
    }
    return Chip(
      label: Text(status),
      backgroundColor: color.withValues(alpha: 0.12),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
    );
  }
}
