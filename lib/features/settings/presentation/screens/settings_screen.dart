import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/app/di/injection_container.dart';
import 'package:crypto_trading_app/core/localization/locale_provider.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart'
    show AuthenticationException, NetworkException, ServerException;
import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/features/markets/domain/repositories/exchange_repository.dart';
import 'package:crypto_trading_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/theme/theme_provider.dart';
import 'package:crypto_trading_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/features/markets/presentation/providers/currencies_provider.dart';
import 'package:crypto_trading_app/features/markets/presentation/providers/markets_provider.dart';
import 'package:crypto_trading_app/features/auth/presentation/widgets/otp_verification_dialog.dart';
import 'package:crypto_trading_app/features/home/presentation/screens/about_screen.dart';

/// App Settings screen (Sync Binance, etc.)
class SettingsScreen extends StatefulWidget {
  /// When true (e.g. opened from admin drawer), scrolls to the Binance sync card.
  final bool focusExchangeSync;

  const SettingsScreen({super.key, this.focusExchangeSync = false});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _lastManualSyncAtKey = 'exchange_last_manual_sync_at';

  final GlobalKey _exchangeSyncSectionKey = GlobalKey();

  bool _isSyncing = false;
  bool _isUpdating2fa = false;
  bool _forceRefreshExchange = false;
  DateTime? _lastManualSyncAt;

  @override
  void initState() {
    super.initState();
    _loadLastManualSyncTime();
    if (widget.focusExchangeSync) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future<void>.delayed(const Duration(milliseconds: 150), () {
          if (!mounted) return;
          final ctx = _exchangeSyncSectionKey.currentContext;
          if (ctx != null) {
            Scrollable.ensureVisible(
              ctx,
              alignment: 0.12,
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeInOut,
            );
          }
        });
      });
    }
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
      final exchangeRepository = sl<ExchangeRepository>();
      final result = await exchangeRepository.syncInfo(forceRefresh: _forceRefreshExchange);
      await _saveLastManualSyncTime(DateTime.now());
      if (!mounted) return;

      await context.read<MarketsProvider>().fetchMarkets(
            refresh: true,
            includeTickers: true,
          );
      await context.read<CurrenciesProvider>().fetchCurrencies(refresh: true);
      await context.read<CurrenciesProvider>().fetchTradableCurrencies();

      if (!mounted) return;

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

  Future<String?> _askOtp(BuildContext context, AuthRepository repo, String token) async {
    return OtpVerificationDialog.show(context, repo: repo, token: token);
  }

  Future<void> _toggle2fa(bool enable) async {
    if (_isUpdating2fa) return;
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;
    if (!auth.hasRealEmailForOtp) {
      showAppSnackBar(
        context,
        message: AppLocalizations.of(context).contactEmailRequiredForOtpShort,
        type: SnackBarType.error,
      );
      return;
    }
    final token = sl<TokenService>().getAccessToken();
    if (token == null || token.isEmpty) return;

    setState(() => _isUpdating2fa = true);
    try {
      final repo = sl<AuthRepository>();
      final sendOtp = await repo.send2faOtp(token);
      final otpSent = sendOtp.fold((_) => false, (_) => true);
      if (!otpSent) {
        sendOtp.fold((f) {
          showAppSnackBar(
            context,
            message: f.message,
            type: SnackBarType.error,
          );
        }, (_) {});
        return;
      }

      if (!mounted) return;
      showAppSnackBar(
        context,
        message: AppLocalizations.of(context).otpSentToEmail,
        type: SnackBarType.success,
      );

      final otp = await _askOtp(context, repo, token);
      if (otp == null || otp.isEmpty || otp.length != 6) return;

      final result = enable
          ? await repo.enable2fa(token: token, otpCode: otp)
          : await repo.disable2fa(token: token, otpCode: otp);

      result.fold(
        (f) {
          showAppSnackBar(context, message: f.message, type: SnackBarType.error);
        },
        (_) {
          auth.updateCurrentUser(
            user.copyWith(
              twoFaEnabled: enable,
              emailVerified: enable ? true : user.emailVerified,
            ),
          );
          showAppSnackBar(
            context,
            message: enable
                ? AppLocalizations.of(context).settings2faEnabled
                : AppLocalizations.of(context).settings2faDisabled,
            type: SnackBarType.success,
          );
        },
      );
    } finally {
      if (mounted) setState(() => _isUpdating2fa = false);
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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Theme section ───────────────────────────────────────
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, _) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.settingsTheme,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 12),
                          // Light / System / Dark toggle
                          SegmentedButton<ThemeMode>(
                            segments: [
                              ButtonSegment(
                                value: ThemeMode.light,
                                icon: const Icon(Icons.light_mode_outlined),
                                label: Text(l10n.settingsThemeLight),
                              ),
                              ButtonSegment(
                                value: ThemeMode.system,
                                icon: const Icon(Icons.auto_mode_outlined),
                                label: Text(l10n.settingsThemeSystem),
                              ),
                              ButtonSegment(
                                value: ThemeMode.dark,
                                icon: const Icon(Icons.dark_mode_outlined),
                                label: Text(l10n.settingsThemeDark),
                              ),
                            ],
                            selected: {themeProvider.themeMode},
                            onSelectionChanged: (s) =>
                                themeProvider.setThemeMode(s.first),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.settingsSeedColor,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 10),
                          // Seed color swatch grid
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: ThemeProvider.presetSeeds.map((preset) {
                              final isSelected =
                                  themeProvider.seedColor.toARGB32() == preset.seed.toARGB32();
                              return Tooltip(
                                message: preset.name,
                                child: InkWell(
                                  mouseCursor: SystemMouseCursors.click,
                                  onTap: () =>
                                      themeProvider.setSeedColor(preset.seed),
                                  borderRadius: BorderRadius.circular(24),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: preset.seed,
                                      shape: BoxShape.circle,
                                      border: isSelected
                                          ? Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                              width: 3,
                                            )
                                          : null,
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: preset.seed
                                                    .withValues(alpha: 0.5),
                                                blurRadius: 6,
                                                spreadRadius: 1,
                                              )
                                            ]
                                          : null,
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 20,
                                          )
                                        : null,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // ── Language section ─────────────────────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).settingsLanguageTitle,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Consumer<LocaleProvider>(
                          builder: (context, localeProvider, _) => Wrap(
                            spacing: 12,
                            children: [
                              ChoiceChip(
                                label: Text(AppLocalizations.of(context).english),
                                selected: localeProvider.locale.languageCode == 'en',
                                onSelected: (_) =>
                                    localeProvider.setLocale(const Locale('en')),
                              ),
                              ChoiceChip(
                                label: Text(AppLocalizations.of(context).vietnamese),
                                selected: localeProvider.locale.languageCode == 'vi',
                                onSelected: (_) =>
                                    localeProvider.setLocale(const Locale('vi')),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).settingsSecurityTitle,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppLocalizations.of(context).settings2faDescription,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: auth.currentUser?.twoFaEnabled ?? false,
                          title: Text(AppLocalizations.of(context).settings2faLabel),
                          subtitle: Text(
                            (auth.currentUser?.twoFaEnabled ?? false)
                                ? AppLocalizations.of(context).settings2faEnabled
                                : AppLocalizations.of(context).settings2faDisabled,
                          ),
                          onChanged: _isUpdating2fa ? null : _toggle2fa,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (auth.canSyncExchange)
                  Card(
                    key: _exchangeSyncSectionKey,
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
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(l10n.exchangeSyncForceRefresh),
                            value: _forceRefreshExchange,
                            onChanged: _isSyncing
                                ? null
                                : (v) =>
                                    setState(() => _forceRefreshExchange = v),
                          ),
                          Text(
                            _lastManualSyncAt == null
                                ? '${l10n.lastManualSync}: ${l10n.neverSyncedYet}'
                                : '${l10n.lastManualSync}: ${_formatDateTime(context, _lastManualSyncAt!)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
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
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(AppLocalizations.of(context).aboutAppTileTitle),
                    subtitle: Text(AppLocalizations.of(context).aboutAppTileSubtitle),
                    trailing: const Icon(Icons.chevron_right),
                    mouseCursor: SystemMouseCursors.click,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutScreen(),
                        ),
                      );
                    },
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

