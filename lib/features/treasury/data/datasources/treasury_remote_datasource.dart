import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/utils/api_response_error_message.dart';
import 'package:crypto_trading_app/core/utils/json_dynamic_parse.dart';
import 'package:crypto_trading_app/core/network/dio_client.dart';
import 'package:crypto_trading_app/features/treasury/domain/entities/chain_picker_options_model.dart';
import 'package:crypto_trading_app/features/treasury/domain/entities/treasury_model.dart';
import 'package:crypto_trading_app/features/treasury/domain/repositories/treasury_repository.dart';
import 'package:dio/dio.dart';

class TreasuryRemoteDataSourceImpl implements TreasuryRepository {
  final DioClient dioClient;

  TreasuryRemoteDataSourceImpl({required this.dioClient});

  T _unwrap<T>(dynamic payload) {
    if (payload is Map<String, dynamic> && payload['data'] is T) {
      return payload['data'] as T;
    }
    if (payload is T) return payload;
    throw const FormatException('Unexpected API response format');
  }

  ServerException _dioServerError(DioException e, {required String defaultMessage}) {
    final raw = e.response?.data;
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      final msg = map['message'];
      final code = map['code'];
      return ServerException(
        message: backendErrorMessageOrDefault(msg, defaultMessage),
        statusCode: e.response?.statusCode,
        code: code is String && code.isNotEmpty ? code : null,
      );
    }
    return ServerException(
      message: defaultMessage,
      statusCode: e.response?.statusCode,
    );
  }

  @override
  Future<List<TreasuryWalletModel>> listWallets({String? chain, String? purpose}) async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.treasuryWallets,
        queryParameters: {
          if (chain != null && chain.isNotEmpty) 'chain': chain,
          if (purpose != null && purpose.isNotEmpty) 'purpose': purpose,
        },
      );
      final raw = _unwrap<List<dynamic>>(response.data);
      return raw
          .whereType<Map<String, dynamic>>()
          .map(TreasuryWalletModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw _dioServerError(e, defaultMessage: 'Failed to load treasury wallets');
    }
  }

  @override
  Future<TreasuryWalletModel> createWallet({
    required String chain,
    required String purpose,
    String? label,
  }) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.treasuryWallets,
        data: {
          'chain': chain,
          'purpose': purpose,
          if (label != null && label.trim().isNotEmpty) 'label': label.trim(),
        },
      );
      return TreasuryWalletModel.fromJson(_unwrap<Map<String, dynamic>>(response.data));
    } on DioException catch (e) {
      throw _dioServerError(e, defaultMessage: 'Failed to create treasury wallet');
    }
  }

  @override
  Future<TreasuryWalletModel> getWalletDetail(String walletId) async {
    try {
      final response = await dioClient.dio.get(ApiConstants.treasuryWalletById(walletId));
      return TreasuryWalletModel.fromJson(_unwrap<Map<String, dynamic>>(response.data));
    } on DioException catch (e) {
      throw _dioServerError(e, defaultMessage: 'Failed to load treasury wallet detail');
    }
  }

  @override
  Future<void> deleteTransactionWallet(String walletId) async {
    try {
      await dioClient.dio.delete(ApiConstants.treasuryWalletById(walletId));
    } on DioException catch (e) {
      throw _dioServerError(e, defaultMessage: 'Failed to delete treasury wallet');
    }
  }

  @override
  Future<List<TreasuryMainWalletModel>> listMainWallets(String chain) async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.treasuryMainWallets,
        queryParameters: {'chain': chain},
      );
      final raw = _unwrap<List<dynamic>>(response.data);
      return raw
          .whereType<Map<String, dynamic>>()
          .map(TreasuryMainWalletModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw _dioServerError(e, defaultMessage: 'Failed to load main wallets');
    }
  }

  @override
  Future<List<TreasuryMainWalletModel>> listPendingMainWallets() async {
    try {
      final response = await dioClient.dio.get(ApiConstants.treasuryMainWalletsPending);
      final raw = _unwrap<List<dynamic>>(response.data);
      return raw.whereType<Map<String, dynamic>>().map(TreasuryMainWalletModel.fromJson).toList();
    } on DioException catch (e) {
      throw _dioServerError(e, defaultMessage: 'Failed to load pending main wallets');
    }
  }

  @override
  Future<TreasuryMainWalletModel> importMainWallet({
    required String chain,
    required String label,
    required String privateKey,
    required String mfaCode,
  }) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.treasuryMainWallets,
        data: {
          'chain': chain,
          'label': label,
          'privateKey': privateKey,
          'mfaCode': mfaCode,
        },
      );
      return TreasuryMainWalletModel.fromJson(_unwrap<Map<String, dynamic>>(response.data));
    } on DioException catch (e) {
      throw _dioServerError(e, defaultMessage: 'Failed to import main wallet');
    }
  }

  @override
  Future<TreasuryMainWalletModel> approveMainWallet(String id) async {
    try {
      final response = await dioClient.dio.patch(ApiConstants.treasuryMainWalletApprove(id));
      return TreasuryMainWalletModel.fromJson(_unwrap<Map<String, dynamic>>(response.data));
    } on DioException catch (e) {
      throw _dioServerError(e, defaultMessage: 'Failed to approve main wallet');
    }
  }

  @override
  Future<TreasuryMainWalletModel> rejectMainWallet(String id) async {
    try {
      final response = await dioClient.dio.patch(ApiConstants.treasuryMainWalletReject(id));
      return TreasuryMainWalletModel.fromJson(_unwrap<Map<String, dynamic>>(response.data));
    } on DioException catch (e) {
      throw _dioServerError(e, defaultMessage: 'Failed to reject main wallet');
    }
  }

  @override
  Future<TreasuryMainWalletModel> setDefaultMainWallet(String id) async {
    try {
      final response = await dioClient.dio.patch(ApiConstants.treasuryMainWalletSetDefault(id));
      return TreasuryMainWalletModel.fromJson(_unwrap<Map<String, dynamic>>(response.data));
    } on DioException catch (e) {
      throw _dioServerError(e, defaultMessage: 'Failed to set default main wallet');
    }
  }

  @override
  Future<String> revealMainWalletPrivateKey({
    required String mainWalletId,
    required String mfaCode,
  }) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.treasuryMainWalletRevealPrivateKey(mainWalletId),
        data: {'mfaCode': mfaCode},
      );
      final map = _unwrap<Map<String, dynamic>>(response.data);
      final pk = map['privateKey'] as String?;
      if (pk == null || pk.isEmpty) {
        throw ServerException(message: 'Invalid reveal response');
      }
      return pk;
    } on DioException catch (e) {
      throw _dioServerError(e, defaultMessage: 'Failed to reveal private key');
    }
  }

  @override
  Future<TreasuryMainWalletModel> updateMainWallet({
    required String mainWalletId,
    String? label,
  }) async {
    try {
      final response = await dioClient.dio.patch(
        ApiConstants.treasuryMainWallet(mainWalletId),
        data: {'label': label},
      );
      return TreasuryMainWalletModel.fromJson(_unwrap<Map<String, dynamic>>(response.data));
    } on DioException catch (e) {
      throw _dioServerError(e, defaultMessage: 'Failed to update main wallet');
    }
  }

  @override
  Future<TreasuryMainWalletModel> requestMainWalletDeletion(String mainWalletId) async {
    try {
      final response = await dioClient.dio.patch(
        ApiConstants.treasuryMainWalletRequestDeletion(mainWalletId),
      );
      return TreasuryMainWalletModel.fromJson(_unwrap<Map<String, dynamic>>(response.data));
    } on DioException catch (e) {
      throw _dioServerError(e, defaultMessage: 'Failed to request main wallet deletion');
    }
  }

  @override
  Future<void> approveMainWalletDeletion(String mainWalletId) async {
    try {
      await dioClient.dio.patch(
        ApiConstants.treasuryMainWalletApproveDeletion(mainWalletId),
        data: const <String, dynamic>{},
      );
    } on DioException catch (e) {
      throw _dioServerError(e, defaultMessage: 'Failed to approve main wallet deletion');
    }
  }

  @override
  Future<TreasuryMainWalletModel> rejectMainWalletDeletion(String mainWalletId) async {
    try {
      final response = await dioClient.dio.patch(
        ApiConstants.treasuryMainWalletRejectDeletion(mainWalletId),
        data: const <String, dynamic>{},
      );
      return TreasuryMainWalletModel.fromJson(_unwrap<Map<String, dynamic>>(response.data));
    } on DioException catch (e) {
      throw _dioServerError(e, defaultMessage: 'Failed to reject main wallet deletion');
    }
  }

  @override
  Future<Map<String, dynamic>> sweepWallet(
    String walletId, {
    String? mainWalletId,
    String asset = 'NATIVE',
  }) async {
    try {
      final body = <String, dynamic>{'asset': asset};
      if (mainWalletId != null && mainWalletId.isNotEmpty) {
        body['mainWalletId'] = mainWalletId;
      }
      final response = await dioClient.dio.post(
        ApiConstants.treasuryWalletSweep(walletId),
        data: body,
      );
      return _unwrap<Map<String, dynamic>>(response.data);
    } on DioException catch (e) {
      throw _dioServerError(e, defaultMessage: 'Failed to enqueue sweep operation');
    }
  }

  @override
  Future<Map<String, dynamic>> fundWallet({
    required String walletId,
    required String amount,
    String asset = 'NATIVE',
  }) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.treasuryWalletFund(walletId),
        data: {'amount': amount, 'asset': asset},
      );
      return _unwrap<Map<String, dynamic>>(response.data);
    } on DioException catch (e) {
      throw _dioServerError(e, defaultMessage: 'Failed to enqueue fund operation');
    }
  }

  @override
  Future<TreasuryPageResult<TreasuryOperationModel>> listOperations({
    String? chain,
    String? type,
    String? status,
    String? q,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.treasuryOperations,
        queryParameters: {
          if (chain != null && chain.isNotEmpty) 'chain': chain,
          if (type != null && type.isNotEmpty) 'type': type,
          if (status != null && status.isNotEmpty) 'status': status,
          if (q != null && q.isNotEmpty) 'q': q,
          'page': page,
          'limit': limit,
        },
      );

      final data = _unwrap<Map<String, dynamic>>(response.data);
      final rawItems = (data['items'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();

      return TreasuryPageResult<TreasuryOperationModel>(
        items: rawItems.map(TreasuryOperationModel.fromJson).toList(),
        total: parseJsonInt(data['total'], rawItems.length),
        page: parseJsonInt(data['page'], page),
        limit: parseJsonInt(data['limit'], limit),
      );
    } on DioException catch (e) {
      throw _dioServerError(e, defaultMessage: 'Failed to load treasury operations');
    }
  }

  @override
  Future<TreasuryPageResult<TreasuryTransactionModel>> listTransactions({
    String? chain,
    String? type,
    String? status,
    String? q,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.treasuryTransactions,
        queryParameters: {
          if (chain != null && chain.isNotEmpty) 'chain': chain,
          if (type != null && type.isNotEmpty) 'type': type,
          if (status != null && status.isNotEmpty) 'status': status,
          if (q != null && q.isNotEmpty) 'q': q,
          'page': page,
          'limit': limit,
        },
      );

      final data = _unwrap<Map<String, dynamic>>(response.data);
      final rawItems = (data['items'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();

      return TreasuryPageResult<TreasuryTransactionModel>(
        items: rawItems.map(TreasuryTransactionModel.fromJson).toList(),
        total: parseJsonInt(data['total'], rawItems.length),
        page: parseJsonInt(data['page'], page),
        limit: parseJsonInt(data['limit'], limit),
      );
    } on DioException catch (e) {
      throw _dioServerError(e, defaultMessage: 'Failed to load treasury transactions');
    }
  }

  @override
  Future<Map<String, dynamic>> manualRetryTreasuryOperation(
    String operationId, {
    String? mainWalletId,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (mainWalletId != null && mainWalletId.trim().isNotEmpty) {
        body['mainWalletId'] = mainWalletId.trim();
      }
      final response = await dioClient.dio.post(
        ApiConstants.treasuryOperationManualRetry(operationId),
        data: body,
      );
      return _unwrap<Map<String, dynamic>>(response.data);
    } on DioException catch (e) {
      throw _dioServerError(e, defaultMessage: 'Manual retry failed');
    }
  }

  @override
  Future<Map<String, dynamic>> manualAbortTreasuryOperation(
    String operationId, {
    String? reason,
  }) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.treasuryOperationManualAbort(operationId),
        data: {
          if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
        },
      );
      return _unwrap<Map<String, dynamic>>(response.data);
    } on DioException catch (e) {
      throw _dioServerError(e, defaultMessage: 'Manual abort failed');
    }
  }

  @override
  Future<Map<String, dynamic>> manualSettleTreasuryOperation(
    String operationId, {
    required String txHash,
    String? mainWalletId,
  }) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.treasuryOperationManualSettle(operationId),
        data: {
          'txHash': txHash.trim(),
          if (mainWalletId != null && mainWalletId.trim().isNotEmpty)
            'mainWalletId': mainWalletId.trim(),
        },
      );
      return _unwrap<Map<String, dynamic>>(response.data);
    } on DioException catch (e) {
      throw _dioServerError(e, defaultMessage: 'Manual settle failed');
    }
  }

  @override
  Future<ChainPickerOptionsModel> getChainPickerOptions() async {
    try {
      final response = await dioClient.dio.get(ApiConstants.treasuryChainPickerOptions);
      return ChainPickerOptionsModel.fromJson(
        _unwrap<Map<String, dynamic>>(response.data),
      );
    } on DioException catch (e) {
      throw _dioServerError(e, defaultMessage: 'Failed to load chain picker options');
    }
  }
}
