import 'package:dio/dio.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';

/// Exchange Remote Data Source
/// Calls backend exchange/sync endpoints (e.g. sync Binance info into DB).
abstract class ExchangeRemoteDataSource {
  /// POST /exchange/sync-info — sync Binance currencies & market pairs into DB.
  /// Requires Authorization: Bearer <token>.
  Future<void> syncInfo();
}

class ExchangeRemoteDataSourceImpl implements ExchangeRemoteDataSource {
  final Dio dio;

  ExchangeRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> syncInfo() async {
    try {
      final response = await dio.post(ApiConstants.exchangeSyncInfo);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }
      throw ServerException(
        message: response.data?['message'] ?? 'Sync failed',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(message: 'Connection timeout');
      }
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) {
        throw AuthenticationException(message: 'Unauthorized');
      }
      if (statusCode == 404) {
        throw NotFoundException(message: 'Sync endpoint not found');
      }
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Sync failed',
        statusCode: statusCode,
      );
    }
  }
}
