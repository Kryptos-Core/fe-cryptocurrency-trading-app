import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/app/di/injection_container.dart' as di;
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import '../../application/providers/binance_credentials_provider.dart';
import '../../application/providers/binance_trading_provider.dart';
import '../../data/repositories/binance_trading_repository_impl.dart';
import '../../domain/entities/binance_credentials.dart';
import 'api_key_setup_screen.dart';
import 'spot_trading_screen.dart';

class ApiKeyListScreen extends StatefulWidget {
  const ApiKeyListScreen({super.key});

  @override
  State<ApiKeyListScreen> createState() => _ApiKeyListScreenState();
}

class _ApiKeyListScreenState extends State<ApiKeyListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BinanceCredentialsProvider>().loadCredentials();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.binanceApiKeyListTitle),
        elevation: 0,
      ),
      body: Consumer<BinanceCredentialsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.credentials.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.key_off_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.binanceApiKeyListEmptyTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.binanceApiKeyListEmptyDescription,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => _navigateToSetup(context),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.binanceApiKeyListAddAction),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadCredentials,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.credentials.length,
              itemBuilder: (context, index) {
                final cred = provider.credentials[index];
                return _CredentialCard(
                  credential: cred,
                  l10n: l10n,
                  onTap: () => _navigateToTrading(context, cred),
                  onDelete: () => _confirmDelete(context, provider, cred, l10n),
                  onTest: () => _testConnection(context, provider, cred, l10n),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToSetup(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToSetup(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ApiKeySetupScreen()),
    );
  }

  void _navigateToTrading(BuildContext context, BinanceCredentials cred) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider<BinanceCredentialsProvider>.value(
              value: context.read<BinanceCredentialsProvider>(),
            ),
            ChangeNotifierProvider<BinanceTradingProvider>(
              create: (_) => BinanceTradingProvider(
                repository: di.sl<BinanceTradingRepositoryImpl>(),
              ),
            ),
          ],
          child: SpotTradingScreen(
            credentialId: cred.id,
            label: cred.label,
          ),
        ),
      ),
    );
  }

  Future<void> _testConnection(
    BuildContext context,
    BinanceCredentialsProvider provider,
    BinanceCredentials cred,
    AppLocalizations l10n,
  ) async {
    final result = await provider.testConnection(cred.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.success
              ? l10n.binanceApiKeyListConnectionOk(result.error ?? 'verified')
              : l10n.binanceApiKeyListConnectionFailed(result.error ?? ''),
        ),
        backgroundColor: result.success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    BinanceCredentialsProvider provider,
    BinanceCredentials cred,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.binanceApiKeyListDeleteConfirmTitle),
        content: Text(
          l10n.binanceApiKeyListDeleteConfirmContent(cred.label ?? 'API Key'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.binanceApiKeyListDelete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.deleteCredential(cred.id);
    }
  }
}

class _CredentialCard extends StatelessWidget {
  final BinanceCredentials credential;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onTest;

  const _CredentialCard({
    required this.credential,
    required this.l10n,
    required this.onTap,
    required this.onDelete,
    required this.onTest,
  });

  @override
  Widget build(BuildContext context) {
    final localizedLabel =
        credential.label ?? l10n.binanceApiKeyListAccountFallbackLabel;
    final testnetBadge = l10n.binanceApiKeyListTestnetBadge;
    final mainnetBadge = l10n.binanceApiKeyListMainnetBadge;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.vpn_key,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizedLabel,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            _buildChip(
                              credential.testnet ? testnetBadge : mainnetBadge,
                              credential.testnet ? Colors.orange : Colors.green,
                            ),
                            const SizedBox(width: 6),
                            ...credential.permissions.map((p) => Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: _buildChip(
                                p.name.toUpperCase(),
                                Theme.of(context).colorScheme.primary,
                              ),
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'test') onTest();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                          value: 'test',
                          child: Text(l10n.binanceApiKeyListTestConnection)),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(l10n.binanceApiKeyListDelete,
                            style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (credential.lastUsedAt != null) ...[
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.binanceApiKeyListLastUsedAt(
                          _formatDate(credential.lastUsedAt!)),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ] else
                    Text(
                      l10n.binanceApiKeyListNeverUsed,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.trending_up, size: 16),
                    label: Text(l10n.binanceApiKeyListTrade),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    final l10n = this.l10n;
    if (diff.inMinutes < 1) return l10n.binanceApiKeyListJustNow;
    if (diff.inMinutes < 60) return l10n.binanceApiKeyListMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.binanceApiKeyListHoursAgo(diff.inHours);
    if (diff.inDays < 7) return l10n.binanceApiKeyListDaysAgo(diff.inDays);
    return '${date.day}/${date.month}/${date.year}';
  }
}
