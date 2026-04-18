import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/features/settings/domain/models/runtime_setting_row.dart';
import 'package:crypto_trading_app/features/settings/domain/models/system_config.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/admin/payment_config/presentation/providers/runtime_settings_provider.dart';
import 'package:crypto_trading_app/features/admin/payment_config/presentation/screens/widgets/runtime_setting_card.dart';

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

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
                  Icon(Icons.error_outline_rounded, size: 48, color: scheme.error),
                  const SizedBox(height: 16),
                  Text(
                    l10n.paymentConfigRuntimeLoadFailed,
                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(provider.error!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton.tonalIcon(
                    onPressed: () => provider.load(force: true),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.retry),
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
        const order = [ConfigCategory.core, ConfigCategory.tech, ConfigCategory.finance];

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
              child: RefreshIndicator(
                onRefresh: () => provider.load(force: true),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    _RuntimeIntroBanner(l10n: l10n, scheme: scheme, textTheme: textTheme),
                    const SizedBox(height: 16),
                    ..._runtimeSectionWidgets(
                      l10n: l10n,
                      textTheme: textTheme,
                      order: order,
                      byCategory: byCategory,
                      controllers: _controllers,
                      onValueChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: 88),
                  ],
                ),
              ),
            ),
            Material(
              elevation: 0,
              color: scheme.surface,
              child: SafeArea(
                top: false,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.85)),
                    ),
                  ),
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
}

List<Widget> _runtimeSectionWidgets({
  required AppLocalizations l10n,
  required TextTheme textTheme,
  required List<ConfigCategory> order,
  required Map<ConfigCategory, List<RuntimeSettingRow>> byCategory,
  required Map<String, TextEditingController> controllers,
  required VoidCallback onValueChanged,
}) {
  final widgets = <Widget>[];
  var first = true;
  for (final cat in order) {
    final rows = byCategory[cat];
    if (rows == null || rows.isEmpty) continue;
    if (!first) {
      widgets.add(const SizedBox(height: 12));
    }
    first = false;
    widgets.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          _runtimeSectionTitle(l10n, cat),
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
    for (final r in rows) {
      widgets.add(
        RuntimeSettingCard(
          key: ValueKey(r.key),
          row: r,
          controller: controllers[r.key]!,
          l10n: l10n,
          onValueChanged: onValueChanged,
        ),
      );
    }
  }
  return widgets;
}

String _runtimeSectionTitle(AppLocalizations l10n, ConfigCategory cat) {
  switch (cat) {
    case ConfigCategory.tech:
      return l10n.paymentConfigRuntimeSectionTech;
    case ConfigCategory.finance:
      return l10n.paymentConfigRuntimeSectionFinance;
    case ConfigCategory.core:
      return l10n.paymentConfigRuntimeSectionCore;
  }
}

class _RuntimeIntroBanner extends StatelessWidget {
  const _RuntimeIntroBanner({
    required this.l10n,
    required this.scheme,
    required this.textTheme,
  });

  final AppLocalizations l10n;
  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.tune_rounded, size: 22, color: scheme.tertiary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.paymentConfigRuntimeIntro,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
