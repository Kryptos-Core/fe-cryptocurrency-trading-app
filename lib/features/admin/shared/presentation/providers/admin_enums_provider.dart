import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/core/network/dio_client.dart';
import 'package:crypto_trading_app/features/admin/payment_config/data/models/admin_enums_snapshot.dart';
import 'package:dio/dio.dart';

/// Loads GET /enums for admin filter value lists (labels remain l10n).
class AdminEnumsProvider extends ChangeNotifier {
  AdminEnumsProvider({required DioClient dioClient}) : _dioClient = dioClient;

  final DioClient _dioClient;

  AdminEnumsSnapshot _snapshot = AdminEnumsSnapshot.fallback();
  bool _loading = false;
  bool _loaded = false;
  String? _error;

  AdminEnumsSnapshot get snapshot => _snapshot;

  List<String> get orderStatuses => _snapshot.orderStatus;
  List<String> get depositStatuses => _snapshot.depositStatus;
  List<String> get withdrawalStatuses => _snapshot.withdrawalStatus;
  List<String> get userRoles => _snapshot.userRole;
  List<String> get userStatuses => _snapshot.userStatus;
  List<String> get treasuryWalletPurposes => _snapshot.treasuryWalletPurpose;

  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> ensureLoaded({bool force = false}) async {
    if (_loaded && !force) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final resp = await _dioClient.dio.get(ApiConstants.adminEnums);
      final data = resp.data;
      Map<String, dynamic>? inner;
      if (data is Map<String, dynamic> && data['data'] is Map) {
        inner = Map<String, dynamic>.from(data['data'] as Map);
      } else if (data is Map<String, dynamic>) {
        inner = Map<String, dynamic>.from(data);
      }
      if (inner != null && inner.isNotEmpty) {
        _snapshot =
            AdminEnumsSnapshot.fromApiMap(inner).mergedWithFallback();
      }
      _loaded = true;
    } on DioException catch (e) {
      _error = e.response?.data?['message']?.toString() ?? e.message;
      _loaded = true;
    } catch (e) {
      _error = e.toString();
      _loaded = true;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
