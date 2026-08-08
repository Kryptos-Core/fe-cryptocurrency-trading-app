import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/features/settings/domain/models/runtime_setting_row.dart';
import 'package:crypto_trading_app/features/settings/domain/models/system_config.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/admin/payment_config/presentation/providers/runtime_settings_provider.dart';
import 'package:crypto_trading_app/features/admin/payment_config/presentation/screens/widgets/runtime_setting_card.dart';

/// Platform runtime settings view for a single [ConfigCategory].
///
/// Used inside the 4 nested runtime-settings tabs (Tech / Finance / Ops / Core).
/// Delegates all API calls to [RuntimeSettingsProvider] filtered by [category].
class RuntimeSettingsCategoryView extends StatefulWidget {
  const RuntimeSettingsCategoryView({
    super.key,
    required this.category,
  });

  /// ConfigCategory name, e.g. 'tech', 'finance', 'ops', 'core'.
  final String category;

  @override
  State<RuntimeSettingsCategoryView> createState() =>
      _RuntimeSettingsCategoryViewState();
}

class _RuntimeSettingsCategoryViewState
    extends State<RuntimeSettingsCategoryView> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<RuntimeSettingsProvider>().load(
            category: widget.category,
            force: true,
          );
    });
  }

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
    for (final r in provider.rowsFor(widget.category)) {
      if (r.isReadOnly) continue;
      updates[r.key] = _controllers[r.key]?.text.trim() ?? '';
    }
    final ok = await provider.saveAll(updates, category: widget.category);
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
        final rows = provider.rowsFor(widget.category);
        if (provider.isLoading && rows.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.error != null && rows.isEmpty) {
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
                    onPressed: () => provider.load(
                      category: widget.category,
                      force: true,
                    ),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          );
        }

        _ensureControllers(rows);

        return Column(
          children: [
            if (provider.error != null)
              MaterialBanner(
                content: Text(provider.error!),
                actions: [
                  TextButton(
                    onPressed: () => provider.load(
                      category: widget.category,
                      force: true,
                    ),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => provider.load(
                  category: widget.category,
                  force: true,
                ),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    _RuntimeCategoryBanner(
                      l10n: l10n,
                      scheme: scheme,
                      textTheme: textTheme,
                      category: widget.category,
                    ),
                    const SizedBox(height: 16),
                    ..._runtimeCards(
                      rows: rows,
                      l10n: l10n,
                      textTheme: textTheme,
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
                    onPressed: provider.isSaving
                        ? null
                        : () => _save(context, provider),
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

List<Widget> _runtimeCards({
  required List<RuntimeSettingRow> rows,
  required AppLocalizations l10n,
  required TextTheme textTheme,
  required Map<String, TextEditingController> controllers,
  required VoidCallback onValueChanged,
}) {
  final widgets = <Widget>[];
  for (var i = 0; i < rows.length; i++) {
    if (i > 0) widgets.add(const SizedBox(height: 8));
    widgets.add(
      RuntimeSettingCard(
        key: ValueKey(rows[i].key),
        row: rows[i],
        controller: controllers[rows[i].key]!,
        l10n: l10n,
        onValueChanged: onValueChanged,
      ),
    );
  }
  return widgets;
}

class _RuntimeCategoryBanner extends StatelessWidget {
  const _RuntimeCategoryBanner({
    required this.l10n,
    required this.scheme,
    required this.textTheme,
    required this.category,
  });

  final AppLocalizations l10n;
  final ColorScheme scheme;
  final TextTheme textTheme;
  final String category;

  @override
  Widget build(BuildContext context) {
    final (title, description) = _categoryInfo(l10n, category);
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

(String title, String description) _categoryInfo(AppLocalizations l10n, String category) {
  switch (category) {
    case 'tech':
      return (
        l10n.paymentConfigRuntimeSectionTech,
        l10n.paymentConfigRuntimeSectionTechDesc,
      );
    case 'finance':
      return (
        l10n.paymentConfigRuntimeSectionFinance,
        l10n.paymentConfigRuntimeSectionFinanceDesc,
      );
    case 'ops':
      return (
        l10n.paymentConfigRuntimeSectionOps,
        l10n.paymentConfigRuntimeSectionOpsDesc,
      );
    case 'core':
      return (
        l10n.paymentConfigRuntimeSectionCore,
        l10n.paymentConfigRuntimeSectionCoreDesc,
      );
    case 'auth_security':
      return (
        l10n.paymentConfigRuntimeSectionAuthSecurity,
        l10n.paymentConfigRuntimeSectionAuthSecurityDesc,
      );
    default:
      return (
        l10n.paymentConfigRuntimeSectionCore,
        '',
      );
  }
}
