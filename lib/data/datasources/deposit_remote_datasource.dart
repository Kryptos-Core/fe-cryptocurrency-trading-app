import 'package:crypto_trading_app/core/network/dio_client.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/data/models/deposit_model.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:dio/dio.dart';

abstract class DepositRemoteDataSource {
  Future<List<DepositModel>> getMyDeposits();
  Future<Map<String, dynamic>> getCheckoutMeta();
  Future<Map<String, dynamic>> createDepositLink(int amount);
  Future<Map<String, dynamic>> syncDepositStatus(int orderCode);
}

class DepositRemoteDataSourceImpl implements DepositRemoteDataSource {
  final DioClient dioClient;

  DepositRemoteDataSourceImpl({required this.dioClient});

  T _unwrapApiData<T>(dynamic payload) {
    if (payload is Map<String, dynamic> && payload['data'] is T) {
      return payload['data'] as T;
    }
    if (payload is T) {
      return payload;
    }
    throw const FormatException('Unexpected API response format');
  }

  @override
  Future<List<DepositModel>> getMyDeposits() async {
    try {
      final response = await dioClient.dio.get(ApiConstants.deposits);
      final rawList = _unwrapApiData<List<dynamic>>(response.data);
      return rawList
          .whereType<Map<String, dynamic>>()
          .map((json) => DepositModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? 'Failed to load deposits');
    } on FormatException {
      throw ServerException(message: 'Failed to parse deposits response');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getCheckoutMeta() async {
    try {
      final response =
          await dioClient.dio.get(ApiConstants.depositsCheckoutMeta);
      return _unwrapApiData<Map<String, dynamic>>(response.data);
    } on DioException catch (e) {
      throw ServerException(
        message:
            e.response?.data?['message'] ?? 'Failed to load deposit checkout meta',
      );
    } on FormatException {
      throw ServerException(message: 'Failed to parse checkout meta response');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> createDepositLink(int amount) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.deposits,
        data: {'amount': amount},
      );
      return _unwrapApiData<Map<String, dynamic>>(response.data);
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? 'Failed to create deposit');
    } on FormatException {
      throw ServerException(message: 'Failed to parse create deposit response');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> syncDepositStatus(int orderCode) async {
    try {
      final response = await dioClient.dio.get(
        '${ApiConstants.deposits}/$orderCode/sync-status',
      );
      return _unwrapApiData<Map<String, dynamic>>(response.data);
    } on DioException catch (e) {
      throw ServerException(
          message:
              e.response?.data?['message'] ?? 'Failed to sync deposit status');
    } on FormatException {
      throw ServerException(message: 'Failed to parse sync deposit response');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
