import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/app/di/injection_container.dart' as di;
import 'package:crypto_trading_app/core/network/dio_client.dart';
import 'package:crypto_trading_app/core/localization/locale_provider.dart';
import 'package:crypto_trading_app/core/theme/theme_provider.dart';
import 'package:crypto_trading_app/core/responsive/app_scroll_behavior.dart';
import 'package:crypto_trading_app/features/admin/market_maker/data/datasources/market_maker_remote_datasource.dart';
import 'package:crypto_trading_app/features/notifications/domain/repositories/notification_repository.dart';
import 'package:crypto_trading_app/features/admin/payment_config/data/datasources/payment_config_remote_datasource.dart';
import 'package:crypto_trading_app/features/treasury/domain/repositories/treasury_repository.dart';
import 'package:crypto_trading_app/features/admin/withdrawal_management/data/datasources/withdrawal_admin_remote_datasource.dart';
import 'package:crypto_trading_app/features/settings/domain/repositories/system_config_repository.dart';
import 'package:crypto_trading_app/features/auth/application/services/auth_wallet_flow_service.dart';
import 'package:crypto_trading_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/admin/shared/presentation/providers/admin_enums_provider.dart';
import 'package:crypto_trading_app/features/admin/transactions/presentation/providers/admin_transactions_provider.dart';
import 'package:crypto_trading_app/features/admin/users/presentation/providers/admin_users_provider.dart';
import 'package:crypto_trading_app/features/blockchain/presentation/providers/blockchain_provider.dart';
import 'package:crypto_trading_app/features/markets/presentation/providers/currencies_provider.dart';
import 'package:crypto_trading_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:crypto_trading_app/features/deposits/presentation/providers/deposits_provider.dart';
import 'package:crypto_trading_app/features/markets/presentation/providers/exchange_rate_provider.dart';
import 'package:crypto_trading_app/features/managed_wallets/presentation/providers/managed_wallets_provider.dart';
import 'package:crypto_trading_app/features/admin/market_maker/presentation/providers/market_maker_provider.dart';
import 'package:crypto_trading_app/features/markets/presentation/providers/markets_provider.dart';
import 'package:crypto_trading_app/features/notifications/presentation/providers/notification_provider.dart';
import 'package:crypto_trading_app/features/treasury/presentation/providers/onchain_chain_picker_provider.dart';
import 'package:crypto_trading_app/features/orders/presentation/providers/orders_provider.dart';
import 'package:crypto_trading_app/features/admin/payment_config/presentation/providers/payment_config_provider.dart';
import 'package:crypto_trading_app/features/admin/payment_config/presentation/providers/runtime_settings_provider.dart';
import 'package:crypto_trading_app/features/treasury/presentation/providers/treasury_main_wallet_provider.dart';
import 'package:crypto_trading_app/features/treasury/presentation/providers/treasury_provider.dart';
import 'package:crypto_trading_app/features/wallets/presentation/providers/wallets_provider.dart';
import 'package:crypto_trading_app/features/admin/withdrawal_management/presentation/providers/withdrawal_management_provider.dart';
import 'package:crypto_trading_app/features/home/presentation/screens/main_screen.dart';

class CryptoTradingApp extends StatelessWidget {
  const CryptoTradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    di.initializeDependencies();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LocaleProvider>.value(
          value: di.sl<LocaleProvider>(),
        ),
        ChangeNotifierProvider<ThemeProvider>.value(
          value: di.sl<ThemeProvider>(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) {
            final provider = AuthProvider(
              authRepository: di.sl(),
              tokenService: di.sl(),
            );
            provider.restoreSession();
            DioClient.onForbidden = provider.handleForbidden;
            return provider;
          },
        ),
        Provider<AuthWalletFlowService>.value(
          value: di.sl<AuthWalletFlowService>(),
        ),
        ChangeNotifierProvider(
          create: (_) => CurrenciesProvider(
            currenciesRepository: di.sl(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => MarketsProvider(
            marketsRepository: di.sl(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => WalletsProvider(
            walletsRepository: di.sl(),
            walletRepository: di.sl(),
            notificationsSocketService: di.sl(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => OrdersProvider(
            ordersRepository: di.sl(),
            walletRepository: di.sl(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => DepositsProvider(
            repository: di.sl(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ExchangeRateProvider(
            repository: di.sl(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => BlockchainProvider(
            blockchainRepository: di.sl(),
          ),
        ),
        ChangeNotifierProvider<ManagedWalletsProvider>.value(
          value: di.sl<ManagedWalletsProvider>(),
        ),
        ChangeNotifierProvider<DashboardProvider>(
          create: (_) => DashboardProvider(
            repository: di.sl(),
            wsService: di.sl(),
            tokenService: di.sl(),
          ),
        ),
        ChangeNotifierProvider<NotificationProvider>.value(
          value: di.sl<NotificationProvider>(),
        ),
        Provider<NotificationRepository>.value(
          value: di.sl<NotificationRepository>(),
        ),
        ChangeNotifierProvider<AdminUsersProvider>.value(
          value: di.sl<AdminUsersProvider>(),
        ),
        ChangeNotifierProvider<AdminEnumsProvider>.value(
          value: di.sl<AdminEnumsProvider>(),
        ),
        ChangeNotifierProvider<AdminTransactionsProvider>.value(
          value: di.sl<AdminTransactionsProvider>(),
        ),
        ChangeNotifierProvider<PaymentConfigProvider>(
          create: (_) => PaymentConfigProvider(
            dataSource: PaymentConfigRemoteDataSourceImpl(dioClient: di.sl()),
          ),
        ),
        ChangeNotifierProvider<RuntimeSettingsProvider>(
          create: (_) => RuntimeSettingsProvider(
            repository: di.sl<SystemConfigRepository>(),
          ),
        ),
        ChangeNotifierProvider<OnchainChainPickerProvider>(
          create: (_) => OnchainChainPickerProvider(
            repository: di.sl<TreasuryRepository>(),
            prefs: di.sl<di.SharedPreferences>(),
          ),
        ),
        ChangeNotifierProvider<TreasuryProvider>(
          create: (_) => TreasuryProvider(
            repository: di.sl<TreasuryRepository>(),
          ),
        ),
        ChangeNotifierProvider<TreasuryMainWalletProvider>(
          create: (context) => TreasuryMainWalletProvider(
            repository: di.sl<TreasuryRepository>(),
            authRepo: di.sl(),
            tokenService: di.sl(),
            chainPicker: context.read<OnchainChainPickerProvider>(),
            roleResolver: () => context.read<AuthProvider>().role,
          ),
        ),
        ChangeNotifierProvider<MarketMakerProvider>(
          create: (_) => MarketMakerProvider(
            dataSource: MarketMakerRemoteDataSourceImpl(dioClient: di.sl()),
          ),
        ),
        ChangeNotifierProvider<WithdrawalManagementProvider>(
          create: (_) => WithdrawalManagementProvider(
            dataSource: WithdrawalAdminRemoteDataSourceImpl(
              dioClient: di.sl<DioClient>(),
            ),
          ),
        ),
      ],
      child: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, localeProvider, themeProvider, _) => MaterialApp(
          title: localeProvider.locale.languageCode == 'vi'
              ? 'Ung dung Giao dich Crypto'
              : 'Crypto Trading App',
          debugShowCheckedModeBanner: false,
          scrollBehavior: appScrollBehavior,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.themeMode,
          locale: localeProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: LocaleProvider.supportedLocales,
          home: const MainScreen(),
        ),
      ),
    );
  }
}
