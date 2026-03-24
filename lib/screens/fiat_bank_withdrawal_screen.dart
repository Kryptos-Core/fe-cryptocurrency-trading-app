import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/fiat_withdrawals_provider.dart';
import 'package:crypto_trading_app/presentation/widgets/app_dropdown_field.dart';

/// Rút USDT về tài khoản ngân hàng VN (MVP — manual payout).
class FiatBankWithdrawalScreen extends StatefulWidget {
  const FiatBankWithdrawalScreen({super.key});

  @override
  State<FiatBankWithdrawalScreen> createState() => _FiatBankWithdrawalScreenState();
}

class _FiatBankWithdrawalScreenState extends State<FiatBankWithdrawalScreen> {
  final _acctCtrl = TextEditingController();
  final _holderCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String? _selectedBankCode;
  String? _selectedVerifiedBankId;
  Timer? _holderLookupDebounce;
  bool _isResolvingHolder = false;
  String? _holderLookupError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<FiatWithdrawalsProvider>();
      p.loadBanks();
      p.refreshMyData();
    });
  }

  @override
  void dispose() {
    _holderLookupDebounce?.cancel();
    _acctCtrl.dispose();
    _holderCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  String _newIdempotencyKey() =>
      '${DateTime.now().toUtc().millisecondsSinceEpoch}_${Random().nextInt(1 << 30)}';

  void _scheduleResolveHolder({bool immediate = false}) {
    _holderLookupDebounce?.cancel();
    if (immediate) {
      _resolveHolder();
      return;
    }
    _holderLookupDebounce = Timer(const Duration(milliseconds: 500), _resolveHolder);
  }

  Future<void> _resolveHolder() async {
    final bankCode = _selectedBankCode;
    final accountNumber = _acctCtrl.text.replaceAll(RegExp(r'\s+'), '');

    if (bankCode == null || bankCode.isEmpty || accountNumber.length < 6) {
      if (!mounted) return;
      setState(() {
        _isResolvingHolder = false;
        _holderLookupError = null;
        _holderCtrl.clear();
      });
      return;
    }

    setState(() {
      _isResolvingHolder = true;
      _holderLookupError = null;
      _holderCtrl.clear();
    });

    final provider = context.read<FiatWithdrawalsProvider>();
    final requestedBankCode = bankCode;
    final requestedAccountNumber = accountNumber;

    final holderName = await provider.resolveAccountHolderName(
      bankCode: requestedBankCode,
      accountNumber: requestedAccountNumber,
    );

    if (!mounted) return;
    final currentAccount = _acctCtrl.text.replaceAll(RegExp(r'\s+'), '');
    if (_selectedBankCode != requestedBankCode || currentAccount != requestedAccountNumber) {
      return;
    }

    setState(() {
      _isResolvingHolder = false;
      if (holderName == null || holderName.isEmpty) {
        _holderLookupError =
            'Không truy xuất được tên chủ tài khoản. Vui lòng kiểm tra lại ngân hàng/số tài khoản.';
        _holderCtrl.clear();
      } else {
        _holderLookupError = null;
        _holderCtrl.text = holderName;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.watch<FiatWithdrawalsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.fiatWithdrawBankTitle),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await p.loadBanks();
          await p.refreshMyData();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.fiatWithdrawBankSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (p.errorMessage != null) ...[
              const SizedBox(height: 12),
              Material(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    p.errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text(l10n.fiatWithdrawSaveBank, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            AppDropdownField<String>(
              value: _selectedBankCode,
              labelText: l10n.fiatWithdrawBankCode,
              menuMaxHeight: 320,
              items: p.banks
                  .map((b) => DropdownMenuItem<String>(
                        value: b['code'] as String?,
                        child: Text('${b['code']} — ${b['name']}', overflow: TextOverflow.ellipsis),
                      ))
                  .where((x) => x.value != null)
                  .cast<DropdownMenuItem<String>>()
                  .toList(),
              onChanged: (v) {
                setState(() => _selectedBankCode = v);
                _scheduleResolveHolder(immediate: true);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _acctCtrl,
              keyboardType: TextInputType.number,
              onChanged: (_) => _scheduleResolveHolder(),
              decoration: InputDecoration(
                labelText: l10n.fiatWithdrawAccountNumber,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _holderCtrl,
              readOnly: true,
              decoration: InputDecoration(
                labelText: l10n.fiatWithdrawHolderName,
                border: const OutlineInputBorder(),
                suffixIcon: _isResolvingHolder
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
                helperText: _holderLookupError,
                helperStyle: TextStyle(
                  color: _holderLookupError == null ? null : Theme.of(context).colorScheme.error,
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: p.isLoading
                  ? null
                  : () async {
                      final code = _selectedBankCode;
                      if (code == null || code.isEmpty) return;
                      final holderName = _holderCtrl.text.trim();
                      if (holderName.isEmpty) return;
                      final ok = await p.submitBank(
                        bankCode: code,
                        accountNumber: _acctCtrl.text.trim(),
                        accountHolderName: holderName,
                      );
                      if (!context.mounted) return;
                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('OK')),
                        );
                        _acctCtrl.clear();
                        _holderCtrl.clear();
                      }
                    },
              child: Text(l10n.fiatWithdrawSaveBank),
            ),
            const Divider(height: 40),
            Text(l10n.fiatWithdrawMyBanks, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (p.isLoading) const LinearProgressIndicator(),
            ...p.myBankAccounts.map(
              (b) => ListTile(
                title: Text('${b['bankCode']} ***${b['accountNumberLast4']}'),
                subtitle: Text('${b['accountHolderName']} — ${b['status']}'),
              ),
            ),
            const Divider(height: 40),
            Text(l10n.fiatWithdrawSubmitRequest, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            AppDropdownField<String>(
              value: _selectedVerifiedBankId,
              labelText: l10n.fiatWithdrawMyBanks,
              menuMaxHeight: 280,
              items: p.myBankAccounts
                  .where((b) => b['status'] == 'VERIFIED')
                  .map((b) => DropdownMenuItem<String>(
                        value: b['bankAccountId'] as String?,
                        child: Text(
                          '${b['bankCode']} ***${b['accountNumberLast4']}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .where((x) => x.value != null)
                  .cast<DropdownMenuItem<String>>()
                  .toList(),
              onChanged: (v) => setState(() => _selectedVerifiedBankId = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.fiatWithdrawAmount,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: p.isLoading
                  ? null
                  : () async {
                      final id = _selectedVerifiedBankId;
                      if (id == null) return;
                      final amt = _amountCtrl.text.trim();
                      if (amt.isEmpty) return;
                      final ok = await p.submitWithdrawal(
                        bankAccountId: id,
                        amount: amt,
                        idempotencyKey: _newIdempotencyKey(),
                      );
                      if (!context.mounted) return;
                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('OK')),
                        );
                        _amountCtrl.clear();
                      }
                    },
              child: Text(l10n.fiatWithdrawSubmitRequest),
            ),
            const Divider(height: 40),
            Text(l10n.fiatWithdrawMyRequests, style: Theme.of(context).textTheme.titleMedium),
            ...p.myRequests.map(
              (r) => ListTile(
                title: Text('${r['amount']} — ${r['status']}'),
                subtitle: Text('${r['bankCode']} ***${r['accountNumberLast4']}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
