import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/network/dio_client.dart';
import 'package:crypto_trading_app/features/admin/payment_config/data/models/treasury_e2e_config_model.dart';
import 'package:dio/dio.dart';

abstract class TreasuryE2EConfigRemoteDataSource {
  Future<List<TreasuryE2EConfigModel>> listConfigs();
  Future<TreasuryE2EConfigModel> getConfigDetail(String id);
  Future<Map<String, dynamic>> getFormOptions({String? environment, String? chain, String? traderUserId, String? traderSearch});
  Future<Map<String, dynamic>> validateDraft(Map<String, dynamic> payload);
  Future<Map<String, dynamic>> testConnection(Map<String, dynamic> payload);
  Future<TreasuryE2EConfigModel> createConfig(Map<String, dynamic> payload);
  Future<TreasuryE2EConfigModel> updateConfig(String id, Map<String, dynamic> payload);
  Future<TreasuryE2EConfigModel> activateConfig(String id);
  Future<TreasuryE2EConfigModel> deactivateConfig(String id);
  Future<void> archiveConfig(String id);
}

class TreasuryE2EConfigRemoteDataSourceImpl implements TreasuryE2EConfigRemoteDataSource {
  TreasuryE2EConfigRemoteDataSourceImpl({required this.dioClient});

  final DioClient dioClient;

  T _unwrap<T>(dynamic payload) {
    if (payload is Map<String, dynamic> && payload['data'] is T) {
      return payload['data'] as T;
    }
    if (payload is T) return payload;
    throw const FormatException('Unexpected API response format');
  }

  @override
  Future<List<TreasuryE2EConfigModel>> listConfigs() async {
    try {
      final response = await dioClient.dio.get(ApiConstants.treasuryE2EConfigs);
      final rawList = _unwrap<List<dynamic>>(response.data);
      return rawList
          .whereType<Map<String, dynamic>>()
          .map(TreasuryE2EConfigModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to load treasury E2E configs',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }


  @override
  Future<Map<String, dynamic>> getFormOptions({String? environment, String? chain, String? traderUserId, String? traderSearch}) async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.treasuryE2EConfigOptions,
        queryParameters: {
          if (environment != null && environment.isNotEmpty) 'environment': environment,
          if (chain != null && chain.isNotEmpty) 'chain': chain,
          if (traderUserId != null && traderUserId.isNotEmpty) 'traderUserId': traderUserId,
          if (traderSearch != null && traderSearch.isNotEmpty) 'traderSearch': traderSearch,
        },
      );
      return Map<String, dynamic>.from(_unwrap<Map<String, dynamic>>(response.data));
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to load treasury E2E config options',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> validateDraft(Map<String, dynamic> payload) async {
    try {
      final response = await dioClient.dio.post(ApiConstants.treasuryE2EConfigValidate, data: payload);
      return Map<String, dynamic>.from(_unwrap<Map<String, dynamic>>(response.data));
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to validate treasury E2E config',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }


  @override
  Future<Map<String, dynamic>> testConnection(Map<String, dynamic> payload) async {
    try {
      final response = await dioClient.dio.post(ApiConstants.treasuryE2EConfigTestConnection, data: payload);
      return Map<String, dynamic>.from(_unwrap<Map<String, dynamic>>(response.data));
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to test treasury E2E connection',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<TreasuryE2EConfigModel> getConfigDetail(String id) async {
    try {
      final response = await dioClient.dio.get(ApiConstants.treasuryE2EConfigById(id));
      return TreasuryE2EConfigModel.fromJson(
        _unwrap<Map<String, dynamic>>(response.data),
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to load treasury E2E config detail',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<TreasuryE2EConfigModel> createConfig(Map<String, dynamic> payload) async {
    try {
      final response = await dioClient.dio.post(ApiConstants.treasuryE2EConfigs, data: payload);
      return TreasuryE2EConfigModel.fromJson(
        _unwrap<Map<String, dynamic>>(response.data),
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to create treasury E2E config',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<TreasuryE2EConfigModel> updateConfig(String id, Map<String, dynamic> payload) async {
    try {
      final response = await dioClient.dio.put(ApiConstants.treasuryE2EConfigById(id), data: payload);
      return TreasuryE2EConfigModel.fromJson(
        _unwrap<Map<String, dynamic>>(response.data),
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to update treasury E2E config',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<TreasuryE2EConfigModel> activateConfig(String id) async {
    try {
      final response = await dioClient.dio.post(ApiConstants.treasuryE2EConfigActivate(id));
      return TreasuryE2EConfigModel.fromJson(
        _unwrap<Map<String, dynamic>>(response.data),
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to activate treasury E2E config',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<TreasuryE2EConfigModel> deactivateConfig(String id) async {
    try {
      final response = await dioClient.dio.post(ApiConstants.treasuryE2EConfigDeactivate(id));
      return TreasuryE2EConfigModel.fromJson(
        _unwrap<Map<String, dynamic>>(response.data),
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to deactivate treasury E2E config',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> archiveConfig(String id) async {
    try {
      await dioClient.dio.delete(ApiConstants.treasuryE2EConfigById(id));
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to archive treasury E2E config',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
