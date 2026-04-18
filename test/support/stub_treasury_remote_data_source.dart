import 'package:crypto_trading_app/features/treasury/domain/repositories/treasury_repository.dart';
import 'package:crypto_trading_app/features/treasury/domain/entities/chain_picker_options_model.dart';
import 'package:crypto_trading_app/features/treasury/domain/entities/treasury_model.dart';

/// Test stub: only [getChainPickerOptions] is real; everything else throws.
class StubTreasuryRepository implements TreasuryRepository {
  StubTreasuryRepository({
    required this.chainPickerJson,
    this.chainPickerError,
  });

  final Map<String, dynamic> chainPickerJson;
  final Object? chainPickerError;

  @override
  Future<ChainPickerOptionsModel> getChainPickerOptions() async {
    final err = chainPickerError;
    if (err != null) throw err;
    return ChainPickerOptionsModel.fromJson(chainPickerJson);
  }

  Never _u() => throw UnimplementedError();

  @override
  Future<void> approveMainWalletDeletion(String mainWalletId) async => _u();

  @override
  Future<TreasuryMainWalletModel> approveMainWallet(String id) async => _u();

  @override
  Future<TreasuryWalletModel> createWallet({
    required String chain,
    required String purpose,
    String? label,
  }) async =>
      _u();

  @override
  Future<void> deleteTransactionWallet(String walletId) async => _u();

  @override
  Future<Map<String, dynamic>> fundWallet({
    required String walletId,
    required String amount,
    String asset = 'NATIVE',
  }) async =>
      _u();

  @override
  Future<TreasuryWalletModel> getWalletDetail(String walletId) async => _u();

  @override
  Future<TreasuryMainWalletModel> importMainWallet({
    required String chain,
    required String label,
    required String privateKey,
    required String mfaCode,
  }) async =>
      _u();

  @override
  Future<List<TreasuryMainWalletModel>> listMainWallets(String chain) async => _u();

  @override
  Future<TreasuryPageResult<TreasuryOperationModel>> listOperations({
    String? chain,
    String? type,
    String? status,
    String? q,
    int page = 1,
    int limit = 20,
  }) async =>
      _u();

  @override
  Future<List<TreasuryMainWalletModel>> listPendingMainWallets() async => _u();

  @override
  Future<TreasuryPageResult<TreasuryTransactionModel>> listTransactions({
    String? chain,
    String? type,
    String? status,
    String? q,
    int page = 1,
    int limit = 20,
  }) async =>
      _u();

  @override
  Future<List<TreasuryWalletModel>> listWallets({
    String? chain,
    String? purpose,
  }) async =>
      _u();

  @override
  Future<TreasuryMainWalletModel> rejectMainWallet(String id) async => _u();

  @override
  Future<TreasuryMainWalletModel> rejectMainWalletDeletion(String mainWalletId) async => _u();

  @override
  Future<String> revealMainWalletPrivateKey({
    required String mainWalletId,
    required String mfaCode,
  }) async =>
      _u();

  @override
  Future<TreasuryMainWalletModel> requestMainWalletDeletion(String mainWalletId) async => _u();

  @override
  Future<TreasuryMainWalletModel> setDefaultMainWallet(String id) async => _u();

  @override
  Future<Map<String, dynamic>> sweepWallet(
    String walletId, {
    String? mainWalletId,
    String asset = 'NATIVE',
  }) async =>
      _u();

  @override
  Future<TreasuryMainWalletModel> updateMainWallet({
    required String mainWalletId,
    String? label,
  }) async =>
      _u();
}
