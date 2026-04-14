import 'package:flutter/material.dart';
import 'package:crypto_trading_app/app/app.dart';
import 'package:crypto_trading_app/app/bootstrap/initialize_app_bootstrap.dart';

Future<void> main() async {
  await initializeAppBootstrap();
  runApp(const CryptoTradingApp());
}
