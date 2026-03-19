import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/treasury_provider.dart';
import 'package:crypto_trading_app/presentation/widgets/app_dropdown_field.dart';

class TreasuryHistoryTabView extends StatefulWidget {
  const TreasuryHistoryTabView({super.key});

  @override
  State<TreasuryHistoryTabView> createState() => _TreasuryHistoryTabViewState();
}

class _TreasuryHistoryTabViewState extends State<TreasuryHistoryTabView> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TreasuryProvider>().loadHistory();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<TreasuryProvider>(
      builder: (context, provider, _) {
        return RefreshIndicator(
          onRefresh: provider.loadHistory,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: [
              _TreasuryHistoryFilterBar(searchCtrl: _searchCtrl, provider: provider),
              const SizedBox(height: 12),
              Text(l10n.treasuryOperationsTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              if (provider.isLoadingHistory && provider.operations.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
              else if (provider.operations.isEmpty)
                Text(l10n.treasuryNoOperations)
              else
                ...provider.operations
                    .map((op) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('${op.type} · ${op.chain} · ${op.amount}'),
                          subtitle: Text('${op.status}${op.txHash != null ? ' · ${op.txHash!}' : ''}'),
                        )),
              const Divider(height: 24),
              Text(l10n.treasuryTransactionsTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              if (provider.transactions.isEmpty)
                Text(l10n.treasuryNoTransactions)
              else
                ...provider.transactions
                    .map((tx) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('${tx.type} · ${tx.chain} · ${tx.amount}'),
                          subtitle: Text('${tx.status}${tx.txHash != null ? ' · ${tx.txHash!}' : ''}'),
                        )),
            ],
          ),
        );
      },
    );
  }
}

class _TreasuryHistoryFilterBar extends StatelessWidget {
  final TextEditingController searchCtrl;
  final TreasuryProvider provider;

  const _TreasuryHistoryFilterBar({required this.searchCtrl, required this.provider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AppDropdownField<String>(
                value: provider.historyChain,
                labelText: l10n.treasuryChainLabel,
                hintText: l10n.treasuryFilterAll,
                items: const [
                  DropdownMenuItem(value: 'TRON_NILE', child: Text('TRON_NILE')),
                  DropdownMenuItem(value: 'TRON_SHASTA', child: Text('TRON_SHASTA')),
                  DropdownMenuItem(value: 'ETH_SEPOLIA', child: Text('ETH_SEPOLIA')),
                ],
                onChanged: (value) async {
                  provider.setHistoryFilters(
                    chain: value,
                    type: provider.historyType,
                    status: provider.historyStatus,
                    query: provider.historyQuery,
                  );
                  await provider.loadHistory();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppDropdownField<String>(
                value: provider.historyType,
                labelText: l10n.treasuryTypeLabel,
                hintText: l10n.treasuryFilterAll,
                items: const [
                  DropdownMenuItem(value: 'SWEEP', child: Text('SWEEP')),
                  DropdownMenuItem(value: 'FUND', child: Text('FUND')),
                ],
                onChanged: (value) async {
                  provider.setHistoryFilters(
                    chain: provider.historyChain,
                    type: value,
                    status: provider.historyStatus,
                    query: provider.historyQuery,
                  );
                  await provider.loadHistory();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: searchCtrl,
          decoration: InputDecoration(
            labelText: l10n.treasurySearchHint,
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () async {
                provider.setHistoryFilters(
                  chain: provider.historyChain,
                  type: provider.historyType,
                  status: provider.historyStatus,
                  query: searchCtrl.text.trim().isEmpty ? null : searchCtrl.text.trim(),
                );
                await provider.loadHistory();
              },
            ),
          ),
          onSubmitted: (_) async {
            provider.setHistoryFilters(
              chain: provider.historyChain,
              type: provider.historyType,
              status: provider.historyStatus,
              query: searchCtrl.text.trim().isEmpty ? null : searchCtrl.text.trim(),
            );
            await provider.loadHistory();
          },
        ),
      ],
    );
  }
}
