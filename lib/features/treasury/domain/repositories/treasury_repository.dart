import 'package:crypto_trading_app/features/treasury/domain/entities/chain_picker_options_model.dart';
import 'package:crypto_trading_app/features/treasury/domain/entities/treasury_model.dart';

/// Treasury + main wallet + onchain operations (API v1).
abstract class TreasuryRepository {
  Future<List<TreasuryWalletModel>> listWallets({
    String? chain,
    String? purpose,
  });

  Future<TreasuryWalletModel> createWallet({
    required String chain,
    required String purpose,
    String? label,
  });

  Future<TreasuryWalletModel> getWalletDetail(String walletId);

  Future<void> deleteTransactionWallet(String walletId);

  Future<List<TreasuryMainWalletModel>> listMainWallets(String chain);

  Future<List<TreasuryMainWalletModel>> listPendingMainWallets();

  Future<TreasuryMainWalletModel> importMainWallet({
    required String chain,
    required String label,
    required String privateKey,
    required String mfaCode,
  });

  Future<TreasuryMainWalletModel> approveMainWallet(String id);
  Future<TreasuryMainWalletModel> rejectMainWallet(String id);
  Future<TreasuryMainWalletModel> setDefaultMainWallet(String id);

  Future<String> revealMainWalletPrivateKey({
    required String mainWalletId,
    required String mfaCode,
  });

  Future<TreasuryMainWalletModel> updateMainWallet({
    required String mainWalletId,
    String? label,
  });

  Future<TreasuryMainWalletModel> requestMainWalletDeletion(String mainWalletId);

  Future<void> approveMainWalletDeletion(String mainWalletId);

  Future<TreasuryMainWalletModel> rejectMainWalletDeletion(String mainWalletId);

  Future<Map<String, dynamic>> sweepWallet(
    String walletId, {
    String? mainWalletId,
    String asset = 'NATIVE',
  });

  Future<Map<String, dynamic>> fundWallet({
    required String walletId,
    required String amount,
    String asset = 'NATIVE',
  });

  Future<TreasuryPageResult<TreasuryOperationModel>> listOperations({
    String? chain,
    String? type,
    String? status,
    String? q,
    int page = 1,
    int limit = 20,
  });

  Future<TreasuryPageResult<TreasuryTransactionModel>> listTransactions({
    String? chain,
    String? type,
    String? status,
    String? q,
    int page = 1,
    int limit = 20,
  });

  Future<ChainPickerOptionsModel> getChainPickerOptions();
}
