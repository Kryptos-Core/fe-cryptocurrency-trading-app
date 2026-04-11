import 'package:crypto_trading_app/core/network/dio_client.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/data/models/payment_method_config_model.dart';
import 'package:dio/dio.dart';

abstract class PaymentConfigRemoteDataSource {
  Future<List<PaymentMethodConfigModel>> listConfigs();
  Future<Map<String, dynamic>> getFormOptions();
  /// Decrypted credentials in `config` — admin edit form only.
  Future<Map<String, dynamic>> getConfigDetail(String id);
  Future<PaymentMethodConfigModel> createConfig(Map<String, dynamic> payload);
  Future<PaymentMethodConfigModel> updateConfig(String id, Map<String, dynamic> payload);
  Future<Map<String, dynamic>> activateConfig(String id, {int? gracePeriodMinutes});
  Future<void> deactivateConfig(String id);
}

class PaymentConfigRemoteDataSourceImpl implements PaymentConfigRemoteDataSource {
  final DioClient dioClient;

  PaymentConfigRemoteDataSourceImpl({required this.dioClient});

  T _unwrap<T>(dynamic payload) {
    if (payload is Map<String, dynamic> && payload['data'] is T) {
      return payload['data'] as T;
    }
    if (payload is T) return payload;
    throw const FormatException('Unexpected API response format');
  }

  @override
  Future<Map<String, dynamic>> getFormOptions() async {
    try {
      final response = await dioClient.dio.get(ApiConstants.paymentConfigOptions);
      final raw = _unwrap<Map<String, dynamic>>(response.data);
      return Map<String, dynamic>.from(raw);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to load payment config options',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getConfigDetail(String id) async {
    try {
      final response = await dioClient.dio.get(ApiConstants.paymentConfigById(id));
      final raw = _unwrap<Map<String, dynamic>>(response.data);
      return Map<String, dynamic>.from(raw);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to load payment config',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<PaymentMethodConfigModel>> listConfigs() async {
    try {
      final response = await dioClient.dio.get(ApiConstants.paymentConfigs);
      final rawList = _unwrap<List<dynamic>>(response.data);
      return rawList
          .whereType<Map<String, dynamic>>()
          .map(PaymentMethodConfigModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? 'Failed to load payment configs');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PaymentMethodConfigModel> createConfig(Map<String, dynamic> payload) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.paymentConfigs,
        data: payload,
      );
      return PaymentMethodConfigModel.fromJson(
        _unwrap<Map<String, dynamic>>(response.data),
      );
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? 'Failed to create payment config');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PaymentMethodConfigModel> updateConfig(
    String id,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await dioClient.dio.put(
        ApiConstants.paymentConfigById(id),
        data: payload,
      );
      return PaymentMethodConfigModel.fromJson(
        _unwrap<Map<String, dynamic>>(response.data),
      );
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? 'Failed to update payment config');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> activateConfig(
    String id, {
    int? gracePeriodMinutes,
  }) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.paymentConfigActivate(id),
        data: gracePeriodMinutes != null
            ? {'grace_period_minutes': gracePeriodMinutes}
            : {},
      );
      return _unwrap<Map<String, dynamic>>(response.data);
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? 'Failed to activate payment config');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deactivateConfig(String id) async {
    try {
      await dioClient.dio.delete(ApiConstants.paymentConfigById(id));
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? 'Failed to deactivate payment config');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
