import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  static const String _apiKeyPrefix = 'binance_api_key_';
  static const String _secretPrefix = 'binance_secret_';
  static const String _credentialIdsKey = 'binance_credential_ids';

  Future<void> saveBinanceCredentials({
    required String credentialId,
    required String apiKey,
    required String apiSecret,
  }) async {
    await _storage.write(key: '$_apiKeyPrefix$credentialId', value: apiKey);
    await _storage.write(key: '$_secretPrefix$credentialId', value: apiSecret);

    final ids = await getCredentialIds();
    if (!ids.contains(credentialId)) {
      await _storage.write(key: _credentialIdsKey, value: ids.join(','));
    }
  }

  Future<({String apiKey, String apiSecret})?> getBinanceCredentials(String credentialId) async {
    final apiKey = await _storage.read(key: '$_apiKeyPrefix$credentialId');
    final secret = await _storage.read(key: '$_secretPrefix$credentialId');
    if (apiKey == null || secret == null) return null;
    return (apiKey: apiKey, apiSecret: secret);
  }

  Future<void> deleteBinanceCredentials(String credentialId) async {
    await _storage.delete(key: '$_apiKeyPrefix$credentialId');
    await _storage.delete(key: '$_secretPrefix$credentialId');

    final ids = await getCredentialIds();
    ids.remove(credentialId);
    if (ids.isEmpty) {
      await _storage.delete(key: _credentialIdsKey);
    } else {
      await _storage.write(key: _credentialIdsKey, value: ids.join(','));
    }
  }

  Future<List<String>> getCredentialIds() async {
    final stored = await _storage.read(key: _credentialIdsKey);
    if (stored == null || stored.isEmpty) return [];
    return stored.split(',').where((s) => s.isNotEmpty).toList();
  }

  Future<void> clearAllBinanceData() async {
    final ids = await getCredentialIds();
    for (final id in ids) {
      await deleteBinanceCredentials(id);
    }
  }
}
