import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:crypto_trading_app/app/di/injection_container.dart' as di;
import 'package:crypto_trading_app/app/router/app_routes.dart';
import 'package:crypto_trading_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/features/auth/presentation/screens/login_screen.dart';
import 'package:crypto_trading_app/features/auth/presentation/screens/register_screen.dart';
import 'package:crypto_trading_app/features/admin/broadcast/presentation/screens/broadcast_notification_screen.dart';
import 'package:crypto_trading_app/features/admin/currencies/presentation/screens/admin_currencies_screen.dart';
import 'package:crypto_trading_app/features/admin/markets/presentation/screens/admin_markets_screen.dart';
import 'package:crypto_trading_app/features/admin/fiat_withdrawals/presentation/screens/fiat_withdrawals_admin_screen.dart';
import 'package:crypto_trading_app/features/admin/payment_config/presentation/screens/payment_config_screen.dart';
import 'package:crypto_trading_app/features/admin/payment_config/presentation/providers/payment_config_provider.dart';
import 'package:crypto_trading_app/features/admin/system_config/presentation/screens/system_config_screen.dart';
import 'package:crypto_trading_app/features/admin/security_requests/presentation/screens/security_requests_review_screen.dart';
import 'package:crypto_trading_app/features/admin/deposit_watcher/presentation/screens/deposit_watcher_admin_screen.dart';
import 'package:crypto_trading_app/features/admin/deposit_watcher/presentation/providers/deposit_watcher_provider.dart';
import 'package:crypto_trading_app/features/admin/transactions/presentation/screens/admin_transactions_screen.dart';
import 'package:crypto_trading_app/features/admin/users/presentation/screens/admin_user_list_screen.dart';
import 'package:crypto_trading_app/features/admin/withdrawal_management/presentation/screens/withdrawal_management_screen.dart';
import 'package:crypto_trading_app/features/home/presentation/screens/about_screen.dart';
import 'package:crypto_trading_app/features/home/presentation/screens/main_screen.dart';
import 'package:crypto_trading_app/features/home/presentation/screens/manual_detail_screen.dart';
import 'package:crypto_trading_app/features/managed_wallets/presentation/screens/managed_wallets_screen.dart';
import 'package:crypto_trading_app/features/managed_wallets/presentation/providers/managed_wallets_provider.dart';
import 'package:crypto_trading_app/features/markets/presentation/screens/currencies_list_screen.dart';
import 'package:crypto_trading_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:crypto_trading_app/features/orders/presentation/screens/orders_screen.dart';
import 'package:crypto_trading_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:crypto_trading_app/features/trading/presentation/screens/market_maker/market_maker_hub_screen.dart';
import 'package:crypto_trading_app/features/treasury/presentation/screens/treasury_main_wallets/treasury_main_wallets_screen.dart';
import 'package:crypto_trading_app/features/binance_trading/presentation/screens/api_key_list_screen.dart';
import 'package:crypto_trading_app/features/binance_trading/presentation/screens/spot_trading_screen.dart';
import 'package:crypto_trading_app/features/binance_trading/application/providers/binance_credentials_provider.dart';
import 'package:crypto_trading_app/features/binance_trading/application/providers/binance_trading_provider.dart';
import 'package:crypto_trading_app/features/binance_trading/data/repositories/binance_trading_repository_impl.dart';
import 'package:crypto_trading_app/features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import 'package:crypto_trading_app/features/ai_assistant/presentation/screens/ai_chat_screen.dart';

// Shared navigator key for the root-level Navigator. Used both to opt
// routes into the root Navigator (via `parentNavigatorKey`) and to anchor
// GoRouter itself so we don't depend on a hidden default key.
final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter createAppRouter(AuthProvider auth) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.root,
    refreshListenable: auth,
    redirect: (context, state) {
      final loc = state.uri.path;
      final loggedIn = auth.isAuthenticated;
      if (!loggedIn && !AppRoutes.guestAllowlist.contains(loc)) {
        return AppRoutes.login;
      }
      if (loggedIn &&
          (loc == AppRoutes.login || loc == AppRoutes.register)) {
        return AppRoutes.root;
      }
      return null;
    },
    routes: [
      // The root shell used to live here as a `ShellRoute` wrapping
      // `MainScreen`. That configuration triggers flutter/flutter#140586
      // (`!keyReservation.contains(key)`) and a follow-on
      // `Multiple widgets used the same GlobalKey` crash whenever two
      // concurrent `GoRouterState` rebuilds leave two `MainScreen`
      // Elements live in the same frame — `GoRouter` rebuilds the
      // shell page alongside a transition, which makes
      // `_MainScreenState` mount twice and the framework-allocated
      // `GlobalObjectKey<State<StatefulWidget>>` to be reserved for
      // both. The MaterialPage-key fix we landed before this only
      // silences the navigator-level duplicate-key assertion; the
      // element-level `Semantics` parent in the new crash log proves
      // the underlying duplicate-Element problem is still there.
      //
      // Simplest, correct fix: promote `MainScreen` to a top-level
      // `GoRoute` with no shell. The bottom-nav lives entirely inside
      // `MainScreen` (it doesn't need a parent shell), and child
      // routes are pushed onto the root navigator so `MainScreen` is
      // disposed cleanly when leaving `/` — guaranteeing there is only
      // ever one `_MainScreenState` mounted at a time.
      GoRoute(
        path: AppRoutes.root,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const MainScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.orders,
        builder: (_, __) => const OrdersScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.about,
        builder: (_, __) => const AboutScreen(),
      ),
      GoRoute(
        path: AppRoutes.manual,
        builder: (_, __) => const OperatorManualScreen(),
        routes: [
          GoRoute(
            path: 'detail/:topic',
            builder: (context, state) {
              final extra = state.extra;
              final topic = extra is ManualDetailTopic
                  ? extra
                  : _topicFromKey(state.pathParameters['topic']);
              return ManualDetailScreen(topic: topic);
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.currencies,
        builder: (_, __) => const CurrenciesListScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.marketMaker,
        builder: (_, __) => const MarketMakerHubScreen(),
      ),
      GoRoute(
        path: AppRoutes.treasury,
        builder: (_, __) => const TreasuryMainWalletsScreen(),
      ),
      GoRoute(
        path: AppRoutes.managedWallets,
        builder: (context, _) => ChangeNotifierProvider<
            ManagedWalletsProvider>.value(
          value: context.read<ManagedWalletsProvider>(),
          child: const ManagedWalletsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.adminPaymentConfig,
        builder: (context, _) => ChangeNotifierProvider<
            PaymentConfigProvider>.value(
          value: context.read<PaymentConfigProvider>(),
          child: const PaymentConfigScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.adminSystemConfig,
        builder: (_, __) => const SystemConfigScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminUsers,
        builder: (_, __) => const AdminUserListScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminSecurityRequests,
        builder: (_, __) => const SecurityRequestsReviewScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminDepositWatcher,
        builder: (context, _) => ChangeNotifierProvider<DepositWatcherProvider>.value(
          value: DepositWatcherProvider(),
          child: const DepositWatcherAdminScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.adminTransactions,
        builder: (_, __) => const AdminTransactionsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminCurrencies,
        builder: (_, __) => const AdminCurrenciesScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminBroadcast,
        builder: (_, __) => const BroadcastNotificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminMarkets,
        builder: (_, __) => const AdminMarketsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminWithdrawals,
        builder: (_, __) => const WithdrawalManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminFiatWithdrawals,
        builder: (_, __) => const FiatWithdrawalsAdminScreen(),
      ),
      GoRoute(
        path: AppRoutes.binanceApiKeys,
        builder: (context, _) => ChangeNotifierProvider<BinanceCredentialsProvider>.value(
          value: context.read<BinanceCredentialsProvider>(),
          child: const ApiKeyListScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.binanceSpotTrading,
        builder: (context, state) => MultiProvider(
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
            credentialId: state.pathParameters['credentialId'] ?? '',
            label: state.uri.queryParameters['label'],
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.aiAssistant,
        builder: (_, __) => const AiAssistantScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (_, __) => const AiChatScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) =>
                AiChatScreen(conversationId: state.pathParameters['id']),
          ),
        ],
      ),
    ],
  );
}

ManualDetailTopic _topicFromKey(String? key) {
  switch (key) {
    case 'faq':
      return ManualDetailTopic.faq;
    case 'contact':
      return ManualDetailTopic.contact;
    case 'glossary':
    default:
      return ManualDetailTopic.glossary;
  }
}
