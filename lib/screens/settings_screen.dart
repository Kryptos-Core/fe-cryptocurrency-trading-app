import 'package:flutter/material.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/services/toast_service.dart';
import 'package:crypto_trading_app/data/datasources/exchange_remote_datasource.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';

/// App Settings screen (Sync Binance, etc.)
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isSyncing = false;

  Future<void> _syncBinance() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);

    final l10n = AppLocalizations.of(context)!;
    try {
      final datasource = sl<ExchangeRemoteDataSource>();
      await datasource.syncInfo();
      if (!mounted) return;
      ToastService().show(
        context,
        message: l10n.syncSuccess,
        type: ToastType.success,
        duration: const Duration(seconds: 3),
      );
    } on AuthenticationException {
      if (!mounted) return;
      ToastService().show(
        context,
        message: '${l10n.syncFailed}: Unauthorized. Please log in again.',
        type: ToastType.error,
        duration: const Duration(seconds: 3),
      );
    } on NetworkException catch (e) {
      if (!mounted) return;
      ToastService().show(
        context,
        message: '${l10n.syncFailed}: ${e.message}',
        type: ToastType.error,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      if (!mounted) return;
      ToastService().show(
        context,
        message: '${l10n.syncFailed}: ${e.toString()}',
        type: ToastType.error,
        duration: const Duration(seconds: 3),
      );
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.sync,
                          size: 28,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.syncBinance,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.syncBinanceDescription,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isSyncing ? null : _syncBinance,
                        icon: _isSyncing
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              )
                            : const Icon(Icons.sync),
                        label: Text(_isSyncing ? l10n.syncing : l10n.syncBinance),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
