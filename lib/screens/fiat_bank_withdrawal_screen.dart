import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/fiat_withdrawals_provider.dart';
import 'package:crypto_trading_app/presentation/widgets/app_dropdown_field.dart';

/// Rút USDT về tài khoản ngân hàng VN (MVP — manual payout).
/// Liên kết STK qua Cas.so / BankHub (grant + identity).
class FiatBankWithdrawalScreen extends StatefulWidget {
  const FiatBankWithdrawalScreen({super.key});

  @override
  State<FiatBankWithdrawalScreen> createState() => _FiatBankWithdrawalScreenState();
}

class _FiatBankWithdrawalScreenState extends State<FiatBankWithdrawalScreen> {
  final _amountCtrl = TextEditingController();
  final _casPublicCtrl = TextEditingController();
  String? _selectedVerifiedBankId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final p = context.read<FiatWithdrawalsProvider>();
      await Future.wait([
        p.loadIntegrationSettings(),
        p.loadBanks(),
        p.refreshMyData(),
      ]);
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _casPublicCtrl.dispose();
    super.dispose();
  }

  String _newIdempotencyKey() =>
      '${DateTime.now().toUtc().millisecondsSinceEpoch}_${Random().nextInt(1 << 30)}';

  Future<void> _openCasGrantLink(FiatWithdrawalsProvider p) async {
    final r = await p.casGrantToken(language: 'vi');
    if (!mounted) return;
    if (r == null) return;
    final link = r['linkUrl']?.toString();
    if (link != null && link.isNotEmpty) {
      final uri = Uri.parse(link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không mở được liên kết Cas trên thiết bị này.')),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'API không trả linkUrl — xem payload trong Console Cas hoặc dán publicToken sau redirect.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.watch<FiatWithdrawalsProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.fiatWithdrawBankTitle),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            p.loadIntegrationSettings(),
            p.loadBanks(),
            p.refreshMyData(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.fiatWithdrawBankSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            if (p.errorMessage != null) ...[
              const SizedBox(height: 12),
              Material(
                color: scheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    p.errorMessage!,
                    style: TextStyle(color: scheme.onErrorContainer),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text(l10n.fiatWithdrawSaveBank, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Cas.so / BankHub',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Liên kết tài khoản qua Cas để hệ thống lấy số tài khoản và tên chủ tài khoản (dev & prod chỉ khác base URL / key trên server).',
                      style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                    ),
                    if (p.integration?['casConfigIncomplete'] == true) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Thiếu biến môi trường CAS_* trên backend (CAS_BANKHUB_BASE_URL, CAS_CLIENT_ID, …).',
                        style: TextStyle(color: scheme.error, fontSize: 13),
                      ),
                    ],
                    const SizedBox(height: 16),
                    FilledButton.tonal(
                      onPressed: p.isLoading ? null : () => _openCasGrantLink(p),
                      child: const Text('Bước 1: Mở liên kết Cas'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _casPublicCtrl,
                      decoration: const InputDecoration(
                        labelText: 'publicToken',
                        hintText: 'Dán sau khi redirect / hoàn tất trên Cas',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: p.isLoading
                          ? null
                          : () async {
                              final t = _casPublicCtrl.text.trim();
                              if (t.isEmpty) return;
                              final ok = await p.casCompleteLink(t);
                              if (!context.mounted) return;
                              if (ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Đã lưu tài khoản (chờ duyệt).')),
                                );
                                _casPublicCtrl.clear();
                              }
                            },
                      child: const Text('Bước 2: Hoàn tất & lưu STK'),
                    ),
                  ],
                ),
              ),
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
