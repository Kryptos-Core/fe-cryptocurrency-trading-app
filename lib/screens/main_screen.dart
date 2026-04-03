import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/core/ui/app_responsive.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart' show sl;
import 'package:crypto_trading_app/core/services/notifications_socket_service.dart';
import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/presentation/providers/notification_provider.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/markets_provider.dart';
import 'package:crypto_trading_app/presentation/providers/wallets_provider.dart';
import 'package:crypto_trading_app/presentation/providers/dashboard_provider.dart';
import 'package:crypto_trading_app/screens/dashboard_screen.dart';
import 'package:crypto_trading_app/screens/currencies_list_screen.dart';
import 'package:crypto_trading_app/screens/markets_list_screen.dart';
import 'package:crypto_trading_app/screens/wallet_api_screen.dart';
import 'package:crypto_trading_app/screens/profile_screen.dart';
import 'package:crypto_trading_app/screens/login_screen.dart';
import 'package:crypto_trading_app/screens/register_screen.dart';
import 'package:crypto_trading_app/screens/orders_screen.dart';
import 'package:crypto_trading_app/screens/security_requests_review_screen.dart';
import 'package:crypto_trading_app/screens/about_screen.dart';
import 'package:crypto_trading_app/screens/settings_screen.dart';
import 'package:crypto_trading_app/screens/notifications_screen.dart';
import 'package:crypto_trading_app/screens/broadcast_notification_screen.dart';
import 'package:crypto_trading_app/screens/market_maker/market_maker_hub_screen.dart';
import 'package:crypto_trading_app/presentation/screens/payment_config/payment_config_screen.dart';
import 'package:crypto_trading_app/presentation/screens/withdrawal_management/withdrawal_management_screen.dart';
import 'package:crypto_trading_app/presentation/screens/fiat_withdrawals/fiat_withdrawals_admin_screen.dart';
import 'package:crypto_trading_app/presentation/providers/payment_config_provider.dart';
import 'package:crypto_trading_app/presentation/providers/treasury_provider.dart';
import 'package:crypto_trading_app/presentation/screens/treasury_main_wallets/treasury_main_wallets_screen.dart';
import 'package:crypto_trading_app/screens/admin_user_list_screen.dart';
import 'package:crypto_trading_app/screens/admin_transactions_screen.dart';
import 'package:crypto_trading_app/screens/admin_currencies_screen.dart';
import 'package:crypto_trading_app/presentation/screens/managed_wallets/managed_wallets_screen.dart';
import 'package:crypto_trading_app/presentation/providers/managed_wallets_provider.dart';

/// Main Screen với Bottom Navigation Bar
/// Cho phép user navigate giữa các modules
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Stored reference so we can remove the listener in dispose() without using context.
  /// Using context in dispose() is unsafe because the widget tree is already deactivated.
  AuthProvider? _authProvider;
  bool _notificationsInitialized = false;

  /// Dedicated socket for the /notifications namespace — handles notification:new
  /// and payment_config:event messages from NotificationsGateway.
  /// Using singleton from DI to share with WalletsProvider for real-time balance updates.
  final NotificationsSocketService _notifSocket = sl<NotificationsSocketService>();

  @override
  void initState() {
    super.initState();
    // Listen for 403 events from DioClient via AuthProvider and show a SnackBar.
    // Also initialize NotificationProvider once user is authenticated.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authProvider = context.read<AuthProvider>();
      _authProvider!.addListener(_onAuthChanged);
      // Trigger once for existing session (restoreSession runs before this listener)
      _maybeInitNotifications();
    });
  }

  @override
  void dispose() {
    _authProvider?.removeListener(_onAuthChanged);
    _authProvider = null;
    super.dispose();
  }

  void _onAuthChanged() {
    final auth = context.read<AuthProvider>();
    if (auth.lastRequestForbidden && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).noPermissionMessage),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
    _maybeInitNotifications();
  }

  void _maybeInitNotifications() {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    if (auth.isAuthenticated && !_notificationsInitialized) {
      _notificationsInitialized = true;
      final notifProvider = context.read<NotificationProvider>();
      notifProvider.initialize();

      // Register payment_config event callback before connecting
      notifProvider.addPaymentConfigEventListener(_onPaymentConfigEvent);
      notifProvider.addTreasuryEventListener(_onTreasuryEvent);

      // Connect to the /notifications Socket.IO namespace and wire socket to providers
      _connectNotificationsSocket(notifProvider);
    } else if (!auth.isAuthenticated) {
      _notificationsInitialized = false;
      _notifSocket.disconnect();
    }
  }

  Future<void> _connectNotificationsSocket(NotificationProvider notifProvider) async {
    // Get access token from TokenService via GetIt — avoids context in async gap
    final tokenService = sl<TokenService>();
    final accessToken = tokenService.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) return;

    await _notifSocket.connect(ApiConstants.notificationsSocketUrl, accessToken);
    notifProvider.listenNotificationsSocket(_notifSocket);
  }

  /// Called when a `payment_config:event` WebSocket message arrives.
  void _onPaymentConfigEvent(Map<String, dynamic> data) {
    if (!mounted) return;
    context.read<PaymentConfigProvider>().handleWebSocketEvent(data);
  }

  /// Called when a `treasury:event` WebSocket message arrives.
  void _onTreasuryEvent(Map<String, dynamic> data) {
    if (!mounted) return;
    context.read<TreasuryProvider>().handleRealtimeEvent(data);
  }

  // Public tabs always rendered — no auth required.
  // Auth-gated tabs are replaced with _AuthRequiredTab when user is a guest.
  List<Widget> _buildScreens(bool isAuthenticated) => [
        const DashboardScreen(),
        const MarketsListScreen(),
        isAuthenticated ? const WalletApiScreen() : const _AuthRequiredTab(returnTab: 2),
        isAuthenticated ? const ProfileScreen() : const _GuestProfileTab(),
      ];

  List<String> _tabTitles(AppLocalizations l10n) => [
        l10n.dashboard,
        l10n.markets,
        l10n.wallets,
        l10n.profile,
      ];

  /// Handle bottom nav tab tap with smart refresh logic.
  void _onTabTap(int index) {
    setState(() => _currentIndex = index);
    if (index == 0) {
      context.read<DashboardProvider>().refresh();
    }
    if (index == 2) {
      context.read<DashboardProvider>().refresh();
      context.read<WalletsProvider>().fetchWallets(includeZero: true);
    }
  }

  /// Open the Trade (Orders) screen. Requires authentication.
  void _openTradeScreen() {
    if (!context.read<AuthProvider>().isAuthenticated) {
      _showAuthRequired();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OrdersScreen()),
    );
  }

  /// Show a prompt directing the user to sign in before trading.
  void _showAuthRequired() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.authRequiredTitle),
        action: SnackBarAction(
          label: l10n.signIn,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          ),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Build a single bottom nav item (icon + label, tap-to-select).
  Widget _buildNavItem(
    int index,
    IconData outlinedIcon,
    IconData filledIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      onTap: () => _onTabTap(index),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? filledIcon : outlinedIcon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: color, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAuthenticated = context.select<AuthProvider, bool>((a) => a.isAuthenticated);
    final screens = _buildScreens(isAuthenticated);
    final titles = _tabTitles(l10n);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          tooltip: l10n.menuTooltip,
        ),
        title: Text(titles[_currentIndex]),
        actions: [
          if (_currentIndex == 1)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<MarketsProvider>().refreshKeepingPosition();
              },
              tooltip: l10n.refresh,
            ),
          if (_currentIndex == 2 && isAuthenticated) ...[
            // Treasury (Managed Wallets) — visible for users with canManageWallets permission
            Consumer<AuthProvider>(
              builder: (_, auth, __) {
                if (!auth.canManageWallets) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.account_balance_outlined),
                  tooltip: l10n.treasuryToolbarTooltip,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider<ManagedWalletsProvider>.value(
                          value: context.read<ManagedWalletsProvider>(),
                          child: const ManagedWalletsScreen(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
          // Notification bell — visible for all authenticated users
          if (isAuthenticated)
            Consumer<NotificationProvider>(
              builder: (_, prov, __) => Badge(
                isLabelVisible: prov.unreadCount > 0,
                label: Text(
                  prov.unreadCount > 99 ? '99+' : '${prov.unreadCount}',
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.red,
                textColor: Colors.white,
                offset: const Offset(-4, 4),
                child: IconButton(
                  tooltip: l10n.notificationsTooltip,
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: AppCenteredContent(
        child: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 72,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomAppBar(
                height: 60,
                padding: EdgeInsets.zero,
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard, l10n.dashboard),
                          _buildNavItem(1, Icons.trending_up_outlined, Icons.trending_up, l10n.markets),
                        ],
                      ),
                    ),
                    const SizedBox(width: 56),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildNavItem(2, Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, l10n.wallets),
                          _buildNavItem(3, Icons.person_outline, Icons.person, l10n.profile),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Positioned(
              top: 0,
              child: _TradeFabPlaceholder(),
            ),
            Positioned(
              top: 0,
              child: _TradeFab(onTap: _openTradeScreen),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Consumer<AuthProvider>(
                builder: (_, auth, __) => UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  accountName: Row(
                    children: [
                      Text(
                        auth.currentUser?.fullName ?? l10n.appTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          auth.role.displayName,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  accountEmail: Text(
                    auth.currentUser?.email ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  currentAccountPicture: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white24,
                        backgroundImage: auth.currentUser?.avatarUrl != null &&
                                auth.currentUser!.avatarUrl!.isNotEmpty
                            ? NetworkImage(auth.currentUser!.avatarUrl!)
                            : null,
                        child: auth.currentUser?.avatarUrl == null ||
                                auth.currentUser!.avatarUrl!.isEmpty
                            ? Text(
                                (auth.currentUser?.fullName.isNotEmpty == true
                                        ? auth.currentUser!.fullName[0]
                                        : '?')
                                    .toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 28, color: Colors.white),
                              )
                            : null,
                      ),
                      if (auth.isEmailVerified)
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Tooltip(
                            message:
                                AppLocalizations.of(context).profileEmailVerifiedTooltip,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.verified,
                                size: 14,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // ── Chung: tiền tệ, công cụ, cài đặt ─────────────────────
              _DrawerSectionHeader(
                l10n.drawerSectionGeneral,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              ),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Icon(
                  Icons.currency_bitcoin,
                  size: 22,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                title: Text(l10n.currencies),
                mouseCursor: SystemMouseCursors.click,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CurrenciesListScreen(),
                    ),
                  );
                },
              ),
              Consumer<AuthProvider>(
                builder: (_, auth, __) {
                  if (!auth.canAccessMarketMakerHub) {
                    return const SizedBox.shrink();
                  }
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Icon(
                      Icons.trending_up,
                      size: 22,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    title: Text(l10n.marketMakerHubTitle),
                    subtitle: Text(
                      l10n.marketMakerHubDrawerSubtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    mouseCursor: SystemMouseCursors.click,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MarketMakerHubScreen(),
                        ),
                      );
                    },
                  );
                },
              ),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Icon(
                  Icons.settings_outlined,
                  size: 22,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                title: Text(l10n.drawerSettings),
                mouseCursor: SystemMouseCursors.click,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
              Consumer<AuthProvider>(
                builder: (_, auth, __) {
                  final showAdmin = auth.canViewUserList;
                  final showFinance = auth.canManagePaymentConfigs;
                  final showManagedStandalone = auth.canManageWallets &&
                      !showFinance &&
                      !showAdmin;
                  if (!showAdmin && !showFinance && !showManagedStandalone) {
                    return const SizedBox.shrink();
                  }
                  return const Divider(height: 1);
                },
              ),
              // ── Các khối quản trị: cùng style card cho mọi role (Admin, Support,
              //    Risk, Finance Manager, …) ─────────────────────────────────
              Consumer<AuthProvider>(
                builder: (_, auth, __) {
                  final showAdmin = auth.canViewUserList;
                  final showFinance = auth.canManagePaymentConfigs;
                  final showManagedStandalone = auth.canManageWallets &&
                      !showFinance &&
                      !showAdmin;
                  if (!showAdmin && !showFinance && !showManagedStandalone) {
                    return const SizedBox.shrink();
                  }
                  final cs = Theme.of(context).colorScheme;
                  final subtitleStyle = Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant);

                  void openManagedWallets() {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ChangeNotifierProvider<ManagedWalletsProvider>.value(
                          value: context.read<ManagedWalletsProvider>(),
                          child: const ManagedWalletsScreen(),
                        ),
                      ),
                    );
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showAdmin)
                        _DrawerManagementCard(
                          title: l10n.drawerSectionAdministration,
                          children: [
                            _DrawerSubsectionHeader(
                                l10n.drawerSectionAdminUsers),
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 2),
                              leading: Icon(
                                Icons.admin_panel_settings_outlined,
                                size: 22,
                                color: cs.primary,
                              ),
                              title: Text(l10n.drawerUserManagement),
                              subtitle: Text(
                                l10n.drawerAdminArea,
                                style: subtitleStyle,
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AdminUserListScreen(),
                                  ),
                                );
                              },
                            ),
                            if (auth.canReviewSecurityRequests)
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 2),
                                leading: Icon(
                                  Icons.security,
                                  size: 22,
                                  color: cs.primary,
                                ),
                                title: Text(l10n.drawerSecurityRequests),
                                subtitle: Text(
                                  l10n.drawerSecuritySubtitle,
                                  style: subtitleStyle,
                                ),
                                mouseCursor: SystemMouseCursors.click,
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SecurityRequestsReviewScreen(),
                                    ),
                                  );
                                },
                              ),
                            _DrawerSubsectionHeader(
                                l10n.drawerSectionAdminOps),
                            if (auth.canManageWallets && !auth.canManagePaymentConfigs)
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 2),
                                leading: Icon(
                                  Icons.account_balance_outlined,
                                  size: 22,
                                  color: cs.primary,
                                ),
                                title: Text(l10n.drawerManagedWalletsTitle),
                                subtitle: Text(
                                  l10n.drawerManagedWalletsSubtitle,
                                  style: subtitleStyle,
                                ),
                                mouseCursor: SystemMouseCursors.click,
                                onTap: openManagedWallets,
                              ),
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 2),
                              leading: Icon(
                                Icons.receipt_long_outlined,
                                size: 22,
                                color: cs.primary,
                              ),
                              title: Text(l10n.drawerTransactionMonitoring),
                              subtitle: Text(
                                l10n.drawerTransactionMonitoringSubtitle,
                                style: subtitleStyle,
                              ),
                              mouseCursor: SystemMouseCursors.click,
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AdminTransactionsScreen(),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 2),
                              leading: Icon(
                                Icons.currency_bitcoin,
                                size: 22,
                                color: cs.primary,
                              ),
                              title: Text(l10n.drawerCoinManagement),
                              subtitle: Text(
                                auth.canManageCurrencies
                                    ? l10n.drawerCoinManagementSubtitleCrud
                                    : l10n.drawerCoinManagementSubtitleView,
                                style: subtitleStyle,
                              ),
                              mouseCursor: SystemMouseCursors.click,
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AdminCurrenciesScreen(),
                                  ),
                                );
                              },
                            ),
                            if (auth.isAdmin) ...[
                              _DrawerSubsectionHeader(
                                  l10n.drawerSectionAdminSystem),
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 2),
                                leading: Icon(
                                  Icons.campaign_outlined,
                                  size: 22,
                                  color: cs.primary,
                                ),
                                title: Text(l10n.drawerBroadcastNotification),
                                subtitle: Text(
                                  l10n.drawerBroadcastSubtitle,
                                  style: subtitleStyle,
                                ),
                                mouseCursor: SystemMouseCursors.click,
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const BroadcastNotificationScreen(),
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 2),
                                leading: Icon(
                                  Icons.sync,
                                  size: 22,
                                  color: cs.primary,
                                ),
                                title: Text(l10n.drawerManualResync),
                                subtitle: Text(
                                  l10n.drawerAdminArea,
                                  style: subtitleStyle,
                                ),
                                mouseCursor: SystemMouseCursors.click,
                                onTap: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          l10n.drawerManualResyncComingSoon),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      if (showFinance)
                        _DrawerManagementCard(
                          title: l10n.drawerSectionFinance,
                          topPadding: showAdmin ? 12 : 0,
                          children: [
                            ..._financeDrawerItemSpecs(
                                    context: context, auth: auth)
                                .map(
                              (spec) => ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                leading: Icon(
                                  spec.icon,
                                  size: 22,
                                  color: cs.primary,
                                ),
                                title: Text(spec.title(l10n)),
                                subtitle: Text(
                                  spec.subtitle(l10n),
                                  style: subtitleStyle,
                                ),
                                mouseCursor: SystemMouseCursors.click,
                                onTap: spec.onTap,
                              ),
                            ),
                          ],
                        ),
                      if (showManagedStandalone)
                        _DrawerManagementCard(
                          title: l10n.drawerSectionTreasuryDeposits,
                          topPadding: showAdmin || showFinance ? 12 : 0,
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              leading: Icon(
                                Icons.account_balance_outlined,
                                size: 22,
                                color: cs.primary,
                              ),
                              title: Text(l10n.drawerManagedWalletsTitle),
                              subtitle: Text(
                                l10n.drawerManagedWalletsSubtitle,
                                style: subtitleStyle,
                              ),
                              mouseCursor: SystemMouseCursors.click,
                              onTap: openManagedWallets,
                            ),
                          ],
                        ),
                    ],
                  );
                },
              ),
              // ── Tài khoản ─────────────────────────────────────────────
              const Divider(height: 1),
              _DrawerSectionHeader(
                l10n.drawerSectionAccount,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              ),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Icon(
                  Icons.info_outline,
                  size: 22,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                title: Text(l10n.aboutTitle),
                mouseCursor: SystemMouseCursors.click,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutScreen(),
                    ),
                  );
                },
              ),
              if (isAuthenticated)
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: Text(
                    l10n.logout,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                  mouseCursor: SystemMouseCursors.click,
                  onTap: () {
                    Navigator.pop(context);
                    context.read<AuthProvider>().logout();
                  },
                )
              else
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: const Icon(Icons.login, color: Colors.indigo),
                  title: Text(
                    l10n.signIn,
                    style: const TextStyle(
                        color: Colors.indigo, fontWeight: FontWeight.w600),
                  ),
                  mouseCursor: SystemMouseCursors.click,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginScreen()),
                    );
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Drawer layout helpers ─────────────────────────────────────────────────────

/// Tiêu đề nhóm menu (CHUNG, QUẢN TRỊ, …).
class _DrawerSectionHeader extends StatelessWidget {
  final String title;
  final EdgeInsets padding;

  const _DrawerSectionHeader(
    this.title, {
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 8),
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: padding,
      child: Text(
        title.toUpperCase(),
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Tiêu đề nhóm con trong khối quản trị.
class _DrawerSubsectionHeader extends StatelessWidget {
  final String title;

  const _DrawerSubsectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

/// Declarative row in the Finance drawer — order and visibility live in one list.
class _FinanceDrawerItemSpec {
  const _FinanceDrawerItemSpec({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String Function(AppLocalizations l10n) title;
  final String Function(AppLocalizations l10n) subtitle;
  final VoidCallback onTap;
}

List<_FinanceDrawerItemSpec> _financeDrawerItemSpecs({
  required BuildContext context,
  required AuthProvider auth,
}) {
  void openManagedWallets() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<ManagedWalletsProvider>.value(
          value: context.read<ManagedWalletsProvider>(),
          child: const ManagedWalletsScreen(),
        ),
      ),
    );
  }

  return <_FinanceDrawerItemSpec>[
    if (auth.canManageWallets)
      _FinanceDrawerItemSpec(
        icon: Icons.account_balance_outlined,
        title: (l) => l.drawerManagedWalletsTitle,
        subtitle: (l) => l.drawerManagedWalletsSubtitle,
        onTap: openManagedWallets,
      ),
    _FinanceDrawerItemSpec(
      icon: Icons.payment_outlined,
      title: (l) => l.drawerPaymentConfig,
      subtitle: (l) => l.drawerPaymentConfigSubtitle,
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: context.read<PaymentConfigProvider>(),
              child: const PaymentConfigScreen(),
            ),
          ),
        );
      },
    ),
    _FinanceDrawerItemSpec(
      icon: Icons.admin_panel_settings_outlined,
      title: (l) => l.drawerTreasuryMainWalletsTitle,
      subtitle: (l) => l.drawerTreasuryMainWalletsSubtitle,
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const TreasuryMainWalletsScreen(),
          ),
        );
      },
    ),
    _FinanceDrawerItemSpec(
      icon: Icons.account_balance_wallet_outlined,
      title: (l) => l.drawerWithdrawalManagement,
      subtitle: (l) => l.drawerWithdrawalManagementSubtitle,
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const WithdrawalManagementScreen(),
          ),
        );
      },
    ),
    _FinanceDrawerItemSpec(
      icon: Icons.savings_outlined,
      title: (l) => l.drawerFiatWithdrawalAdmin,
      subtitle: (l) => l.drawerFiatWithdrawalAdminSubtitle,
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const FiatWithdrawalsAdminScreen(),
          ),
        );
      },
    ),
  ];
}

/// Card nền bo góc dùng chung cho mọi mục quản trị (Admin, Support, Risk, Finance…).
class _DrawerManagementCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final double topPadding;

  const _DrawerManagementCard({
    required this.title,
    required this.children,
    this.topPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(8, topPadding, 8, 0),
      child: Material(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _DrawerSectionHeader(
              title,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            ),
            ...children,
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Guest guard widgets ────────────────────────────────────────────────────────

/// Shown in place of any protected tab when the user is not authenticated.
/// Provides a clear CTA to go to login, with an optional returnTab hint.
class _AuthRequiredTab extends StatelessWidget {
  final int returnTab;

  const _AuthRequiredTab({required this.returnTab});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 64, color: colorScheme.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context).authRequiredTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).authRequiredSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                icon: const Icon(Icons.login),
                label: Text(AppLocalizations.of(context).signIn),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: Text(AppLocalizations.of(context).createAccount),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Profile tab content shown to guests — highlights what they can do after signing in.
class _GuestProfileTab extends StatelessWidget {
  const _GuestProfileTab();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 44,
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(
              Icons.person_outline,
              size: 44,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).welcomeGuest,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).guestSignInDesc,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
              icon: const Icon(Icons.login),
              label: Text(AppLocalizations.of(context).signIn),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
              child: Text(AppLocalizations.of(context).createAccount),
            ),
          ),
          const SizedBox(height: 40),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).guestFeaturesTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colorScheme.outline,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          _FeatureRow(icon: Icons.trending_up, label: AppLocalizations.of(context).guestFeatureLiveMarkets, colorScheme: colorScheme),
          _FeatureRow(icon: Icons.currency_bitcoin, label: AppLocalizations.of(context).guestFeatureCurrencies, colorScheme: colorScheme),
          _FeatureRow(icon: Icons.account_balance_wallet_outlined, label: AppLocalizations.of(context).guestFeatureDeposit, colorScheme: colorScheme),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;

  const _FeatureRow({
    required this.icon,
    required this.label,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

/// Fake notch background under the center action to preserve the old visual rhythm
/// without using BottomAppBar's built-in notch/clipper on desktop.
class _TradeFabPlaceholder extends StatelessWidget {
  const _TradeFabPlaceholder();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).bottomAppBarTheme.color ?? Theme.of(context).colorScheme.surface;
    return IgnorePointer(
      child: Container(
        width: 72,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
    );
  }
}

/// Trade button with the same raised 3D visual, but rendered as a normal widget
/// so it no longer depends on Scaffold geometry/notch behavior.
class _TradeFab extends StatelessWidget {
  final VoidCallback onTap;

  const _TradeFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Material(
        color: Colors.transparent,
        child: InkResponse(
          mouseCursor: SystemMouseCursors.click,
          onTap: onTap,
          customBorder: const CircleBorder(),
          radius: 32,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4DB6AC), Color(0xFF00695C)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF26A69A).withValues(alpha: 0.55),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.18),
                  blurRadius: 4,
                  offset: const Offset(-2, -2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 5,
                  left: 8,
                  child: Container(
                    width: 40,
                    height: 14,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                const Icon(
                  Icons.swap_horiz_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
