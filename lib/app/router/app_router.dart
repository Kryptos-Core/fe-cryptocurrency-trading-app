import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
import 'package:crypto_trading_app/features/admin/security_requests/presentation/screens/security_requests_review_screen.dart';
import 'package:crypto_trading_app/features/admin/transactions/presentation/screens/admin_transactions_screen.dart';
import 'package:crypto_trading_app/features/admin/users/presentation/screens/admin_user_list_screen.dart';
import 'package:crypto_trading_app/features/admin/withdrawal_management/presentation/screens/withdrawal_management_screen.dart';
import 'package:crypto_trading_app/features/home/presentation/screens/about_screen.dart';
import 'package:crypto_trading_app/features/home/presentation/screens/main_screen.dart';
import 'package:crypto_trading_app/features/managed_wallets/presentation/screens/managed_wallets_screen.dart';
import 'package:crypto_trading_app/features/managed_wallets/presentation/providers/managed_wallets_provider.dart';
import 'package:crypto_trading_app/features/markets/presentation/screens/currencies_list_screen.dart';
import 'package:crypto_trading_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:crypto_trading_app/features/orders/presentation/screens/orders_screen.dart';
import 'package:crypto_trading_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:crypto_trading_app/features/trading/presentation/screens/market_maker/market_maker_hub_screen.dart';
import 'package:crypto_trading_app/features/treasury/presentation/screens/treasury_main_wallets/treasury_main_wallets_screen.dart';

GoRouter createAppRouter(AuthProvider auth) {
  return GoRouter(
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
      ShellRoute(
        builder: (_, __, Widget child) => child,
        routes: [
          GoRoute(
            path: AppRoutes.root,
            builder: (_, __) => const MainScreen(),
          ),
        ],
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
        path: AppRoutes.adminUsers,
        builder: (_, __) => const AdminUserListScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminSecurityRequests,
        builder: (_, __) => const SecurityRequestsReviewScreen(),
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
    ],
  );
}
