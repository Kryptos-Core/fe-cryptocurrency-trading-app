import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/domain/entities/managed_wallet/managed_wallet.dart';
import 'package:crypto_trading_app/domain/entities/managed_wallet/managed_wallet_balance.dart';
import 'package:crypto_trading_app/domain/entities/managed_wallet/managed_wallet_transaction.dart';
import 'package:crypto_trading_app/domain/entities/managed_wallet/deposit_method.dart';
import 'package:crypto_trading_app/domain/repositories/managed_wallets_repository.dart';

class ManagedWalletsRepositoryImpl implements ManagedWalletsRepository {
  final Dio _dio;

  ManagedWalletsRepositoryImpl({required Dio dio}) : _dio = dio;

  @override
  Future<Either<Failure, ManagedWallet>> createWallet({
    required String chain,
    String? label,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.managedWallets,
        data: {
          'chain': chain,
          if (label != null && label.isNotEmpty) 'label': label,
        },
      );
      final data = _extractDataMap(response.data);
      return Right(_parseManagedWallet(data));
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ManagedWallet>>> listWallets() async {
    try {
      final response = await _dio.get(ApiConstants.managedWallets);
      final list = _extractDataList(response.data);
      return Right(list.map(_parseManagedWallet).toList());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ManagedWallet>>> getDepositDefaults() async {
    try {
      final response = await _dio.get(ApiConstants.managedWalletsDepositDefaults);
      final list = _extractDataList(response.data);
      return Right(list.map(_parseManagedWallet).toList());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ManagedWalletBalance>> getWalletDetail(String walletId) async {
    try {
      final response = await _dio.get(ApiConstants.managedWalletById(walletId));
      final data = _extractDataMap(response.data);
      return Right(
        ManagedWalletBalance(
          walletId: data['wallet_id']?.toString() ?? walletId,
          address: data['address']?.toString() ?? '',
          balance: data['balance']?.toString() ?? '0',
          symbol: data['symbol']?.toString() ?? 'TRX',
          fetchedAt: DateTime.now(),
        ),
      );
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ManagedWalletTransaction>>> getWalletTransactions(
    String walletId,
  ) async {
    try {
      final response = await _dio.get(
        ApiConstants.managedWalletTransactions(walletId),
      );
      final list = _extractDataList(response.data);
      return Right(list.map(_parseManagedWalletTransaction).toList());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> sendTrx({
    required String walletId,
    required String toAddress,
    required String amount,
  }) async {
    try {
      await _dio.post(
        ApiConstants.managedWalletSend(walletId),
        data: {'toAddress': toAddress, 'amount': amount},
      );
      return const Right(true);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ManagedWallet>> setDepositDefault(String walletId) async {
    try {
      final response = await _dio.patch(
        ApiConstants.managedWalletSetDefault(walletId),
      );
      final data = _extractDataMap(response.data);
      return Right(_parseManagedWallet(data));
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> setRecommendedChain(String chain) async {
    try {
      await _dio.patch(
        ApiConstants.managedWalletsRecommendedChain,
        data: {'chain': chain},
      );
      return Right(chain);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deactivateWallet(String walletId) async {
    try {
      await _dio.delete(ApiConstants.managedWalletById(walletId));
      return const Right(true);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DepositMethodsResponse>> getDepositMethods() async {
    try {
      final response = await _dio.get(ApiConstants.depositMethods);
      final data = _extractDataMap(response.data);
      final methodsList = data['methods'];
      final List<DepositMethod> methods = [];
      if (methodsList is List) {
        for (final m in methodsList) {
          if (m is Map<String, dynamic>) {
            methods.add(_parseDepositMethod(m));
          }
        }
      }
      return Right(
        DepositMethodsResponse(
          recommendedChain: data['recommended_chain']?.toString(),
          methods: methods,
        ),
      );
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  ManagedWallet _parseManagedWallet(Map<String, dynamic> json) {
    BlockchainNetwork chain;
    try {
      chain = BlockchainNetworkX.fromApiValue(json['chain']?.toString() ?? 'TRON_NILE');
    } catch (_) {
      chain = BlockchainNetwork.tronNile;
    }

    final isDefault = json['isDefaultDeposit'] ?? json['is_default_deposit'];
    final isActiveVal = json['isActive'] ?? json['is_active'];

    return ManagedWallet(
      walletId: (json['walletId'] ?? json['wallet_id'])?.toString() ?? '',
      userId: (json['userId'] ?? json['user_id'])?.toString() ?? '',
      chain: chain,
      address: json['address']?.toString() ?? '',
      label: json['label']?.toString(),
      isDefaultDeposit: isDefault == true || isDefault == 1,
      defaultSetAt: _tryParseDateTime(json['defaultSetAt'] ?? json['default_set_at']),
      isActive: isActiveVal != false && isActiveVal != 0,
      createdAt: _tryParseDateTime(json['createdAt'] ?? json['created_at']) ?? DateTime.now(),
      updatedAt: _tryParseDateTime(json['updatedAt'] ?? json['updated_at']) ?? DateTime.now(),
    );
  }

  ManagedWalletTransaction _parseManagedWalletTransaction(Map<String, dynamic> json) {
    return ManagedWalletTransaction(
      txId: json['txId']?.toString() ?? json['tx_id']?.toString() ?? '',
      txHash: json['txHash']?.toString() ?? json['tx_hash']?.toString(),
      fromAddress: json['fromAddress']?.toString() ?? json['from_address']?.toString() ?? '',
      toAddress: json['toAddress']?.toString() ?? json['to_address']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0',
      status: json['status']?.toString() ?? 'PENDING',
      createdAt: _tryParseDateTime(json['createdAt'] ?? json['created_at']) ?? DateTime.now(),
    );
  }

  DepositMethod _parseDepositMethod(Map<String, dynamic> json) {
    return DepositMethod(
      chain: json['chain']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      depositAddress: json['deposit_address']?.toString(),
      isRecommended: json['is_recommended'] == true,
      depositEnabled: json['deposit_enabled'] != false,
      minConfirmations: (json['min_confirmations'] as num?)?.toInt() ?? 12,
      estimatedTime: json['estimated_time']?.toString() ?? '~3 min',
    );
  }

  Map<String, dynamic> _extractDataMap(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final data = responseData['data'];
      if (data is Map<String, dynamic>) return data;
      return responseData;
    }
    return {};
  }

  List<Map<String, dynamic>> _extractDataList(dynamic responseData) {
    if (responseData is List) {
      return responseData.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (responseData is Map<String, dynamic>) {
      final data = responseData['data'];
      if (data is List) {
        return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      }
    }
    return const [];
  }

  DateTime? _tryParseDateTime(dynamic raw) {
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString());
  }

  Failure _mapDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;

    String message = 'Server error';
    if (responseData is Map<String, dynamic>) {
      message = responseData['message']?.toString() ?? message;
    } else if (e.message != null && e.message!.isNotEmpty) {
      message = e.message!;
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkFailure(message: message);
    }

    if (statusCode == 401 || statusCode == 403) return AuthenticationFailure(message: message);
    if (statusCode == 404) return NotFoundFailure(message: message);
    if (statusCode == 409) return ConflictFailure(message: message);
    if (statusCode == 400 || statusCode == 422) return ValidationFailure(message: message);

    return ServerFailure(message: message);
  }
}
