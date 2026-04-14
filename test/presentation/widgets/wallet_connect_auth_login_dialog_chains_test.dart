import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/onchain_chain_picker_provider.dart';
import 'package:crypto_trading_app/features/auth/presentation/widgets/wallet_connect_auth_login_dialog.dart';

import '../../support/stub_treasury_remote_data_source.dart';

/// Đăng nhập WC (legacy QR) phải dùng cùng tập EVM+Solana như liên kết ví (chain-picker API),
/// không dùng danh sách hardcode; Tron chỉ qua extension — không có chip Tron trong Wrap QR.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WalletConnectAuthLoginDialog — chain list', () {
    testWidgets(
      'hiển thị chip Ethereum (Sepolia) khi BE onchain_deposit_withdraw có ETH_SEPOLIA',
      (tester) async {
        // Tránh init Reown AppKit (chỉ Android/iOS); desktop dùng luồng legacy QR trực tiếp.
        debugDefaultTargetPlatformOverride = TargetPlatform.windows;
        try {
          SharedPreferences.setMockInitialValues({});
          final prefs = await SharedPreferences.getInstance();
          final chainPicker = OnchainChainPickerProvider(
            dataSource: StubTreasuryRemoteDataSource(
              chainPickerJson: {
                'operatorMode': 'sandbox',
                'tronDefaultNetwork': 'TRON_NILE',
                'pickers': {
                  'onchain_deposit_withdraw': [
                    'BSC_CHAPEL',
                    'ETH_SEPOLIA',
                    'BASE_SEPOLIA',
                    'SOLANA_DEVNET',
                    'TRON_NILE',
                  ],
                },
              },
            ),
            prefs: prefs,
          );
          await chainPicker.ensureLoaded();

          await tester.pumpWidget(
            ChangeNotifierProvider<OnchainChainPickerProvider>.value(
              value: chainPicker,
              child: const MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: Locale('en'),
                home: Scaffold(
                  body: Center(
                    child: WalletConnectAuthLoginDialog(),
                  ),
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();

          expect(
            find.textContaining('Ethereum (Sepolia)'),
            findsWidgets,
          );
          expect(find.textContaining('Base (Sepolia)'), findsWidgets);
          expect(find.textContaining('Tron'), findsNothing);
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      },
    );
  });
}

