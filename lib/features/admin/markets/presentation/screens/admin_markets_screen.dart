import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:crypto_trading_app/app/di/injection_container.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart'
    show AuthenticationException, NetworkException, ServerException;
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/features/markets/domain/entities/exchange_sync_result.dart';
import 'package:crypto_trading_app/features/markets/domain/repositories/exchange_repository.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/features/markets/presentation/providers/currencies_provider.dart';
import 'package:crypto_trading_app/features/markets/presentation/providers/markets_provider.dart';

/// Admin-focused screen: Binance catalog sync + last [ExchangeSyncResult] on screen.
///
/// [exchangeRepository] is optional (tests); production uses [sl] when null.
class AdminMarketsScreen extends StatefulWidget {
  final ExchangeRepository? exchangeRepository;

  const AdminMarketsScreen({super.key, this.exchangeRepository});

  @override
  State<AdminMarketsScreen> createState() => _AdminMarketsScreenState();
}

class _AdminMarketsScreenState extends State<AdminMarketsScreen> {
  static final Uri _binanceLimitsUri = Uri.parse(
    'https://developers.binance.com/docs/binance-spot-api-docs/rest-api#limits',
  );

  bool _isSyncing = false;
  bool _forceRefresh = false;
  ExchangeSyncResult? _lastResult;

  ExchangeRepository get _exchange =>
      widget.exchangeRepository ?? sl<ExchangeRepository>();

  Future<void> _openBinanceLimitsDoc() async {
    if (!await launchUrl(_binanceLimitsUri,
        mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        message: 'Could not open link',
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _sync() async {
    if (_isSyncing) return;
    final l10n = AppLocalizations.of(context);
    final marketsProvider = context.read<MarketsProvider>();
    final currenciesProvider = context.read<CurrenciesProvider>();
    setState(() => _isSyncing = true);

    try {
      final result = await _exchange.syncInfo(forceRefresh: _forceRefresh);
      if (!mounted) return;

      await marketsProvider.fetchMarkets(
        refresh: true,
        includeTickers: true,
      );
      await currenciesProvider.fetchCurrencies(refresh: true);
      await currenciesProvider.fetchTradableCurrencies();

      if (!mounted) return;

      setState(() => _lastResult = result);

      showAppSnackBar(
        context,
        message: l10n.exchangeSyncResultSummary(
          result.pairsCreated,
          result.pairsSkipped,
          result.currenciesCreated,
          result.currenciesSkipped,
        ),
        type: SnackBarType.success,
        duration: const Duration(seconds: 5),
      );

      if (result.hasErrors && mounted) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.exchangeSyncWarningsTitle),
            content: SingleChildScrollView(
              child: SelectableText(
                result.errors.take(20).join('\n'),
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.exchangeSyncClose),
              ),
            ],
          ),
        );
      }
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
    } on ServerException catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        message: '${l10n.syncFailed}: ${e.message}',
        type: SnackBarType.error,
        duration: const Duration(seconds: 5),
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
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminMarketsScreenTitle),
      ),
      body: !auth.canSyncExchange
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.noPermissionMessage,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.adminMarketsIntro,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.exchangeSyncForceRefresh),
                    value: _forceRefresh,
                    onChanged: _isSyncing
                        ? null
                        : (v) => setState(() => _forceRefresh = v),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _isSyncing ? null : _sync,
                    icon: _isSyncing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync),
                    label: Text(
                      _isSyncing ? l10n.syncing : l10n.manualResyncBinance,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: _openBinanceLimitsDoc,
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: Text(l10n.adminMarketsBinanceLimitsLink),
                  ),
                  if (_lastResult != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      l10n.adminMarketsLastResult,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SelectableText(
                          l10n.exchangeSyncResultSummary(
                            _lastResult!.pairsCreated,
                            _lastResult!.pairsSkipped,
                            _lastResult!.currenciesCreated,
                            _lastResult!.currenciesSkipped,
                          ),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    if (_lastResult!.hasErrors) ...[
                      const SizedBox(height: 12),
                      Text(
                        l10n.exchangeSyncWarningsTitle,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(color: theme.colorScheme.error),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        _lastResult!.errors.take(12).join('\n'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
    );
  }
}
