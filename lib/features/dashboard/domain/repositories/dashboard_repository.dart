import 'package:crypto_trading_app/features/dashboard/domain/entities/dashboard_summary.dart';

/// Aggregated dashboard REST (`GET /dashboard`).
abstract class DashboardRepository {
  Future<DashboardSummary> getDashboardSummary();
}
