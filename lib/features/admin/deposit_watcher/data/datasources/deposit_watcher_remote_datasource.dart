import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';

class DepositWatcherCursorInfo {
  final String chain;
  final String cursorValue;
  final String cursorKind;

  const DepositWatcherCursorInfo({
    required this.chain,
    required this.cursorValue,
    required this.cursorKind,
  });

  factory DepositWatcherCursorInfo.fromJson(Map<String, dynamic> json) {
    return DepositWatcherCursorInfo(
      chain: json['chain'] as String? ?? '',
      cursorValue: json['cursor_value'] as String? ?? '0',
      cursorKind: json['cursor_kind'] as String? ?? 'TIMESTAMP_MS',
    );
  }

  DateTime? get cursorAsDateTime {
    if (cursorKind == 'TIMESTAMP_MS') {
      final ms = int.tryParse(cursorValue);
      if (ms != null && ms > 0) {
        return DateTime.fromMillisecondsSinceEpoch(ms);
      }
    }
    return null;
  }
}

class DepositWatcherRemoteDatasource {
  final Dio _dio;

  DepositWatcherRemoteDatasource({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
            ));

  Future<List<DepositWatcherCursorInfo>> listCursors() async {
    try {
      // NOTE: baseUrl đã chứa /api/v1, nên endpoint không cần prefix đó
      final res = await _dio.get('/admin/deposit-watcher/cursors');
      final data = res.data as Map<String, dynamic>;
      final cursors = data['cursors'] as List<dynamic>? ?? [];
      return cursors.map((e) => DepositWatcherCursorInfo.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      debugPrint('listCursors error: ${e.message}');
      rethrow;
    }
  }

  Future<void> resetCursor(String chain) async {
    try {
      await _dio.post('/admin/deposit-watcher/reset-cursor', queryParameters: {'chain': chain});
    } on DioException catch (e) {
      debugPrint('resetCursor error: ${e.message}');
      rethrow;
    }
  }

  Future<void> resetAllCursors() async {
    try {
      await _dio.delete('/admin/deposit-watcher/cursors');
    } on DioException catch (e) {
      debugPrint('resetAllCursors error: ${e.message}');
      rethrow;
    }
  }
}
