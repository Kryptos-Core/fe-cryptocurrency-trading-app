import 'package:crypto_trading_app/domain/models/runtime_setting_row.dart';
import 'package:crypto_trading_app/domain/models/system_config.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/screens/payment_config/widgets/runtime_setting_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('runtime setting helpers', () {
    test('normalizeRuntimeSettingValueType maps aliases', () {
      expect(normalizeRuntimeSettingValueType('bool'), 'BOOLEAN');
      expect(normalizeRuntimeSettingValueType('BOOLEAN'), 'BOOLEAN');
      expect(normalizeRuntimeSettingValueType('int'), 'INTEGER');
      expect(normalizeRuntimeSettingValueType('FLOAT'), 'FLOAT');
      expect(normalizeRuntimeSettingValueType('text'), 'STRING');
    });

    test('parseRuntimeSettingBool', () {
      expect(parseRuntimeSettingBool('true'), true);
      expect(parseRuntimeSettingBool('FALSE'), false);
      expect(parseRuntimeSettingBool('1'), true);
      expect(parseRuntimeSettingBool('0'), false);
    });
  });

  group('RuntimeSettingCard', () {
    Widget wrapWithL10n(Widget child) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(body: child),
      );
    }

    testWidgets('boolean type renders Switch and updates controller', (tester) async {
      final ctrl = TextEditingController(text: 'false');
      addTearDown(ctrl.dispose);
      final row = RuntimeSettingRow(
        key: 'BLOCKCHAIN_ALLOW_TEST_SIGNATURE',
        value: 'false',
        effectiveValue: 'false',
        valueSource: 'environment',
        type: 'BOOLEAN',
        category: ConfigCategory.CORE,
        name: 'Allow test',
        description: 'Desc',
        isReadOnly: false,
      );

      await tester.pumpWidget(
        wrapWithL10n(
          Builder(
            builder: (context) {
              return RuntimeSettingCard(
                row: row,
                controller: ctrl,
                l10n: AppLocalizations.of(context)!,
                onValueChanged: () {},
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Switch), findsOneWidget);
      expect(find.byType(TextField), findsNothing);

      await tester.tap(find.byType(Switch));
      await tester.pump();
      expect(ctrl.text, 'true');
    });

    testWidgets('string type renders TextField not Switch', (tester) async {
      final ctrl = TextEditingController(text: 'ETH');
      addTearDown(ctrl.dispose);
      final row = RuntimeSettingRow(
        key: 'BLOCKCHAIN_WITHDRAW_ETH_SYMBOL',
        value: 'ETH',
        effectiveValue: 'ETH',
        valueSource: 'environment',
        type: 'STRING',
        category: ConfigCategory.CORE,
        name: 'Symbol',
        description: 'Desc',
        isReadOnly: false,
      );

      await tester.pumpWidget(
        wrapWithL10n(
          Builder(
            builder: (context) {
              return RuntimeSettingCard(
                row: row,
                controller: ctrl,
                l10n: AppLocalizations.of(context)!,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Switch), findsNothing);
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
