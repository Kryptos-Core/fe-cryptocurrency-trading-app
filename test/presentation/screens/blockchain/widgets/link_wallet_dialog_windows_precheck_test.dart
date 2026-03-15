import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart';
import 'package:crypto_trading_app/core/services/wallet_signing/wallet_extension_precheck_service.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_dtos.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/linked_wallet.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/onchain_transaction.dart';
import 'package:crypto_trading_app/domain/repositories/blockchain_repository.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/blockchain_provider.dart';
import 'package:crypto_trading_app/presentation/screens/blockchain/widgets/link_wallet_dialog.dart';

class _FakeBlockchainRepository implements BlockchainRepository {
  const _FakeBlockchainRepository();

  @override
  Future<Either<Failure, RequestLinkResponse>> requestLink({
    required BlockchainNetwork chain,
    required String address,
    String? label,
  }) async {
    return const Right(
      RequestLinkResponse(
        message: 'challenge-for-test',
        expiresIn: 300,
      ),
    );
  }

  @override
  Future<Either<Failure, DepositAddressResponse>> getDepositAddress(
      BlockchainNetwork chain) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, DepositPreviewResponse>> previewDeposit(
    BlockchainNetwork chain,
    String txHash,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, VerifyLinkResponse>> verifyLink({
    required BlockchainNetwork chain,
    required String address,
    required String signature,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<LinkedWallet>>> getLinkedWallets() async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, LinkedWalletBalance>> getLinkedWalletBalance(
      String linkId) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> unlinkWallet(String linkId) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, OnchainTransaction>> submitDeposit(
    SubmitDepositRequest request,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, OnchainTransaction>> requestWithdrawal(
    RequestWithdrawalRequest request,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<OnchainTransaction>>> getTransactions({
    int limit = 50,
  }) async {
    throw UnimplementedError();
  }
}

Widget _buildTestApp() {
  final provider = BlockchainProvider(
    blockchainRepository: const _FakeBlockchainRepository(),
  );

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<BlockchainProvider>.value(value: provider),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: LinkWalletDialog(),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LinkWalletDialog Windows precheck', () {
    setUp(() async {
      await sl.reset();
      sl.registerLazySingleton<WalletExtensionPrecheckService>(
        () => WalletExtensionPrecheckService(
          openExternalUrl: (_) async => true,
        ),
      );
    });

    tearDown(() async {
      await sl.reset();
    });

    testWidgets(
        'shows windows precheck block for ETH after requesting challenge',
        (tester) async {
      await tester.pumpWidget(_buildTestApp());

      await tester.enterText(
        find.byType(TextFormField).first,
        '0xabc123',
      );

      await tester.tap(find.text('1) Request Challenge'));
      await tester.pumpAndSettle();

      expect(
        find.text(
            'Windows pre-check: confirm extension is installed before signing.'),
        findsOneWidget,
      );
      expect(find.text('Check extension in browser'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
    },
        variant: const TargetPlatformVariant(
            <TargetPlatform>{TargetPlatform.windows}));

    testWidgets('hides windows precheck block in test mode', (tester) async {
      await tester.pumpWidget(_buildTestApp());

      await tester
          .tap(find.text('Enable test mode (manual signature fallback)'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).first,
        '0xabc123',
      );

      await tester.tap(find.text('1) Request Challenge'));
      await tester.pumpAndSettle();

      expect(
        find.text(
            'Windows pre-check: confirm extension is installed before signing.'),
        findsNothing,
      );
      expect(find.text('Check extension in browser'), findsNothing);
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
    },
        variant: const TargetPlatformVariant(
            <TargetPlatform>{TargetPlatform.windows}));
  });
}
