import 'package:crypto_trading_app/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:crypto_trading_app/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:crypto_trading_app/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;

  DashboardRepositoryImpl({required DashboardRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<DashboardSummary> getDashboardSummary() =>
      _remoteDataSource.getDashboardSummary();
}
