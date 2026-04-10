import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_dtos.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/linked_wallet.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/linked_wallet_status.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/onchain_transaction.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/onchain_tx_status.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/wc_link_session_poll_result.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/wc_session_proposal.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/wc_session_status.dart';
import 'package:crypto_trading_app/domain/repositories/blockchain_repository.dart';

class BlockchainRepositoryImpl implements BlockchainRepository {
  final Dio _dio;

  BlockchainRepositoryImpl({required Dio dio}) : _dio = dio;

  @override
  Future<Either<Failure, DepositAddressResponse>> getDepositAddress(
    BlockchainNetwork chain,
  ) async {
    try {
      final response = await _dio.get(
        ApiConstants.blockchainDepositAddress,
        queryParameters: {'chain': chain.apiValue},
      );

      final data = _extractDataMap(response.data);
      return Right(
        DepositAddressResponse(
          chain: BlockchainNetworkX.fromApiValue(
            data['chain']?.toString() ?? chain.apiValue,
          ),
          depositAddress: data['depositAddress']?.toString() ?? '',
          note: data['note']?.toString(),
        ),
      );
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DepositPreviewResponse>> previewDeposit(
    BlockchainNetwork chain,
    String txHash,
  ) async {
    try {
      final response = await _dio.get(
        ApiConstants.blockchainPreviewDeposit,
        queryParameters: {
          'chain': chain.apiValue,
          'txHash': txHash,
        },
      );

      final data = _extractDataMap(response.data);
      return Right(
        DepositPreviewResponse(
          chain: BlockchainNetworkX.fromApiValue(
            data['chain']?.toString() ?? chain.apiValue,
          ),
          txHash: data['txHash']?.toString() ?? txHash,
          status: data['status']?.toString() ?? 'PENDING',
          confirmations: (data['confirmations'] as num?)?.toInt() ?? 0,
          fromAddress: data['fromAddress']?.toString() ?? '',
          toAddress: data['toAddress']?.toString() ?? '',
          onchainAmount: data['onchainAmount']?.toString() ?? '0',
          senderLinked: data['senderLinked'] == true,
        ),
      );
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RequestLinkResponse>> requestLink({
    required BlockchainNetwork chain,
    required String address,
    String? label,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.blockchainRequestLink,
        data: {
          'chain': chain.apiValue,
          'address': address,
          if (label != null && label.isNotEmpty) 'label': label,
        },
      );

      final data = _extractDataMap(response.data);
      return Right(
        RequestLinkResponse(
          message: data['message']?.toString() ?? '',
          expiresIn: (data['expiresIn'] as num?)?.toInt() ?? 0,
        ),
      );
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VerifyLinkResponse>> verifyLink({
    required BlockchainNetwork chain,
    required String address,
    required String signature,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.blockchainVerifyLink,
        data: {
          'chain': chain.apiValue,
          'address': address,
          'signature': signature,
        },
      );

      final data = _extractDataMap(response.data);
      return Right(
        VerifyLinkResponse(
          linkId: data['linkId']?.toString() ?? '',
          chain: BlockchainNetworkX.fromApiValue(
            data['chain']?.toString() ?? chain.apiValue,
          ),
          address: data['address']?.toString() ?? address,
          status: data['status']?.toString() ?? 'VERIFIED',
        ),
      );
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LinkedWallet>>> getLinkedWallets() async {
    try {
      final response = await _dio.get(ApiConstants.blockchainWallets);
      final list = _extractDataList(response.data);
      final wallets = list.map(_parseLinkedWallet).toList();
      return Right(wallets);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LinkedWalletBalance>> getLinkedWalletBalance(
    String linkId,
  ) async {
    try {
      final response = await _dio.get(ApiConstants.blockchainWalletBalance(linkId));
      final data = _extractDataMap(response.data);

      final chain = BlockchainNetworkX.fromApiValue(
        data['chain']?.toString() ?? 'BSC_CHAPEL',
      );

      return Right(
        LinkedWalletBalance(
          linkId: data['linkId']?.toString() ?? linkId,
          chain: chain,
          address: data['address']?.toString() ?? '',
          balance: data['balance']?.toString() ?? '0',
        ),
      );
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> unlinkWallet(String linkId) async {
    try {
      await _dio.delete(ApiConstants.blockchainUnlinkWallet(linkId));
      return const Right(true);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OnchainTransaction>> submitDeposit(
    SubmitDepositRequest request,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.blockchainSubmitDeposit,
        data: request.toJson(),
      );
      final data = _extractDataMap(response.data);
      return Right(_parseOnchainTransaction(data));
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OnchainTransaction>> requestWithdrawal(
    RequestWithdrawalRequest request,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.blockchainRequestWithdrawal,
        data: request.toJson(),
      );
      final data = _extractDataMap(response.data);
      return Right(_parseOnchainTransaction(data));
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OnchainTransaction>>> getTransactions({
    int limit = 50,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.blockchainTransactions,
        queryParameters: {'limit': limit},
      );
      final list = _extractDataList(response.data);
      return Right(list.map(_parseOnchainTransaction).toList());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ============ WalletConnect v2 ============

  @override
  Future<Either<Failure, WcSessionProposal>> initWcSession(
    BlockchainNetwork chain,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.blockchainWcInit,
        data: {'chain': chain.apiValue},
      );
      final data = _extractDataMap(response.data);
      return Right(WcSessionProposal.fromJson({
        ...data,
        'chain': chain.apiValue,
      }));
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, WcLinkSessionPollResult>> getWcSessionStatus(
    String sessionId,
  ) async {
    try {
      final response = await _dio.get(
        ApiConstants.blockchainWcStatus(sessionId),
      );
      final data = _extractDataMap(response.data);
      final statusStr = data['status']?.toString() ?? 'pending';
      return Right(
        WcLinkSessionPollResult(
          status: WcSessionStatusX.fromApiValue(statusStr),
          address: data['address']?.toString(),
          signature: data['signature']?.toString(),
        ),
      );
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VerifyLinkResponse>> submitWcSignature({
    required String sessionId,
    required String address,
    required String signature,
    required BlockchainNetwork chain,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.blockchainWcSubmit,
        data: {
          'sessionId': sessionId,
          'address': address,
          'signature': signature,
          'chain': chain.apiValue,
        },
      );
      final data = _extractDataMap(response.data);
      return Right(
        VerifyLinkResponse(
          linkId: data['linkId']?.toString() ?? '',
          chain: BlockchainNetworkX.fromApiValue(
            data['chain']?.toString() ?? chain.apiValue,
          ),
          address: data['address']?.toString() ?? address,
          status: data['status']?.toString() ?? 'VERIFIED',
        ),
      );
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  LinkedWallet _parseLinkedWallet(Map<String, dynamic> json) {
    return LinkedWallet(
      linkId: json['linkId']?.toString() ?? '',
      chain: BlockchainNetworkX.fromApiValue(
        json['chain']?.toString() ?? 'BSC_CHAPEL',
      ),
      address: json['address']?.toString() ?? '',
      label: json['label']?.toString(),
      status: LinkedWalletStatusX.fromApiValue(
        json['status']?.toString() ?? 'PENDING',
      ),
      linkedAt: _tryParseDateTime(json['linkedAt']),
    );
  }

  OnchainTransaction _parseOnchainTransaction(Map<String, dynamic> json) {
    final chain = BlockchainNetworkX.fromApiValue(
      json['chain']?.toString() ?? 'BSC_CHAPEL',
    );
    final status = OnchainTxStatusX.fromApiValue(
      json['status']?.toString() ?? 'PENDING',
    );

    return OnchainTransaction(
      txId: json['txId']?.toString() ?? '',
      chain: chain,
      type: OnchainTxTypeX.fromApiValue(
        json['type']?.toString() ?? 'TRANSFER',
      ),
      txHash: json['txHash']?.toString(),
      fromAddress: json['fromAddress']?.toString() ?? '',
      toAddress: json['toAddress']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0',
      status: status,
      confirmations: (json['confirmations'] as num?)?.toInt() ?? 0,
      createdAt:
          _tryParseDateTime(json['createdAt']) ?? DateTime.now().toUtc(),
      confirmedAt: _tryParseDateTime(json['confirmedAt']),
      creditedAmount: json['creditedAmount']?.toString(),
      creditedCurrencyId: json['creditedCurrencyId']?.toString(),
      conversionRate: json['conversionRate']?.toString(),
    );
  }

  Map<String, dynamic> _extractDataMap(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final data = responseData['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return responseData;
    }
    return {};
  }

  List<Map<String, dynamic>> _extractDataList(dynamic responseData) {
    if (responseData is List) {
      return responseData
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    if (responseData is Map<String, dynamic>) {
      final data = responseData['data'];
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
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
    String? apiCode;
    if (responseData is Map<String, dynamic>) {
      message = responseData['message']?.toString() ?? message;
      apiCode = responseData['code']?.toString();
    } else if (e.message != null && e.message!.isNotEmpty) {
      message = e.message!;
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkFailure(message: message);
    }

    if (statusCode == 401 || statusCode == 403) {
      return AuthenticationFailure(message: message);
    }
    if (statusCode == 404) {
      return NotFoundFailure(message: message);
    }
    if (statusCode == 409) {
      return ConflictFailure(message: message);
    }
    if (statusCode == 400 || statusCode == 422) {
      return ValidationFailure(message: message, code: apiCode);
    }

    return ServerFailure(message: message);
  }
}
