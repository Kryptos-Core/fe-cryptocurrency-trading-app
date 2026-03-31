import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/network/dio_client.dart';
import 'package:crypto_trading_app/data/models/treasury_model.dart';
import 'package:dio/dio.dart';

abstract class TreasuryRemoteDataSource {
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

  Future<Map<String, dynamic>> sweepWallet(String walletId, {String? mainWalletId});

  Future<Map<String, dynamic>> fundWallet({
    required String walletId,
    required String amount,
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
}

class TreasuryRemoteDataSourceImpl implements TreasuryRemoteDataSource {
  final DioClient dioClient;

  TreasuryRemoteDataSourceImpl({required this.dioClient});

  T _unwrap<T>(dynamic payload) {
    if (payload is Map<String, dynamic> && payload['data'] is T) {
      return payload['data'] as T;
    }
    if (payload is T) return payload;
    throw const FormatException('Unexpected API response format');
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
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to load treasury wallets',
      );
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
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to create treasury wallet',
      );
    }
  }

  @override
  Future<TreasuryWalletModel> getWalletDetail(String walletId) async {
    try {
      final response = await dioClient.dio.get(ApiConstants.treasuryWalletById(walletId));
      return TreasuryWalletModel.fromJson(_unwrap<Map<String, dynamic>>(response.data));
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to load treasury wallet detail',
      );
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
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to load main wallets',
      );
    }
  }

  @override
  Future<List<TreasuryMainWalletModel>> listPendingMainWallets() async {
    try {
      final response = await dioClient.dio.get(ApiConstants.treasuryMainWalletsPending);
      final raw = _unwrap<List<dynamic>>(response.data);
      return raw.whereType<Map<String, dynamic>>().map(TreasuryMainWalletModel.fromJson).toList();
    } on DioException catch (e) {
      throw ServerException(message: e.response?.data?['message'] ?? 'Failed to load pending main wallets');
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
      throw ServerException(message: e.response?.data?['message'] ?? 'Failed to import main wallet');
    }
  }

  @override
  Future<TreasuryMainWalletModel> approveMainWallet(String id) async {
    try {
      final response = await dioClient.dio.patch(ApiConstants.treasuryMainWalletApprove(id));
      return TreasuryMainWalletModel.fromJson(_unwrap<Map<String, dynamic>>(response.data));
    } on DioException catch (e) {
      throw ServerException(message: e.response?.data?['message'] ?? 'Failed to approve main wallet');
    }
  }

  @override
  Future<TreasuryMainWalletModel> rejectMainWallet(String id) async {
    try {
      final response = await dioClient.dio.patch(ApiConstants.treasuryMainWalletReject(id));
      return TreasuryMainWalletModel.fromJson(_unwrap<Map<String, dynamic>>(response.data));
    } on DioException catch (e) {
      throw ServerException(message: e.response?.data?['message'] ?? 'Failed to reject main wallet');
    }
  }

  @override
  Future<TreasuryMainWalletModel> setDefaultMainWallet(String id) async {
    try {
      final response = await dioClient.dio.patch(ApiConstants.treasuryMainWalletSetDefault(id));
      return TreasuryMainWalletModel.fromJson(_unwrap<Map<String, dynamic>>(response.data));
    } on DioException catch (e) {
      throw ServerException(message: e.response?.data?['message'] ?? 'Failed to set default main wallet');
    }
  }

  @override
  Future<Map<String, dynamic>> sweepWallet(String walletId, {String? mainWalletId}) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.treasuryWalletSweep(walletId),
        data: mainWalletId != null ? {'mainWalletId': mainWalletId} : null,
      );
      return _unwrap<Map<String, dynamic>>(response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to enqueue sweep operation',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> fundWallet({
    required String walletId,
    required String amount,
  }) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.treasuryWalletFund(walletId),
        data: {'amount': amount},
      );
      return _unwrap<Map<String, dynamic>>(response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to enqueue fund operation',
      );
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
        total: (data['total'] as num?)?.toInt() ?? rawItems.length,
        page: (data['page'] as num?)?.toInt() ?? page,
        limit: (data['limit'] as num?)?.toInt() ?? limit,
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to load treasury operations',
      );
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
        total: (data['total'] as num?)?.toInt() ?? rawItems.length,
        page: (data['page'] as num?)?.toInt() ?? page,
        limit: (data['limit'] as num?)?.toInt() ?? limit,
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to load treasury transactions',
      );
    }
  }
}
