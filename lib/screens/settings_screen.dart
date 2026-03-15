import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/data/datasources/exchange_remote_datasource.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/auth_provider.dart';

/// App Settings screen (Sync Binance, etc.)
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _lastManualSyncAtKey = 'exchange_last_manual_sync_at';

  bool _isSyncing = false;
  DateTime? _lastManualSyncAt;

  @override
  void initState() {
    super.initState();
    _loadLastManualSyncTime();
  }

  Future<void> _loadLastManualSyncTime() async {
    final tokenService = sl<TokenService>();
    final value =
        tokenService.sharedPreferences.getString(_lastManualSyncAtKey);
    if (value == null || value.isEmpty) return;
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return;
    if (!mounted) return;
    setState(() => _lastManualSyncAt = parsed);
  }

  Future<void> _saveLastManualSyncTime(DateTime value) async {
    final tokenService = sl<TokenService>();
    await tokenService.sharedPreferences
        .setString(_lastManualSyncAtKey, value.toIso8601String());
    if (!mounted) return;
    setState(() => _lastManualSyncAt = value);
  }

  String _formatDateTime(BuildContext context, DateTime value) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.yMd(locale).add_Hm().format(value.toLocal());
  }

  Future<void> _syncBinance() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);

    final l10n = AppLocalizations.of(context);
    try {
      final datasource = sl<ExchangeRemoteDataSource>();
      await datasource.syncInfo();
      await _saveLastManualSyncTime(DateTime.now());
      if (!mounted) return;
      showAppSnackBar(
        context,
        message: l10n.syncSuccess,
        type: SnackBarType.success,
        duration: const Duration(seconds: 3),
      );
    } on AuthenticationException {
      if (!mounted) return;
      showAppSnackBar(
        context,
        message: '${l10n.syncFailed}: Unauthorized. Please log in again.',
        type: SnackBarType.error,
        duration: const Duration(seconds: 3),
      );
    } on NetworkException catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        message: '${l10n.syncFailed}: ${e.message}',
        type: SnackBarType.error,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        message: '${l10n.syncFailed}: ${e.toString()}',
        type: SnackBarType.error,
        duration: const Duration(seconds: 3),
      );
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (!auth.canSyncExchange) {
              return const SizedBox.shrink();
            }

            return Column(
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
                                    l10n.manualResyncBinance,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.manualResyncBinanceDescription,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _lastManualSyncAt == null
                              ? '${l10n.lastManualSync}: ${l10n.neverSyncedYet}'
                              : '${l10n.lastManualSync}: ${_formatDateTime(context, _lastManualSyncAt!)}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  )
                                : const Icon(Icons.sync),
                            label: Text(_isSyncing
                                ? l10n.syncing
                                : l10n.manualResyncBinance),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
