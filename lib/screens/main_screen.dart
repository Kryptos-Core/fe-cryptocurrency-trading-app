import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
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
import 'package:crypto_trading_app/presentation/screens/blockchain/blockchain_hub_screen.dart';
import 'package:crypto_trading_app/presentation/screens/payment_config/payment_config_screen.dart';
import 'package:crypto_trading_app/presentation/screens/withdrawal_management/withdrawal_management_screen.dart';
import 'package:crypto_trading_app/presentation/providers/payment_config_provider.dart';
import 'package:crypto_trading_app/presentation/providers/treasury_provider.dart';
import 'package:crypto_trading_app/screens/admin_user_list_screen.dart';
import 'package:crypto_trading_app/screens/admin_transactions_screen.dart';
import 'package:crypto_trading_app/screens/admin_currencies_screen.dart';

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
  final NotificationsSocketService _notifSocket = NotificationsSocketService();

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
    _notifSocket.dispose();
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
  // Wallet tab (incl. Tổng danh mục): visible for ALL authenticated roles (trader, admin, support, risk, finance, market maker).
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
          if (_currentIndex == 2 && isAuthenticated)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () =>
                  context.read<WalletsProvider>().fetchWallets(refresh: true),
              tooltip: l10n.refresh,
            ),
          if (_currentIndex == 2 && isAuthenticated)
            IconButton(
              icon: const Icon(Icons.account_tree_outlined),
              tooltip: l10n.onchainTooltip,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BlockchainHubScreen(),
                  ),
                );
              },
            ),
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
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Smart refresh: re-check dashboard data freshness on tab focus
          if (index == 0) {
            context.read<DashboardProvider>().refresh();
          }
          if (index == 2) {
            context.read<DashboardProvider>().refresh();
            context.read<WalletsProvider>().fetchWallets(includeZero: true);
          }
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard),
            label: l10n.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.trending_up_outlined),
            activeIcon: const Icon(Icons.trending_up),
            label: l10n.markets,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            activeIcon: const Icon(Icons.account_balance_wallet),
            label: l10n.wallets,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
      drawer: Drawer(
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
                        style:
                            const TextStyle(fontSize: 11, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                accountEmail: Text(
                  auth.currentUser?.email ?? '',
                  style: const TextStyle(color: Colors.white70),
                ),
                currentAccountPicture: CircleAvatar(
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
                          style: const TextStyle(fontSize: 28, color: Colors.white),
                        )
                      : null,
                ),
              ),
            ),
            // ── Standard navigation ──────────────────────────────────
            ListTile(
              leading: const Icon(Icons.currency_bitcoin),
              title: Text(l10n.currencies),
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
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: Text(l10n.orders),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrdersScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_tree_outlined),
              title: Text(l10n.drawerOnchainWallets),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BlockchainHubScreen(),
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
                  leading: const Icon(Icons.trending_up, color: Colors.deepOrange),
                  title: Text(l10n.marketMakerHubTitle),
                  subtitle: Text(
                    l10n.marketMakerHubDrawerSubtitle,
                    style: const TextStyle(fontSize: 11),
                  ),
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
              leading: const Icon(Icons.settings),
              title: Text(l10n.drawerSettings),
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
            const Divider(),
            // ── Admin section (visible only to ADMIN / Support / Risk) ─
            Consumer<AuthProvider>(
              builder: (_, auth, __) {
                if (!auth.canViewUserList) return const SizedBox.shrink();
                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.admin_panel_settings, color: Colors.deepOrange),
                      title: Text(l10n.drawerUserManagement),
                      subtitle: Text(l10n.drawerAdminArea, style: const TextStyle(fontSize: 11)),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminUserListScreen(),
                          ),
                        );
                      },
                    ),
                    if (auth.canReviewSecurityRequests)
                      ListTile(
                        leading: const Icon(Icons.security, color: Colors.deepOrange),
                        title: Text(l10n.drawerSecurityRequests),
                        subtitle: Text(l10n.drawerSecuritySubtitle, style: const TextStyle(fontSize: 11)),
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
                    // Giám sát giao dịch (ADMIN / RISK_OFFICER / SUPPORT_AGENT)
                    if (auth.canViewUserList)
                      ListTile(
                        leading: const Icon(Icons.receipt_long_outlined, color: Colors.deepOrange),
                        title: Text(l10n.drawerTransactionMonitoring),
                        subtitle: Text(l10n.drawerTransactionMonitoringSubtitle, style: const TextStyle(fontSize: 11)),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminTransactionsScreen(),
                            ),
                          );
                        },
                      ),
                    // Coin management — full CRUD for admin, read-only view for
                    // risk officer and support agent (role guard inside screen).
                    if (auth.canViewUserList)
                      ListTile(
                        leading: const Icon(Icons.currency_bitcoin, color: Colors.deepOrange),
                        title: Text(l10n.drawerCoinManagement),
                        subtitle: Text(
                          auth.canManageCurrencies
                              ? l10n.drawerCoinManagementSubtitleCrud
                              : l10n.drawerCoinManagementSubtitleView,
                          style: const TextStyle(fontSize: 11),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminCurrenciesScreen(),
                            ),
                          );
                        },
                      ),
                    // Broadcast & manual resync remain admin-only
                    if (auth.isAdmin) ...[
                      ListTile(
                        leading: const Icon(Icons.campaign_outlined, color: Colors.deepOrange),
                        title: Text(l10n.drawerBroadcastNotification),
                        subtitle: Text(l10n.drawerBroadcastSubtitle, style: const TextStyle(fontSize: 11)),
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
                        leading: const Icon(Icons.sync, color: Colors.deepOrange),
                        title: Text(l10n.drawerManualResync),
                        subtitle: Text(l10n.drawerAdminArea, style: const TextStyle(fontSize: 11)),
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.drawerManualResyncComingSoon),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                    const Divider(),
                  ],
                );
              },
            ),
            // ── Payment config (ADMIN + FINANCE_MANAGER) ─────────────
            Consumer<AuthProvider>(
              builder: (_, auth, __) {
                if (!auth.canManagePaymentConfigs) return const SizedBox.shrink();
                return Column(
                  children: [
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.payment_outlined, color: Colors.deepOrange),
                      title: Text(l10n.drawerPaymentConfig),
                      subtitle: Text(l10n.drawerPaymentConfigSubtitle, style: const TextStyle(fontSize: 11)),
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
                    ListTile(
                      leading: const Icon(Icons.account_balance_wallet_outlined, color: Colors.deepOrange),
                      title: Text(l10n.drawerWithdrawalManagement),
                      subtitle: Text(l10n.drawerWithdrawalManagementSubtitle, style: const TextStyle(fontSize: 11)),
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
                  ],
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: Text(l10n.aboutTitle),
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
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: Text(l10n.logout, style: const TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(context);
                  context.read<AuthProvider>().logout();
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.login, color: Colors.indigo),
                title: Text(l10n.signIn, style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
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
