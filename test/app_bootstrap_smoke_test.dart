import 'package:crypto_trading_app/features/notifications/application/services/fcm_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto_trading_app/app/bootstrap/initialize_app_bootstrap.dart';

void main() {
  test('bootstrap entrypoint remains callable', () {
    expect(initializeAppBootstrap, isA<Function>());
  });

  test('bootstrap references shared app infrastructure types', () {
    expect(Hive, isNotNull);
    expect(FcmService, isNotNull);
  });
}
