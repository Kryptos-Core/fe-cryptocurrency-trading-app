import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:crypto_trading_app/app/router/app_routes.dart';
import 'package:crypto_trading_app/features/auth/application/services/auth_wallet_flow_service.dart';
import 'package:crypto_trading_app/features/auth/presentation/dev/dev_account_sheet.dart';
import 'package:crypto_trading_app/features/auth/presentation/dev/dev_test_accounts.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/features/auth/presentation/screens/register_screen.dart';
import 'package:provider/provider.dart';

/// Nút kết nối ví — dùng chung cho WalletConnect và TronLink
class _WalletLoginButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool disabled;
  final VoidCallback onPressed;
  final double verticalPadding;

  const _WalletLoginButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.disabled,
    required this.onPressed,
    this.verticalPadding = 14,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: disabled ? null : onPressed,
        icon: Icon(icon, color: disabled ? null : color, size: 20),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          side: BorderSide(color: disabled ? Colors.grey : color),
          foregroundColor: disabled ? null : color,
        ),
      ),
    );
  }
}

/// Bố cục login co giãn theo chiều cao viewport (ưu tiên không scroll).
class _LoginViewportLayout {
  const _LoginViewportLayout({
    required this.padding,
    required this.logoSize,
    required this.gapScale,
    required this.denseInputs,
    required this.walletButtonVerticalPadding,
    required this.mainButtonVerticalPadding,
    required this.needsScroll,
    required this.useSmallerTitle,
  });

  final double padding;
  final double logoSize;
  final double gapScale;
  final bool denseInputs;
  final double walletButtonVerticalPadding;
  final double mainButtonVerticalPadding;
  final bool needsScroll;
  final bool useSmallerTitle;

  double g(double n) => n * gapScale;
}

_LoginViewportLayout _layoutLoginForViewport(double maxH, double maxW) {
  final shortest = math.min(maxH, maxW);
  final fromWidth = maxW * 0.24;
  final fromHeight = maxH * 0.16;
  final fromShortest = shortest * 0.40;
  var idealLogo = math
      .max(fromWidth, math.max(fromHeight, fromShortest))
      .clamp(120.0, 400.0);

  var padding = maxH < 560
      ? 10.0
      : maxH < 680
          ? 14.0
          : 24.0;
  var gapScale = maxH < 520
      ? 0.5
      : maxH < 600
          ? 0.62
          : maxH < 720
              ? 0.78
              : 1.0;
  var dense = maxH < 700;
  var useSmallerTitle = maxH < 640;
  var walletVPad = maxH < 540 ? 8.0 : (maxH < 660 ? 10.0 : 14.0);
  var mainBtnVPad = dense ? 12.0 : 16.0;

  double estimateTotal(double logo) {
    final fieldH = dense ? 44.0 : 54.0;
    final walletH = walletVPad * 2 + 24.0;
    return padding * 2 +
        logo +
        16 * gapScale +
        (useSmallerTitle ? 30.0 : 42.0) +
        8 * gapScale +
        (dense ? 14.0 : 20.0) +
        22 * gapScale +
        fieldH +
        12 * gapScale +
        fieldH +
        14 * gapScale +
        (dense ? 40.0 : 50.0) +
        8 * gapScale +
        26.0 +
        14 * gapScale +
        22.0 +
        8 * gapScale +
        walletH +
        6 * gapScale +
        walletH +
        8 * gapScale +
        32.0 +
        28.0;
  }

  var logo = idealLogo;
  while (estimateTotal(logo) > maxH && logo > 72) {
    logo -= 14;
  }
  while (estimateTotal(logo) > maxH && gapScale > 0.5) {
    gapScale = (gapScale - 0.06).clamp(0.5, 1.0);
    dense = true;
    useSmallerTitle = true;
  }
  while (estimateTotal(logo) > maxH && logo > 56) {
    logo -= 10;
  }
  while (estimateTotal(logo) > maxH && padding > 8) {
    padding -= 2;
    dense = true;
    useSmallerTitle = true;
  }
  // Last resort: shrink gaps further so scroll is almost never needed on normal windows.
  while (estimateTotal(logo) > maxH && gapScale > 0.42) {
    gapScale = (gapScale - 0.04).clamp(0.42, 1.0);
    dense = true;
    useSmallerTitle = true;
  }
  while (estimateTotal(logo) > maxH && logo > 48) {
    logo -= 8;
  }

  final needsScroll = estimateTotal(logo) > maxH + 2;
  logo = logo.clamp(48.0, 400.0);

  return _LoginViewportLayout(
    padding: padding,
    logoSize: logo,
    gapScale: gapScale,
    denseInputs: dense,
    walletButtonVerticalPadding: walletVPad,
    mainButtonVerticalPadding: mainBtnVPad,
    needsScroll: needsScroll,
    useSmallerTitle: useSmallerTitle,
  );
}

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

  /// Return to the main (guest-capable) shell via GoRouter (avoid imperative [MainScreen] stacking).
  void _exitToGuest() {
    if (!mounted) return;
    context.go(AppRoutes.root);
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = context.read<AuthProvider>();
    final l10n = AppLocalizations.of(context);

    try {
      final result = await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      result.fold(
        (failure) {
          setState(() {
            _isLoading = false;
          });
          if (mounted) {
            showAppSnackBar(
              context,
              message: '${l10n.loginFailed}: ${failure.message}',
              type: SnackBarType.error,
              duration: const Duration(seconds: 4),
            );
          }
        },
        (_) {
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

            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                context.go(AppRoutes.root);
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

  void _onWalletAuthSuccess() {
    if (!mounted) return;
    showAppSnackBar(
      context,
      message: 'Đăng nhập bằng ví thành công!',
      type: SnackBarType.success,
      duration: const Duration(seconds: 1),
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.go(AppRoutes.root);
      }
    });
  }

  void _showDevAccounts() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DevAccountSheet(
        accounts: devTestAccounts,
        onLogin: (email, password) {
          Navigator.of(context).pop();
          _emailController.text = email;
          _passwordController.text = password;
          _handleLogin();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n.back,
          onPressed: _isLoading ? null : _exitToGuest,
        ),
        title: Text(l10n.login),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final lv = _layoutLoginForViewport(
              constraints.maxHeight,
              constraints.maxWidth,
            );
            final form = _loginFormColumn(lv, l10n);
            final padded = Padding(
              padding: EdgeInsets.all(lv.padding),
              child: form,
            );

            if (lv.needsScroll) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: padded,
              );
            }

            return Column(
              children: [
                const Spacer(flex: 1),
                padded,
                const Spacer(flex: 1),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _loginFormColumn(_LoginViewportLayout lv, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final subtitleStyle = lv.denseInputs
        ? theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])
        : theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]);

    InputDecoration fieldDeco(InputDecoration base) {
      if (!lv.denseInputs) return base;
      return base.copyWith(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Icon(
              Icons.currency_bitcoin,
              size: lv.logoSize,
              color: theme.colorScheme.primary,
              semanticLabel: l10n.appTitle,
            ),
          ),
          SizedBox(height: lv.g(16)),
          Text(
            l10n.appTitle,
            style: (lv.useSmallerTitle
                    ? theme.textTheme.titleLarge
                    : theme.textTheme.headlineSmall)
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: lv.g(8)),
          Text(
            l10n.loginToAccount,
            style: subtitleStyle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: lv.g(22)),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            enabled: !_isLoading,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: fieldDeco(
              InputDecoration(
                labelText: l10n.email,
                hintText: 'user@example.com',
                prefixIcon: const Icon(Icons.email_outlined),
                border: const OutlineInputBorder(),
              ),
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
          SizedBox(height: lv.g(12)),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            enabled: !_isLoading,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: fieldDeco(
              InputDecoration(
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
          SizedBox(height: lv.g(14)),
          FilledButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: FilledButton.styleFrom(
              padding:
                  EdgeInsets.symmetric(vertical: lv.mainButtonVerticalPadding),
              visualDensity: lv.denseInputs
                  ? VisualDensity.compact
                  : VisualDensity.standard,
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
                : Text(
                    l10n.login,
                    style: TextStyle(fontSize: lv.denseInputs ? 15 : 16),
                  ),
          ),
          SizedBox(height: lv.g(14)),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Hoặc đăng nhập bằng ví',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          SizedBox(height: lv.g(8)),
          _WalletLoginButton(
            label: 'WalletConnect (QR)',
            icon: Icons.qr_code_2,
            color: const Color(0xFF5B8DEF),
            disabled: _isLoading,
            verticalPadding: lv.walletButtonVerticalPadding,
            onPressed: () =>
                context.read<AuthWalletFlowService>().openWalletConnectQrLogin(
                      context,
                      onSuccess: _onWalletAuthSuccess,
                    ),
          ),
          SizedBox(height: lv.g(8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  l10n.noAccount,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  visualDensity: lv.denseInputs ? VisualDensity.compact : null,
                  padding: lv.denseInputs
                      ? const EdgeInsets.symmetric(horizontal: 8)
                      : null,
                ),
                onPressed: _isLoading ? null : _navigateToRegister,
                child: Text(l10n.register),
              ),
            ],
          ),
          SizedBox(height: lv.g(4)),
          Center(
            child: TextButton(
              style: TextButton.styleFrom(
                visualDensity: lv.denseInputs ? VisualDensity.compact : null,
                tapTargetSize:
                    lv.denseInputs ? MaterialTapTargetSize.shrinkWrap : null,
              ),
              onPressed: _isLoading ? null : _exitToGuest,
              child: Text(l10n.continueAsGuest),
            ),
          ),
          if (kDebugMode) ...[
            SizedBox(height: lv.g(4)),
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.bug_report, size: 16),
                label: Text(l10n.testAccount),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange,
                  visualDensity: lv.denseInputs ? VisualDensity.compact : null,
                  tapTargetSize: lv.denseInputs
                      ? MaterialTapTargetSize.shrinkWrap
                      : null,
                ),
                onPressed: _isLoading ? null : _showDevAccounts,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
