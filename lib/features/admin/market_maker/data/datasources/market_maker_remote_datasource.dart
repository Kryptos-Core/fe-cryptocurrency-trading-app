import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/network/dio_client.dart';
import 'package:crypto_trading_app/features/admin/market_maker/data/models/market_maker_config_model.dart';
import 'package:crypto_trading_app/features/admin/market_maker/data/models/market_maker_form_defaults_model.dart';
import 'package:dio/dio.dart';

abstract class MarketMakerRemoteDataSource {
  Future<MarketMakerFormDefaultsModel> getFormDefaults();
  Future<List<MarketMakerConfigModel>> listConfigs();
  Future<MarketMakerConfigModel> upsertConfig(String pairId, Map<String, dynamic> payload);
  Future<void> deleteConfig(String pairId);
  Future<Map<String, dynamic>> placeMakerOrders(
    String pairId, {
    String? orderAmountOverride,
    String? refreshCycleKey,
  });
  Future<List<MarketMakerPairOption>> getActivePairs();
}

class MarketMakerRemoteDataSourceImpl implements MarketMakerRemoteDataSource {
  final DioClient dioClient;

  MarketMakerRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<MarketMakerFormDefaultsModel> getFormDefaults() async {
    try {
      final response = await dioClient.dio.get(ApiConstants.marketMakerDefaults);
      final map = _unwrap<Map<String, dynamic>>(response.data);
      return MarketMakerFormDefaultsModel.fromJson(map);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to load MM defaults',
        errorCode: ServerErrorCode.loadMarketMakerDefaults,
      );
    }
  }

  T _unwrap<T>(dynamic payload) {
    if (payload is Map<String, dynamic> && payload['data'] is T) {
      return payload['data'] as T;
    }
    if (payload is T) return payload;
    throw const FormatException('Unexpected API response format');
  }

  Map<String, dynamic>? _safeContext(dynamic raw) {
    if (raw is Map && raw['context'] is Map) {
      return Map<String, dynamic>.from(raw['context'] as Map);
    }
    return null;
  }

  @override
  Future<List<MarketMakerConfigModel>> listConfigs() async {
    try {
      final response = await dioClient.dio.get(ApiConstants.marketMakerConfig);
      final rawList = _unwrap<List<dynamic>>(response.data);
      return rawList
          .whereType<Map<String, dynamic>>()
          .map(MarketMakerConfigModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to load market maker configs',
        errorCode: ServerErrorCode.loadMarketMakerConfigs,
      );
    }
  }

  @override
  Future<MarketMakerConfigModel> upsertConfig(
    String pairId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await dioClient.dio.put(
        ApiConstants.marketMakerConfigByPair(pairId),
        data: payload,
      );
      return MarketMakerConfigModel.fromJson(_unwrap<Map<String, dynamic>>(response.data));
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to save market maker config',
        statusCode: e.response?.statusCode,
        code: e.response?.data?['code']?.toString(),
        context: _safeContext(e.response?.data),
        errorCode: ServerErrorCode.saveMarketMakerConfig,
      );
    }
  }

  @override
  Future<void> deleteConfig(String pairId) async {
    try {
      await dioClient.dio.delete(ApiConstants.marketMakerConfigByPair(pairId));
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to delete market maker config',
        errorCode: ServerErrorCode.deleteMarketMakerConfig,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> placeMakerOrders(
    String pairId, {
    String? orderAmountOverride,
    String? refreshCycleKey,
  }) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.marketMakerRefresh(pairId),
        data: {
          if (refreshCycleKey != null && refreshCycleKey.isNotEmpty)
            'refresh_cycle_key': refreshCycleKey,
          if (orderAmountOverride != null && orderAmountOverride.isNotEmpty)
            'order_amount_override': orderAmountOverride,
        },
      );
      return _unwrap<Map<String, dynamic>>(response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to place maker orders',
        statusCode: e.response?.statusCode,
        code: e.response?.data?['code']?.toString(),
        context: _safeContext(e.response?.data),
        errorCode: ServerErrorCode.placeMakerOrders,
      );
    }
  }

  @override
  Future<List<MarketMakerPairOption>> getActivePairs() async {
    try {
      final response = await dioClient.dio.get(ApiConstants.marketsActive);
      final raw = _unwrap<List<dynamic>>(response.data);
      return raw
          .whereType<Map<String, dynamic>>()
          .map(MarketMakerPairOption.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to load active pairs',
        errorCode: ServerErrorCode.loadActivePairs,
      );
    }
  }
}
