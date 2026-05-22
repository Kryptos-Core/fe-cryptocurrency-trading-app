/// Named paths for [GoRouter]; tab indices on [MainScreen] stay unchanged.
abstract final class AppRoutes {
  AppRoutes._();

  /// Shell — bottom navigation (dashboard / markets / wallets / profile).
  static const String root = '/';

  /// Auth
  static const String login = '/login';
  static const String register = '/register';

  /// Primary pushes from shell / drawer
  static const String orders = '/orders';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String currencies = '/currencies';
  static const String notifications = '/notifications';
  static const String marketMaker = '/market-maker';

  /// Treasury / managed wallets
  static const String treasury = '/treasury';
  static const String managedWallets = '/managed-wallets';

  /// Admin (aligned with plan + existing screens)
  static const String adminUsers = '/admin/users';
  static const String adminTransactions = '/admin/transactions';
  static const String adminCurrencies = '/admin/currencies';
  static const String adminMarkets = '/admin/markets';
  static const String adminPaymentConfig = '/admin/payment-config';
  static const String adminSystemConfig = '/admin/system-config';
  static const String adminWithdrawals = '/admin/withdrawals';
  static const String adminFiatWithdrawals = '/admin/fiat-withdrawals';
  static const String adminBroadcast = '/admin/broadcast';
  static const String adminSecurityRequests = '/admin/security-requests';
  static const String adminDepositWatcher = '/admin/deposit-watcher';

  /// Binance non-custodial trading
  static const String binanceApiKeys = '/binance/api-keys';
  static const String binanceSpotTrading = '/binance/spot/:credentialId';
  static const String binanceFuturesTrading = '/binance/futures';

  /// Bottom navigation indices — must stay aligned with `_buildScreens` in MainScreen.
  static const int tabDashboard = 0;
  static const int tabMarkets = 1;
  static const int tabWallets = 2;
  static const int tabProfile = 3;

  /// Paths guests may open without signing in (shell + browse + auth screens).
  static const Set<String> guestAllowlist = {
    root,
    login,
    register,
    currencies,
    about,
    settings,
  };
}
