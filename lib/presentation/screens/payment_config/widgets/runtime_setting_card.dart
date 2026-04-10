import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crypto_trading_app/domain/models/runtime_setting_row.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/screens/payment_config/widgets/runtime_setting_row_l10n.dart';

/// Normalizes API `type` strings for UI branching.
String normalizeRuntimeSettingValueType(String type) {
  final t = type.toUpperCase().trim();
  if (t == 'BOOL' || t == 'BOOLEAN') return 'BOOLEAN';
  if (t == 'INT' || t == 'INTEGER') return 'INTEGER';
  if (t == 'DOUBLE' || t == 'FLOAT' || t == 'NUMBER') return 'FLOAT';
  return 'STRING';
}

bool parseRuntimeSettingBool(String raw) {
  final v = raw.trim().toLowerCase();
  return v == 'true' || v == '1' || v == 'yes';
}

/// One runtime config row: matches payment-config card styling (outline, surface, 12px radius).
class RuntimeSettingCard extends StatelessWidget {
  const RuntimeSettingCard({
    super.key,
    required this.row,
    required this.controller,
    required this.l10n,
    this.onValueChanged,
  });

  final RuntimeSettingRow row;
  final TextEditingController controller;
  final AppLocalizations l10n;
  final VoidCallback? onValueChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final rowTitle = RuntimeSettingRowL10n.name(l10n, row);
    final rowDesc = RuntimeSettingRowL10n.description(l10n, row);
    final sourceLabel = row.valueSource == 'environment'
        ? l10n.paymentConfigRuntimeSourceEnv
        : l10n.paymentConfigRuntimeSourceDb;
    final normType = normalizeRuntimeSettingValueType(row.type);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.9)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    rowTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _RuntimeSourceCapsule(
                  label: sourceLabel,
                  isEnvironment: row.valueSource == 'environment',
                  scheme: scheme,
                ),
              ],
            ),
            if (rowDesc != null && rowDesc.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                rowDesc,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (normType == 'BOOLEAN')
              _BooleanValueRow(
                row: row,
                controller: controller,
                l10n: l10n,
                scheme: scheme,
                theme: theme,
                onValueChanged: onValueChanged,
              )
            else
              TextField(
                controller: controller,
                readOnly: row.isReadOnly,
                keyboardType: _keyboardTypeFor(normType),
                inputFormatters: _inputFormattersFor(normType),
                maxLines: row.key.contains('URL') || row.key.contains('HOST') ? 2 : 1,
                minLines: row.key.contains('URL') || row.key.contains('HOST') ? 2 : 1,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.65)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: scheme.primary, width: 1.5),
                  ),
                  filled: true,
                  fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  hintText: l10n.paymentConfigRuntimeValueHint,
                ),
                onChanged: (_) => onValueChanged?.call(),
              ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                Chip(
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  label: Text(
                    RuntimeSettingRowL10n.dataTypeSuffix(l10n, row.type),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  side: BorderSide(color: scheme.outline.withValues(alpha: 0.35)),
                  backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 4),
                title: Text(
                  l10n.paymentConfigRuntimeTechKeySection,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: SelectableText(
                      row.key,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        height: 1.35,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static TextInputType _keyboardTypeFor(String normType) {
    return switch (normType) {
      'INTEGER' => TextInputType.number,
      'FLOAT' => const TextInputType.numberWithOptions(decimal: true, signed: true),
      _ => TextInputType.text,
    };
  }

  static List<TextInputFormatter>? _inputFormattersFor(String normType) {
    if (normType == 'INTEGER') {
      return [FilteringTextInputFormatter.allow(RegExp(r'[0-9-]'))];
    }
    if (normType == 'FLOAT') {
      return [FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-eE+]'))];
    }
    return null;
  }
}

class _BooleanValueRow extends StatelessWidget {
  const _BooleanValueRow({
    required this.row,
    required this.controller,
    required this.l10n,
    required this.scheme,
    required this.theme,
    this.onValueChanged,
  });

  final RuntimeSettingRow row;
  final TextEditingController controller;
  final AppLocalizations l10n;
  final ColorScheme scheme;
  final ThemeData theme;
  final VoidCallback? onValueChanged;

  @override
  Widget build(BuildContext context) {
    final on = parseRuntimeSettingBool(controller.text);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Icon(
            on ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
            size: 22,
            color: on ? scheme.primary : scheme.outline,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              on ? l10n.paymentConfigRuntimeValueOn : l10n.paymentConfigRuntimeValueOff,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: on,
            onChanged: row.isReadOnly
                ? null
                : (v) {
                    controller.text = v ? 'true' : 'false';
                    onValueChanged?.call();
                  },
          ),
        ],
      ),
    );
  }
}

class _RuntimeSourceCapsule extends StatelessWidget {
  const _RuntimeSourceCapsule({
    required this.label,
    required this.isEnvironment,
    required this.scheme,
  });

  final String label;
  final bool isEnvironment;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final fromEnv = isEnvironment;
    final bg = fromEnv
        ? scheme.surfaceContainerHighest
        : scheme.primaryContainer.withValues(alpha: 0.85);
    final fg = fromEnv ? scheme.onSurfaceVariant : scheme.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outline.withValues(alpha: fromEnv ? 0.22 : 0.28)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.15,
            ),
      ),
    );
  }
}
