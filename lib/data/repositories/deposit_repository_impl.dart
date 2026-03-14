import 'package:crypto_trading_app/data/datasources/deposit_remote_datasource.dart';
import 'package:crypto_trading_app/domain/entities/deposit.dart';
import 'package:crypto_trading_app/domain/repositories/deposit_repository.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';

class DepositRepositoryImpl implements DepositRepository {
  final DepositRemoteDataSource remoteDataSource;

  DepositRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<Deposit>> getMyDeposits() async {
    try {
      final models = await remoteDataSource.getMyDeposits();
      return models.cast<Deposit>();
    } on ServerException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<Map<String, dynamic>> createDepositLink(int amount) async {
    try {
      return await remoteDataSource.createDepositLink(amount);
    } on ServerException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<Map<String, dynamic>> syncDepositStatus(int orderCode) async {
    try {
      return await remoteDataSource.syncDepositStatus(orderCode);
    } on ServerException catch (e) {
      throw ServerException(message: e.message);
    }
  }
}
