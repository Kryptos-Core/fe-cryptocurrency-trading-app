import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/markets_provider.dart';
import 'package:crypto_trading_app/presentation/providers/wallets_provider.dart';
import 'package:crypto_trading_app/screens/dashboard_screen.dart';
import 'package:crypto_trading_app/screens/currencies_list_screen.dart';
import 'package:crypto_trading_app/screens/markets_list_screen.dart';
import 'package:crypto_trading_app/screens/wallet_api_screen.dart';
import 'package:crypto_trading_app/screens/profile_screen.dart';
import 'package:crypto_trading_app/screens/orders_screen.dart';
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

  @override
  void initState() {
    super.initState();
    // Listen for 403 events from DioClient via AuthProvider and show a SnackBar.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().addListener(_onAuthChanged);
    });
  }

  @override
  void dispose() {
    context.read<AuthProvider>().removeListener(_onAuthChanged);
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

  final List<Widget> _screens = [
    const DashboardScreen(), // Home: Dashboard với overview
    const MarketsListScreen(), // Markets
    const WalletApiScreen(), // Wallets (Real API)
    const ProfileScreen(), // Profile
  ];

  static const List<String> _tabTitles = [
    'Dashboard',
    'Markets',
    'Wallets',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          if (_currentIndex == 2)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => context.read<WalletsProvider>().fetchWallets(refresh: true),
              tooltip: l10n.refresh,
            ),
          if (_currentIndex == 2)
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
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
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
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Text(
                    (auth.currentUser?.fullName.isNotEmpty == true
                            ? auth.currentUser!.fullName[0]
                            : '?')
                        .toUpperCase(),
                    style: const TextStyle(
                        fontSize: 28, color: Colors.white),
                  ),
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
                            content: Text('User management screen — coming soon'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    if (auth.isAdmin) ...[
                      ListTile(
                        leading: const Icon(Icons.sync,
                            color: Colors.deepOrange),
                        title: const Text('Sync Binance'),
                        subtitle: const Text('Admin area',
                            style: TextStyle(fontSize: 11)),
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Exchange sync — coming soon'),
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
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout',
                  style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(context);
                context.read<AuthProvider>().logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
