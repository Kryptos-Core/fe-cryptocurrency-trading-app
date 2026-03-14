import 'package:crypto_trading_app/core/network/dio_client.dart';
import 'package:crypto_trading_app/data/models/deposit_model.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:dio/dio.dart';

abstract class DepositRemoteDataSource {
  Future<List<DepositModel>> getMyDeposits();
  Future<Map<String, dynamic>> createDepositLink(double amount);
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
  Future<Map<String, dynamic>> createDepositLink(double amount) async {
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
}
