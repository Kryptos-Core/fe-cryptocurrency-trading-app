import 'package:flutter/material.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart';
import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/data/datasources/auth_remote_datasource.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/data/repositories/auth_repository_impl.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/screens/main_screen.dart';
import 'package:crypto_trading_app/screens/register_screen.dart';

/// Login Screen
/// Allows users to authenticate with email and password
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authRepository = sl<AuthRepository>();
      final result = await authRepository.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      result.fold(
        // Failure
        (failure) {
          setState(() {
            _isLoading = false;
          });
          if (mounted) {
            final l10n = AppLocalizations.of(context);
            showAppSnackBar(
              context,
              message: '${l10n.loginFailed}: ${failure.message}',
              type: SnackBarType.error,
              duration: const Duration(seconds: 4),
            );
          }
        },
        // Success
        (authResponse) async {
          // Save tokens
          final tokenService = sl<TokenService>();
          await tokenService.saveTokens(
            accessToken: authResponse.accessToken,
            refreshToken: authResponse.refreshToken,
          );

          setState(() {
            _isLoading = false;
          });

          if (mounted) {
            showAppSnackBar(
              context,
              message: 'Login successful!',
              type: SnackBarType.success,
              duration: const Duration(seconds: 1),
            );

            // Navigate to main screen (with bottom navigation)
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const MainScreen()),
                );
              }
            });
          }
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        showAppSnackBar(
          context,
          message: 'Error: ${e.toString()}',
          type: SnackBarType.error,
          duration: const Duration(seconds: 4),
        );
      }
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  Future<void> _checkConnection() async {
    final ok = await sl<AuthRemoteDataSource>().checkHealth();
    if (!mounted) return;
    final url = '${ApiConstants.baseUrl}/health';
    if (ok) {
      showAppSnackBar(
        context,
        message: 'Backend is reachable. $url',
        type: SnackBarType.success,
        duration: const Duration(seconds: 2),
      );
    } else {
      showAppSnackBar(
        context,
        message: 'Cannot reach backend. Open in browser: $url',
        type: SnackBarType.error,
        duration: const Duration(seconds: 4),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.login),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Icon
                  Icon(
                    Icons.currency_bitcoin,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    l10n.appTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    l10n.loginToAccount,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_isLoading,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      labelText: l10n.email,
                      hintText: 'user@example.com',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.emailRequired;
                      }
                      final emailRegex = RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                      );
                      if (!emailRegex.hasMatch(value.trim())) {
                        return l10n.invalidEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    enabled: !_isLoading,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      labelText: l10n.password,
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.passwordRequired;
                      }
                      if (value.length < 8) {
                        return l10n.passwordMinLength;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Login Button
                  FilledButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            l10n.login,
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _isLoading ? null : _checkConnection,
                    icon: const Icon(Icons.wifi_find, size: 18),
                    label: const Text('Check connection (health)'),
                  ),
                  const SizedBox(height: 16),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.noAccount),
                      TextButton(
                        onPressed: _isLoading ? null : _navigateToRegister,
                        child: Text(l10n.register),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
