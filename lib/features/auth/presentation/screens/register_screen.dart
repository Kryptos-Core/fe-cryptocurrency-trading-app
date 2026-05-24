import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:crypto_trading_app/app/router/app_routes.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/core/utils/name_validator.dart';
import 'package:crypto_trading_app/features/auth/application/services/auth_wallet_flow_service.dart';
import 'package:crypto_trading_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

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
      // Get trimmed values
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final authProvider = context.read<AuthProvider>();

      // Step 1: Register user with email + password + firstName/lastName (REQUIRED)
      final registerResult = await authProvider.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
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
              showAppSnackBar(
                context,
                message:
                    '${AppLocalizations.of(context).registerFailed}: ${failure.message}',
                type: SnackBarType.error,
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
        showAppSnackBar(
          context,
          message: AppLocalizations.of(context).registerSuccessLoggingIn,
          type: SnackBarType.success,
          duration: const Duration(seconds: 2),
        );
      }

      // Step 2: Auto-login after successful registration
      final loginResult = await authProvider.login(
        email: email,
        password: password,
      );

      if (!loginResult.isRight()) {
        // Login failed - navigate to login screen with error
        if (mounted) {
          showAppSnackBar(
            context,
            message: AppLocalizations.of(context).registerLoginFailedManual,
            type: SnackBarType.warning,
            duration: const Duration(seconds: 3),
          );
          context.go(AppRoutes.login);
        }
        return;
      }

      // Login successful
      if (mounted) {
        showAppSnackBar(
          context,
          message: AppLocalizations.of(context).registerLoginSuccess,
          type: SnackBarType.success,
          duration: const Duration(seconds: 1),
        );
      }

      // Step 3: Navigate to shell home via GoRouter (same as email login).
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          context.go(AppRoutes.root);
        });
      }
    } catch (e) {
      if (!mounted) return;
      final msg =
          AppLocalizations.of(context).registerUnexpectedError(e.toString());
      setState(() {
        _errorMessage = msg;
        _isLoading = false;
      });
      if (mounted) {
        showAppSnackBar(
          context,
          message: msg,
          type: SnackBarType.error,
          duration: const Duration(seconds: 4),
        );
      }
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pop();
  }

  void _onWalletAuthSuccess() {
    if (!mounted) return;
    showAppSnackBar(
      context,
      message: AppLocalizations.of(context).registerWalletSuccess,
      type: SnackBarType.success,
      duration: const Duration(seconds: 1),
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.go(AppRoutes.root);
      }
    });
  }

  static const double _kFormMaxWidth = 520;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(l10n.register),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _kFormMaxWidth),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App Icon
                    Icon(
                      Icons.person_add_outlined,
                      size: 80,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      l10n.registerCreateAccount,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    Text(
                      l10n.registerSignUpSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: onSurfaceVariant,
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
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                theme.colorScheme.error.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: theme.colorScheme.onErrorContainer,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // First Name Field (REQUIRED)
                    TextFormField(
                      controller: _firstNameController,
                      enabled: !_isLoading,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context).registerFirstNameLabel,
                        prefixIcon: const Icon(Icons.person_outlined),
                        border: const OutlineInputBorder(),
                        helperText: AppLocalizations.of(context)
                            .registerFirstNameHelper,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(context)
                              .registerFirstNameRequired;
                        }
                        return NameValidator.validateName(
                            value,
                            AppLocalizations.of(context)
                                .registerFirstNameLabel);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Last Name Field (REQUIRED)
                    TextFormField(
                      controller: _lastNameController,
                      enabled: !_isLoading,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context).registerLastNameLabel,
                        prefixIcon: const Icon(Icons.person_outlined),
                        border: const OutlineInputBorder(),
                        helperText: AppLocalizations.of(context)
                            .registerFirstNameHelper,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(context)
                              .registerLastNameRequired;
                        }
                        return NameValidator.validateName(value,
                            AppLocalizations.of(context).registerLastNameLabel);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).email,
                        hintText:
                            AppLocalizations.of(context).registerEmailHint,
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(context).emailRequired;
                        }
                        final emailRegex = RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return AppLocalizations.of(context).invalidEmail;
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
                        labelText:
                            AppLocalizations.of(context).registerPasswordLabel,
                        hintText:
                            AppLocalizations.of(context).registerPasswordHint,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final l10n = AppLocalizations.of(context);
                        if (value == null || value.isEmpty) {
                          return l10n.registerPasswordRequired;
                        }
                        if (value.length < 8) {
                          return l10n.registerPasswordMinLength;
                        }
                        if (!RegExp(r'[A-Z]').hasMatch(value)) {
                          return l10n.registerPasswordNeedsUppercase;
                        }
                        if (!RegExp(r'[a-z]').hasMatch(value)) {
                          return l10n.registerPasswordNeedsLowercase;
                        }
                        if (!RegExp(r'[0-9]').hasMatch(value)) {
                          return l10n.registerPasswordNeedsNumber;
                        }
                        if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                          return l10n.registerPasswordNeedsSpecial;
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
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)
                            .registerConfirmPasswordLabel,
                        hintText: AppLocalizations.of(context)
                            .registerConfirmPasswordHint,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => setState(() =>
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final l10n = AppLocalizations.of(context);
                        if (value == null || value.isEmpty) {
                          return l10n.registerConfirmPasswordRequired;
                        }
                        if (value != _passwordController.text) {
                          return l10n.registerPasswordsNoMatch;
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
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              l10n.register,
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                    const SizedBox(height: 24),

                    // Wallet register divider
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            l10n.registerWalletDivider,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () => context
                                .read<AuthWalletFlowService>()
                                .openWalletConnectQrLogin(
                                  context,
                                  onSuccess: _onWalletAuthSuccess,
                                ),
                        icon: const Icon(Icons.qr_code_2,
                            color: Color(0xFF5B8DEF), size: 20),
                        label: Text(l10n.registerWalletConnectQr),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFF5B8DEF)),
                          foregroundColor: const Color(0xFF5B8DEF),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l10n.hasAccount),
                        TextButton(
                          onPressed: _isLoading ? null : _navigateToLogin,
                          child: Text(l10n.login),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
