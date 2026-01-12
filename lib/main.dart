import 'package:flutter/material.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart' as di;
import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/screens/home_screen.dart';
import 'package:crypto_trading_app/screens/login_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await di.initializeDependencies();
  
  runApp(const CryptoTradingApp());
}

class CryptoTradingApp extends StatelessWidget {
  const CryptoTradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Re-initialize on hot reload if needed
    di.initializeDependencies();
    
    // Check if user is authenticated
    final tokenService = di.sl<TokenService>();
    final isAuthenticated = tokenService.isAuthenticated();
    
    return MaterialApp(
      title: 'Crypto Trading App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      // Show HomeScreen if authenticated, otherwise LoginScreen
      home: isAuthenticated ? const HomeScreen() : const LoginScreen(),
    );
  }
}
