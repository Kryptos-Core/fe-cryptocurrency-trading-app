import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/domain/models/runtime_setting_row.dart';
import 'package:crypto_trading_app/domain/models/system_config.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/runtime_settings_provider.dart';
import 'package:crypto_trading_app/presentation/screens/payment_config/widgets/runtime_setting_row_l10n.dart';

/// Platform runtime settings (RPC URLs, limits, symbols) — GET/PATCH `/system-configs/runtime`.
class RuntimeSettingsTabView extends StatefulWidget {
  const RuntimeSettingsTabView({super.key});

  @override
  State<RuntimeSettingsTabView> createState() => _RuntimeSettingsTabViewState();
}

class _RuntimeSettingsTabViewState extends State<RuntimeSettingsTabView> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _ensureControllers(List<RuntimeSettingRow> rows) {
    for (final r in rows) {
      if (!_controllers.containsKey(r.key)) {
        _controllers[r.key] = TextEditingController(text: r.value);
      }
    }
    final valid = rows.map((e) => e.key).toSet();
    for (final k in _controllers.keys.toList()) {
      if (!valid.contains(k)) {
        _controllers.remove(k)?.dispose();
      }
    }
  }

  void _resetControllersAfterSave() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
  }

  Future<void> _save(BuildContext context, RuntimeSettingsProvider provider) async {
    final l10n = AppLocalizations.of(context);
    final updates = <String, String>{};
    for (final r in provider.rows) {
      if (r.isReadOnly) continue;
      updates[r.key] = _controllers[r.key]?.text.trim() ?? '';
    }
    final ok = await provider.saveAll(updates);
    if (!context.mounted) return;
    if (ok) {
      setState(_resetControllersAfterSave);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.paymentConfigRuntimeSaved)),
      );
    } else if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error!), backgroundColor: Colors.red),
      );
    }
  }

  String _sectionTitle(AppLocalizations l10n, ConfigCategory cat) {
    switch (cat) {
      case ConfigCategory.TECH:
        return l10n.paymentConfigRuntimeSectionTech;
      case ConfigCategory.FINANCE:
        return l10n.paymentConfigRuntimeSectionFinance;
      case ConfigCategory.CORE:
        return l10n.paymentConfigRuntimeSectionCore;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<RuntimeSettingsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.rows.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.error != null && provider.rows.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.paymentConfigRuntimeLoadFailed),
                  const SizedBox(height: 8),
                  Text(provider.error!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => provider.load(force: true),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          );
        }

        _ensureControllers(provider.rows);

        final byCategory = <ConfigCategory, List<RuntimeSettingRow>>{};
        for (final r in provider.rows) {
          byCategory.putIfAbsent(r.category, () => []).add(r);
        }
        final order = [ConfigCategory.CORE, ConfigCategory.TECH, ConfigCategory.FINANCE];

        return Column(
          children: [
            if (provider.error != null)
              MaterialBanner(
                content: Text(provider.error!),
                actions: [
                  TextButton(onPressed: () => provider.load(force: true), child: Text(l10n.retry)),
                ],
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  Text(
                    l10n.paymentConfigRuntimeIntro,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  for (final cat in order)
                    if (byCategory[cat] != null) ...[
                      Text(
                        _sectionTitle(l10n, cat),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ...byCategory[cat]!.map((r) => _buildRow(context, l10n, r)),
                      const SizedBox(height: 16),
                    ],
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: provider.isSaving ? null : () => _save(context, provider),
                    child: provider.isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.paymentConfigRuntimeSaveAll),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRow(BuildContext context, AppLocalizations l10n, RuntimeSettingRow r) {
    final ctrl = _controllers[r.key]!;
    final sourceLabel = r.valueSource == 'environment'
        ? l10n.paymentConfigRuntimeSourceEnv
        : l10n.paymentConfigRuntimeSourceDb;
    final rowTitle = RuntimeSettingRowL10n.name(l10n, r);
    final rowDesc = RuntimeSettingRowL10n.description(l10n, r);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    rowTitle,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  sourceLabel,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
            if (rowDesc != null && rowDesc.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                rowDesc,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
            const SizedBox(height: 6),
            Text(
              r.key,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: ctrl,
              readOnly: r.isReadOnly,
              maxLines: r.key.contains('URL') || r.key.contains('HOST') ? 2 : 1,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                isDense: true,
                suffixText: RuntimeSettingRowL10n.dataTypeSuffix(l10n, r.type),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
