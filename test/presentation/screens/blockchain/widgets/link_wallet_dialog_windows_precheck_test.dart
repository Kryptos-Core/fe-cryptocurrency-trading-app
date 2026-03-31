import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_dtos.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/linked_wallet.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/onchain_transaction.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/wc_link_session_poll_result.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/wc_session_proposal.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/wc_session_status.dart';
import 'package:crypto_trading_app/domain/repositories/blockchain_repository.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/blockchain_provider.dart';
import 'package:crypto_trading_app/presentation/screens/blockchain/widgets/link_wallet_dialog.dart';

/// Fake repository để test UI — tất cả WC methods trả về stub hợp lệ
class _FakeBlockchainRepository implements BlockchainRepository {
  const _FakeBlockchainRepository();

  @override
  Future<Either<Failure, WcSessionProposal>> initWcSession(
    BlockchainNetwork chain,
  ) async {
    return Right(WcSessionProposal(
      sessionId: 'test-session-id',
      wcUri: 'wc:abc123@2?relay-protocol=irn&symKey=xyz',
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      chain: chain,
      caip2Chain: 'eip155:11155111',
    ));
  }

  @override
  Future<Either<Failure, WcLinkSessionPollResult>> getWcSessionStatus(
    String sessionId,
  ) async {
    return const Right(
      WcLinkSessionPollResult(status: WcSessionStatus.pending),
    );
  }

  @override
  Future<Either<Failure, VerifyLinkResponse>> submitWcSignature({
    required String sessionId,
    required String address,
    required String signature,
    required BlockchainNetwork chain,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, RequestLinkResponse>> requestLink({
    required BlockchainNetwork chain,
    required String address,
    String? label,
  }) async {
    throw UnimplementedError();
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

  group('LinkWalletDialog — WalletConnect QR Flow', () {
    testWidgets(
        'hiển thị QR code session sau khi nhấn nút kết nối ví',
        (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // Dialog mở, hiển thị nút "Kết nối ví" hoặc cở chọn network
      expect(find.byType(LinkWalletDialog), findsOneWidget);
    });

    testWidgets(
        'không có Windows extension precheck nào trong WC flow',
        (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // Windows precheck card đã bị xoá — không còn tồn tại
      expect(find.text('Check extension in browser'), findsNothing);
      expect(
        find.text(
            'Windows pre-check: confirm extension is installed before signing.'),
        findsNothing,
      );
    },
        variant: const TargetPlatformVariant(
            <TargetPlatform>{TargetPlatform.windows}));
  });
}
