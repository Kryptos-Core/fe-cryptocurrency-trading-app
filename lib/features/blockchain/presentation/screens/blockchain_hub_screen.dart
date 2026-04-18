import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/blockchain/presentation/providers/blockchain_provider.dart';
import 'package:crypto_trading_app/features/blockchain/presentation/screens/linked_wallets_screen.dart';
import 'package:crypto_trading_app/features/blockchain/presentation/screens/onchain_deposit_screen.dart';
import 'package:crypto_trading_app/features/blockchain/presentation/screens/onchain_withdraw_screen.dart';

class BlockchainHubScreen extends StatefulWidget {
  const BlockchainHubScreen({super.key});

  @override
  State<BlockchainHubScreen> createState() => _BlockchainHubScreenState();
}

class _BlockchainHubScreenState extends State<BlockchainHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BlockchainProvider>().fetchLinkedWallets();
      context.read<BlockchainProvider>().fetchRecentTransactions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.onchainWalletsTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.onchainLinkedWallets),
            Tab(text: l10n.deposit),
            Tab(text: l10n.withdraw),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l10n.refresh,
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final provider = context.read<BlockchainProvider>();
              await provider.fetchLinkedWallets();
              await provider.fetchRecentTransactions();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          LinkedWalletsScreen(),
          OnchainDepositScreen(),
          OnchainWithdrawScreen(),
        ],
      ),
    );
  }
}
