import 'package:crypto_trading_app/core/network/dio_client.dart';
import 'package:crypto_trading_app/data/models/deposit_model.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:dio/dio.dart';

abstract class DepositRemoteDataSource {
  Future<List<DepositModel>> getMyDeposits();
  Future<Map<String, dynamic>> createDepositLink(int amount);
  Future<Map<String, dynamic>> syncDepositStatus(int orderCode);
}

class DepositRemoteDataSourceImpl implements DepositRemoteDataSource {
  final DioClient dioClient;

  DepositRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<DepositModel>> getMyDeposits() async {
    try {
      final response = await dioClient.dio.get('/deposits');
      if (response.data != null && response.data is List) {
        return (response.data as List)
            .map((json) => DepositModel.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? 'Failed to load deposits');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> createDepositLink(int amount) async {
    try {
      final response = await dioClient.dio.post(
        '/deposits',
        data: {'amount': amount},
      );
      return response.data;
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? 'Failed to create deposit');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> syncDepositStatus(int orderCode) async {
    try {
      final response =
          await dioClient.dio.get('/deposits/$orderCode/sync-status');
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {'updated': false};
    } on DioException catch (e) {
      throw ServerException(
          message:
              e.response?.data?['message'] ?? 'Failed to sync deposit status');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
