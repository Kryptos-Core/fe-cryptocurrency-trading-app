import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/fiat_withdrawals_provider.dart';

class FiatWithdrawalsAdminScreen extends StatefulWidget {
  const FiatWithdrawalsAdminScreen({super.key});

  @override
  State<FiatWithdrawalsAdminScreen> createState() => _FiatWithdrawalsAdminScreenState();
}

class _FiatWithdrawalsAdminScreenState extends State<FiatWithdrawalsAdminScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<FiatWithdrawalsProvider>();
      p.loadAdminBanks(status: 'PENDING');
      p.loadAdminRequests(status: 'PENDING_REVIEW');
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.watch<FiatWithdrawalsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.fiatWithdrawAdminTitle),
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(text: l10n.fiatWithdrawAdminBanks),
            Tab(text: l10n.fiatWithdrawAdminRequests),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          RefreshIndicator(
            onRefresh: () => p.loadAdminBanks(status: 'PENDING'),
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                if (p.errorMessage != null)
                  ListTile(
                    title: Text(p.errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ),
                if (p.adminLoading) const LinearProgressIndicator(),
                ...p.adminBanks.map((b) {
                  final id = b['bankAccountId'] as String? ?? '';
                  return Card(
                    child: ListTile(
                      title: Text('${b['bankCode']} ***${b['accountNumberLast4']}'),
                      subtitle: Text('${b['accountHolderName']}\nuser: ${b['userId']}'),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle_outline),
                            onPressed: () async {
                              final ok = await p.adminVerifyBank(id);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(ok ? 'OK' : (p.errorMessage ?? 'Error'))),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel_outlined),
                            onPressed: () async {
                              final ok = await p.adminRejectBank(id, reason: 'Rejected');
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(ok ? 'OK' : (p.errorMessage ?? 'Error'))),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          RefreshIndicator(
            onRefresh: () => p.loadAdminRequests(status: 'PENDING_REVIEW'),
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                if (p.adminLoading) const LinearProgressIndicator(),
                ...p.adminRequests.map((r) {
                  final id = r['requestId'] as String? ?? '';
                  return Card(
                    child: ListTile(
                      title: Text('${r['amount']} ${r['status']}'),
                      subtitle: Text('${r['bankCode']} ***${r['accountNumberLast4']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.done_all),
                            onPressed: () async {
                              final refCtrl = TextEditingController();
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(l10n.fiatWithdrawTransferRef),
                                  content: TextField(
                                    controller: refCtrl,
                                    decoration: InputDecoration(labelText: l10n.fiatWithdrawTransferRef),
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
                                    FilledButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: Text(l10n.fiatWithdrawComplete),
                                    ),
                                  ],
                                ),
                              );
                              if (ok != true || !context.mounted) return;
                              final done = await p.adminCompleteWithdrawal(id, refCtrl.text.trim());
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(done ? 'OK' : (p.errorMessage ?? 'Error'))),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.block),
                            onPressed: () async {
                              final done = await p.adminRejectWithdrawal(id, reason: 'Rejected');
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(done ? 'OK' : (p.errorMessage ?? 'Error'))),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
