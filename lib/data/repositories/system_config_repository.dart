import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/system_config.dart';
import '../../domain/models/runtime_setting_row.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/token_service.dart';

class SystemConfigRepository {
  final TokenService _tokenService;
  final http.Client _client;

  SystemConfigRepository({
    required TokenService tokenService,
    http.Client? client,
  })  : _tokenService = tokenService,
        _client = client ?? http.Client();

  /// Nest [ResponseInterceptor] wraps JSON as `{ success, data?, timestamp }`.
  static dynamic unwrapEnvelope(dynamic decoded) {
    if (decoded is Map<String, dynamic> &&
        decoded['success'] == true &&
        decoded.containsKey('data')) {
      return decoded['data'];
    }
    return decoded;
  }

  Future<Map<String, String>> _headers() async {
    final token = _tokenService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<SystemConfig>> getAllConfigs() async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}/system-configs'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final payload = unwrapEnvelope(jsonDecode(response.body));
      if (payload is! List) {
        throw FormatException('Expected list of configs, got ${payload.runtimeType}');
      }
      return payload.map((e) => SystemConfig.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load system configs: ${response.statusCode}');
    }
  }

  Future<List<RuntimeSettingRow>> getRuntimeSettings() async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}/system-configs/runtime'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final payload = unwrapEnvelope(jsonDecode(response.body));
      if (payload is! List) {
        throw FormatException('Expected list of runtime settings, got ${payload.runtimeType}');
      }
      return payload
          .map((e) => RuntimeSettingRow.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load runtime settings: ${response.statusCode} ${response.body}');
  }

  Future<void> patchRuntimeBulk(Map<String, String> updates) async {
    final response = await _client.patch(
      Uri.parse('${ApiConstants.baseUrl}/system-configs/runtime'),
      headers: await _headers(),
      body: jsonEncode({'updates': updates}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save runtime settings: ${response.statusCode} ${response.body}');
    }
  }

  Future<SystemConfig> updateConfig(String key, String value) async {
    final response = await _client.patch(
      Uri.parse('${ApiConstants.baseUrl}/system-configs/$key'),
      headers: await _headers(),
      body: jsonEncode({'value': value}),
    );

    if (response.statusCode == 200) {
      final payload = unwrapEnvelope(jsonDecode(response.body));
      if (payload is! Map<String, dynamic>) {
        throw FormatException('Expected config object, got ${payload.runtimeType}');
      }
      return SystemConfig.fromJson(payload);
    } else {
      throw Exception('Failed to update system config: ${response.statusCode}');
    }
  }
}
