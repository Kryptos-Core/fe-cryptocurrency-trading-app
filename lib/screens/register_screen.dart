import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart';
import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/core/services/toast_service.dart';
import 'package:crypto_trading_app/domain/usecases/auth_usecases.dart';
import 'package:crypto_trading_app/screens/login_screen.dart';

/// Register Screen
/// Allows new users to create an account
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Step 1: Register user with email + password only
      final registerUseCase = sl<RegisterUseCase>();
      final registerResult = await registerUseCase(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: '', // Backend doesn't require these
        lastName: '',
      );

      if (!registerResult.isRight()) {
        // Registration failed - show error message
        registerResult.fold(
          (failure) {
            setState(() {
              _errorMessage = failure.message;
              _isLoading = false;
            });
            if (mounted) {
              ToastService().show(
                context,
                message: 'Registration failed: ${failure.message}',
                type: ToastType.error,
                duration: const Duration(seconds: 4),
              );
            }
          },
          (_) {}, // Won't reach here due to isRight check
        );
        return;
      }

      // Registration successful
      if (mounted) {
        ToastService().show(
          context,
          message: 'Registration successful! Logging in...',
          type: ToastType.success,
          duration: const Duration(seconds: 2),
        );
      }

      // Step 2: Auto-login after successful registration
      final loginUseCase = sl<LoginUseCase>();
      final loginResult = await loginUseCase(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!loginResult.isRight()) {
        // Login failed - navigate to login screen with error
        if (mounted) {
          ToastService().show(
            context,
            message: 'Login failed. Please try logging in manually.',
            type: ToastType.warning,
            duration: const Duration(seconds: 3),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
        return;
      }

      // Login successful
      if (mounted) {
        ToastService().show(
          context,
          message: 'Login successful!',
          type: ToastType.success,
          duration: const Duration(seconds: 1),
        );
      }

      // Step 3: Save tokens and update profile
      loginResult.fold(
        (_) {}, // Error handled above
        (authResponse) async {
          // Save tokens
          final tokenService = sl<TokenService>();
          await tokenService.saveTokens(
            accessToken: authResponse.accessToken,
            refreshToken: authResponse.refreshToken,
          );

          // Step 4: Update user profile with firstName and lastName
          if (_firstNameController.text.trim().isNotEmpty ||
              _lastNameController.text.trim().isNotEmpty) {
            try {
              final dio = sl<Dio>();
              await dio.patch(
                '/users/me',
                data: {
                  'firstName': _firstNameController.text.trim(),
                  'lastName': _lastNameController.text.trim(),
                },
              );
              if (mounted) {
                ToastService().show(
                  context,
                  message: 'Profile updated successfully!',
                  type: ToastType.success,
                  duration: const Duration(seconds: 1),
                );
              }
            } catch (e) {
              // Update profile failed, but user is logged in
              // Show warning but still navigate to home screen
              if (mounted) {
                ToastService().show(
                  context,
                  message: 'Profile update failed: ${e.toString()}',
                  type: ToastType.warning,
                  duration: const Duration(seconds: 3),
                );
              }
            }
          }

          // Step 5: Navigate to home screen
          if (mounted) {
            Future.delayed(const Duration(milliseconds: 500), () {
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            });
          }
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Unexpected error: ${e.toString()}';
        _isLoading = false;
      });
      if (mounted) {
        ToastService().show(
          context,
          message: 'Error: ${e.toString()}',
          type: ToastType.error,
          duration: const Duration(seconds: 4),
        );
      }
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
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
                    Icons.person_add_outlined,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Sign up to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Error Message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // First Name Field
                  TextFormField(
                    controller: _firstNameController,
                    enabled: !_isLoading,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      hintText: 'John',
                      prefixIcon: Icon(Icons.person_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Last Name Field
                  TextFormField(
                    controller: _lastNameController,
                    enabled: !_isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      hintText: 'Doe',
                      prefixIcon: Icon(Icons.person_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'user@example.com',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email';
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
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Min 8 characters with uppercase, lowercase, number',
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
                        return 'Please enter a password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      if (!RegExp(r'[A-Z]').hasMatch(value)) {
                        return 'Password must contain uppercase letter';
                      }
                      if (!RegExp(r'[a-z]').hasMatch(value)) {
                        return 'Password must contain lowercase letter';
                      }
                      if (!RegExp(r'[0-9]').hasMatch(value)) {
                        return 'Password must contain a number';
                      }
                      if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                        return 'Password must contain a special character';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: 'Re-enter your password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Register Button
                  FilledButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Register',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? '),
                      TextButton(
                        onPressed: _isLoading ? null : _navigateToLogin,
                        child: const Text('Login'),
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
