import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/app/di/injection_container.dart' as di;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Binance API Keys'),
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
                    'No Binance API Keys',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connect your Binance account to start trading',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => _navigateToSetup(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add API Key'),
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
                  onTap: () => _navigateToTrading(context, cred),
                  onDelete: () => _confirmDelete(context, provider, cred),
                  onTest: () => _testConnection(context, provider, cred),
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
  ) async {
    final result = await provider.testConnection(cred.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.success
              ? 'Connection OK — Account: ${result.error ?? "verified"}'
              : 'Connection failed: ${result.error}',
        ),
        backgroundColor: result.success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    BinanceCredentialsProvider provider,
    BinanceCredentials cred,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete API Key?'),
        content: Text(
          'Are you sure you want to delete "${cred.label ?? "API Key"}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
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
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onTest;

  const _CredentialCard({
    required this.credential,
    required this.onTap,
    required this.onDelete,
    required this.onTest,
  });

  @override
  Widget build(BuildContext context) {
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
                          credential.label ?? 'Binance Account',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            _buildChip(
                              credential.testnet ? 'TESTNET' : 'MAINNET',
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
                      const PopupMenuItem(value: 'test', child: Text('Test Connection')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete', style: TextStyle(color: Colors.red)),
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
                      'Last used: ${_formatDate(credential.lastUsedAt!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ] else
                    Text(
                      'Never used',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.trending_up, size: 16),
                    label: const Text('Trade'),
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
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
