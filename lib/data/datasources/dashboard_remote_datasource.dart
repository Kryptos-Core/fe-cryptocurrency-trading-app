import 'package:dio/dio.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/data/models/dashboard_summary_model.dart';

/// Dashboard Remote Data Source
/// Calls GET /api/v1/dashboard — aggregated endpoint returning top markets,
/// portfolio total, and wallet balances in a single round-trip.
abstract class DashboardRemoteDataSource {
  Future<DashboardSummary> getDashboardSummary();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio dio;

  DashboardRemoteDataSourceImpl({required this.dio});

  @override
  Future<DashboardSummary> getDashboardSummary() async {
    try {
      final response = await dio.get(ApiConstants.dashboard);

      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        // BE wraps in { success, data, message, timestamp }
        final payload = body['data'] as Map<String, dynamic>? ?? body;
        return DashboardSummary.fromJson(payload);
      } else {
        throw ServerException(
          message: 'Failed to fetch dashboard summary',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(message: 'Connection timeout');
      }
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? 'Server error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is NetworkException || e is ServerException) rethrow;
      throw ServerException(message: 'Unexpected error: $e');
    }
  }
}
