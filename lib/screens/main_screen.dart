import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/presentation/providers/auth_provider.dart';
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
import 'package:crypto_trading_app/presentation/screens/blockchain/blockchain_hub_screen.dart';

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

  @override
  void initState() {
    super.initState();
    // Listen for 403 events from DioClient via AuthProvider and show a SnackBar.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authProvider = context.read<AuthProvider>();
      _authProvider!.addListener(_onAuthChanged);
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
        const SnackBar(
          content: Text('⛔ You do not have permission to perform this action.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Public tabs always rendered — no auth required.
  // Auth-gated tabs are replaced with _AuthRequiredTab when user is a guest.
  List<Widget> _buildScreens(bool isAuthenticated) => [
        const DashboardScreen(),
        const MarketsListScreen(),
        isAuthenticated ? const WalletApiScreen() : const _AuthRequiredTab(returnTab: 2),
        isAuthenticated ? const ProfileScreen() : const _GuestProfileTab(),
      ];

  static const List<String> _tabTitles = [
    'Dashboard',
    'Markets',
    'Wallets',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAuthenticated = context.select<AuthProvider, bool>((a) => a.isAuthenticated);
    final screens = _buildScreens(isAuthenticated);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          tooltip: 'Menu',
        ),
        title: Text(_tabTitles[_currentIndex]),
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
              tooltip: 'On-chain',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BlockchainHubScreen(),
                  ),
                );
              },
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
              title: const Text('On-chain Wallets'),
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
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
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
                      leading: const Icon(Icons.admin_panel_settings,
                          color: Colors.deepOrange),
                      title: const Text('User Management'),
                      subtitle: const Text('Admin area',
                          style: TextStyle(fontSize: 11)),
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('User management screen — coming soon'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    if (auth.canReviewSecurityRequests)
                      ListTile(
                        leading: const Icon(Icons.security,
                            color: Colors.deepOrange),
                        title: const Text('Security requests'),
                        subtitle: const Text('Approve/reject email & password changes',
                            style: TextStyle(fontSize: 11)),
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
                    if (auth.isAdmin) ...[
                      ListTile(
                        leading:
                            const Icon(Icons.sync, color: Colors.deepOrange),
                        title: const Text('Manual re-sync Binance'),
                        subtitle: const Text('Admin area',
                            style: TextStyle(fontSize: 11)),
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Manual exchange re-sync — coming soon'),
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
                title: const Text('Logout',
                    style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(context);
                  context.read<AuthProvider>().logout();
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.login, color: Colors.indigo),
                title: const Text('Sign In',
                    style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w600)),
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
            Icon(
              Icons.lock_outline,
              size: 64,
              color: colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Text(
              'Sign in required',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please sign in to access this feature.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                icon: const Icon(Icons.login),
                label: const Text('Sign In'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text('Create Account'),
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
            'Welcome, Guest',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to access your wallet, place orders, and manage your account.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: colorScheme.outline),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              icon: const Icon(Icons.login),
              label: const Text('Sign In'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: const Text('Create Account'),
            ),
          ),
          const SizedBox(height: 40),
          const Divider(),
          const SizedBox(height: 16),
          // Public features available to guests
          Text(
            'Available without signing in',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colorScheme.outline,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          _FeatureRow(
            icon: Icons.trending_up,
            label: 'Live market data & charts',
            colorScheme: colorScheme,
          ),
          _FeatureRow(
            icon: Icons.currency_bitcoin,
            label: 'Supported currencies & networks',
            colorScheme: colorScheme,
          ),
          _FeatureRow(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Platform deposit methods',
            colorScheme: colorScheme,
          ),
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
