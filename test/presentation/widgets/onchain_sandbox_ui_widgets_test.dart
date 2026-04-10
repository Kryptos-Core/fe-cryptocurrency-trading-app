import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/widgets/onchain_network_dropdown_menu_child.dart';
import 'package:crypto_trading_app/presentation/widgets/onchain_sandbox_operator_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const enBannerFull =
      'On-chain deployment is in Sandbox mode. Use test networks only — not real mainnet funds.';

  Widget appWithBanner(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: Builder(
          builder: (context) => child,
        ),
      ),
    );
  }

  group('OnchainSandboxOperatorBanner', () {
    tearDown(() {
      dotenv.clean();
    });

    testWidgets('shows full banner when ONCHAIN_OPERATOR_MODE is sandbox',
        (tester) async {
      dotenv.loadFromString(envString: 'ONCHAIN_OPERATOR_MODE=sandbox');
      await tester.pumpWidget(
        appWithBanner(
          Builder(
            builder: (context) {
              return OnchainSandboxOperatorBanner(
                l10n: AppLocalizations.of(context)!,
              );
            },
          ),
        ),
      );
      await tester.pump();
      expect(find.text(enBannerFull), findsOneWidget);
      expect(find.byIcon(Icons.science_outlined), findsOneWidget);
    });

    testWidgets('shows nothing when production', (tester) async {
      dotenv.loadFromString(envString: 'ONCHAIN_OPERATOR_MODE=production');
      await tester.pumpWidget(
        appWithBanner(
          Builder(
            builder: (context) {
              return OnchainSandboxOperatorBanner(
                l10n: AppLocalizations.of(context)!,
              );
            },
          ),
        ),
      );
      await tester.pump();
      expect(find.text(enBannerFull), findsNothing);
    });

    testWidgets('shows nothing when env key missing', (tester) async {
      dotenv.loadFromString(envString: 'OTHER=1');
      await tester.pumpWidget(
        appWithBanner(
          Builder(
            builder: (context) {
              return OnchainSandboxOperatorBanner(
                l10n: AppLocalizations.of(context)!,
              );
            },
          ),
        ),
      );
      await tester.pump();
      expect(find.text(enBannerFull), findsNothing);
    });
  });

  group('OnchainNetworkDropdownMenuChild', () {
    testWidgets('appends Sandbox label for sandbox chains', (tester) async {
      await tester.pumpWidget(
        appWithBanner(
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return OnchainNetworkDropdownMenuChild(
                network: BlockchainNetwork.bscChapel,
                l10n: l10n,
              );
            },
          ),
        ),
      );
      expect(find.text('BSC (Chapel)'), findsOneWidget);
      expect(find.text('Sandbox'), findsOneWidget);
    });

    testWidgets('no Sandbox label for mainnet', (tester) async {
      await tester.pumpWidget(
        appWithBanner(
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return OnchainNetworkDropdownMenuChild(
                network: BlockchainNetwork.ethMainnet,
                l10n: l10n,
              );
            },
          ),
        ),
      );
      expect(find.text('Ethereum (mainnet)'), findsOneWidget);
      expect(find.text('Sandbox'), findsNothing);
    });

    testWidgets('suppressSandboxSuffix hides testnet Sandbox tag', (tester) async {
      await tester.pumpWidget(
        appWithBanner(
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return OnchainNetworkDropdownMenuChild(
                network: BlockchainNetwork.bscChapel,
                l10n: l10n,
                suppressSandboxSuffix: true,
              );
            },
          ),
        ),
      );
      expect(find.text('BSC (Chapel)'), findsOneWidget);
      expect(find.text('Sandbox'), findsNothing);
    });
  });
}
