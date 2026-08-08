import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/app/router/app_routes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crypto_trading_app/app/di/injection_container.dart';
import 'package:crypto_trading_app/core/responsive/app_responsive.dart';
import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/core/utils/wallet_placeholder_email.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:crypto_trading_app/features/user/domain/entities/user.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/features/auth/presentation/widgets/otp_verification_dialog.dart';
import 'package:crypto_trading_app/features/treasury/presentation/widgets/wallet_contact_email_verification_dialog.dart';
import 'package:crypto_trading_app/core/widgets/user_email_verified_mark.dart';
import 'package:crypto_trading_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:crypto_trading_app/features/home/presentation/screens/about_screen.dart';

/// Profile Screen - User account information
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  /// Merge local profile with [AuthProvider.currentUser] so toggling 2FA in
  /// Settings updates this screen without a full refetch.
  User _mergeProfileWithAuth(User local, User? auth) {
    if (auth == null || auth.id != local.id) return local;
    final emailVerified = context.read<AuthProvider>().isEmailVerified;
    return local.copyWith(
      twoFaEnabled: auth.twoFaEnabled,
      emailVerified: emailVerified,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final tokenService = sl<TokenService>();
    var token = tokenService.getAccessToken();

    if (token == null || token.isEmpty) {
      await Future<void>.delayed(Duration.zero);
      token = tokenService.getAccessToken();
    }

    if (token == null || token.isEmpty) {
      if (!mounted) return;
      if (context.read<AuthProvider>().isAuthenticated) {
        await context.read<AuthProvider>().logout();
      }
      _navigateToLogin();
      return;
    }

    try {
      final authRepository = sl<AuthRepository>();
      final result = await authRepository.getCurrentUser(token);

      result.fold(
        (failure) async {
          setState(() {
            _errorMessage = failure.message;
            _isLoading = false;
          });

          if (mounted) {
            showAppSnackBar(
              context,
              message:
                  '${AppLocalizations.of(context).failedToLoadProfile}: ${failure.message}',
              type: SnackBarType.error,
              duration: const Duration(seconds: 3),
            );
          }

          if (failure is AuthenticationFailure) {
            if (mounted && context.read<AuthProvider>().isAuthenticated) {
              await context.read<AuthProvider>().logout();
            }
            Future.delayed(const Duration(seconds: 1), () {
              _navigateToLogin();
            });
          }
        },
        (user) {
          setState(() {
            _currentUser = user;
            _isLoading = false;
          });
          if (mounted) {
            context.read<AuthProvider>().updateCurrentUser(user);
          }
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      if (mounted) {
        showAppSnackBar(
          context,
          message: 'Error: ${e.toString()}',
          type: SnackBarType.error,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  void _navigateToLogin() {
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  Future<void> _handleLogout() async {
    final l10n = AppLocalizations.of(context);
    final authProvider = context.read<AuthProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final l10nDialog = AppLocalizations.of(dialogContext);
        return AlertDialog(
          title: Text(l10nDialog.logout),
          content: Text(l10nDialog.areYouSureLogout),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10nDialog.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10nDialog.logout),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await authProvider.logout();

      if (mounted) {
        showAppSnackBar(
          context,
          message: l10n.loggedOutSuccess,
          type: SnackBarType.success,
          duration: const Duration(seconds: 1),
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          _navigateToLogin();
        });
      }
    }
  }

  String _getInitials(User user) {
    final firstName = user.firstName.trim();
    final lastName = user.lastName.trim();

    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return firstName[0].toUpperCase() + lastName[0].toUpperCase();
    } else if (firstName.isNotEmpty) {
      return firstName[0].toUpperCase();
    } else if (lastName.isNotEmpty) {
      return lastName[0].toUpperCase();
    } else {
      return user.email.isNotEmpty ? user.email[0].toUpperCase() : '?';
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final token = sl<TokenService>().getAccessToken();
    if (token == null || token.isEmpty) return;
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
        source: ImageSource.gallery, maxWidth: 512, imageQuality: 85);
    if (xFile == null || !mounted) return;
    final bytes = await xFile.readAsBytes();
    final ext = xFile.name.split('.').last.toLowerCase();
    final mime = ext == 'jpg' || ext == 'jpeg'
        ? 'image/jpeg'
        : ext == 'png'
            ? 'image/png'
            : ext == 'webp'
                ? 'image/webp'
                : 'image/jpeg';
    final authRepo = sl<AuthRepository>();
    final result = await authRepo.uploadAvatar(
      token: token,
      fileBytes: bytes,
      fileName: xFile.name,
      mimeType: mime,
    );
    result.fold(
      (f) {
        if (mounted) {
          showAppSnackBar(context,
              message: f.message, type: SnackBarType.error);
        }
      },
      (user) {
        setState(() => _currentUser = user);
        context.read<AuthProvider>().updateCurrentUser(user);
        if (mounted) {
          showAppSnackBar(
            context,
            message: AppLocalizations.of(context).profileAvatarUpdated,
            type: SnackBarType.success,
          );
        }
      },
    );
  }

  Future<void> _editProfileBasic() async {
    if (_currentUser == null) return;
    final first = TextEditingController(text: _currentUser!.firstName);
    final last = TextEditingController(text: _currentUser!.lastName);
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx).profileEditName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: first,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(ctx).profileFirstName)),
            const SizedBox(height: 12),
            TextField(
                controller: last,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(ctx).profileLastName)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppLocalizations.of(ctx).cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(ctx).save),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final token = sl<TokenService>().getAccessToken();
    if (token == null) return;
    final result = await sl<AuthRepository>().updateProfileBasic(
      token: token,
      firstName: first.text.trim().isEmpty ? null : first.text.trim(),
      lastName: last.text.trim().isEmpty ? null : last.text.trim(),
    );
    result.fold(
      (f) {
        if (mounted) {
          showAppSnackBar(context,
              message: f.message, type: SnackBarType.error);
        }
      },
      (user) {
        setState(() => _currentUser = user);
        context.read<AuthProvider>().updateCurrentUser(user);
        if (mounted) {
          showAppSnackBar(
            context,
            message: AppLocalizations.of(context).profileUpdated,
            type: SnackBarType.success,
          );
        }
      },
    );
  }

  /// Đổi mật khẩu trực tiếp (không cần xét duyệt).
  /// Khi emailVerificationRequired = false (admin đã tắt), bỏ qua bước OTP.
  Future<void> _requestPasswordChange() async {
    if (_currentUser == null) return;
    final effective = _mergeProfileWithAuth(
        _currentUser!, context.read<AuthProvider>().currentUser);
    if (isWalletPlaceholderEmail(effective.email)) {
      if (mounted) {
        showAppSnackBar(
          context,
          message: AppLocalizations.of(context).contactEmailRequiredForOtpShort,
          type: SnackBarType.error,
        );
      }
      return;
    }
    if (!effective.twoFaEnabled) {
      if (mounted) {
        showAppSnackBar(
          context,
          message: AppLocalizations.of(context).otpRequiredEnable2faFirst,
          type: SnackBarType.error,
        );
      }
      return;
    }

    final token = sl<TokenService>().getAccessToken();
    if (token == null) return;
    final authRepo = sl<AuthRepository>();
    final authProvider = context.read<AuthProvider>();

    // Bỏ qua OTP khi admin đã tắt email verification.
    final emailVerificationRequired = authProvider.emailVerificationRequired;
    String? otpCode;

    if (emailVerificationRequired) {
      final otpSent = await authRepo.send2faOtp(token);
      final canContinue = otpSent.fold((f) {
        if (mounted) {
          showAppSnackBar(context, message: f.message, type: SnackBarType.error);
        }
        return false;
      }, (_) => true);
      if (!canContinue) return;

      if (mounted) {
        showAppSnackBar(
          context,
          message: AppLocalizations.of(context).otpSentToEmail,
          type: SnackBarType.success,
        );
      }

      if (!mounted) return;
      otpCode = await OtpVerificationDialog.show(context, repo: authRepo, token: token);
      if (otpCode == null || otpCode.length != 6) return;
    }

    final newPassword = await _showChangePasswordDialog();
    if (newPassword == null || newPassword.isEmpty) return;

    final result = await authRepo.changePassword(
      token: token,
      newPassword: newPassword,
      otpCode: otpCode,
    );
    result.fold(
      (f) {
        if (mounted) {
          showAppSnackBar(context,
              message: f.message, type: SnackBarType.error);
        }
      },
      (_) {
        if (mounted) {
          showAppSnackBar(
            context,
            message: AppLocalizations.of(context).profilePasswordChanged,
            type: SnackBarType.success,
          );
        }
      },
    );
  }

  /// Gửi yêu cầu thay đổi email (cần xét duyệt)
  Future<void> _requestEmailChange() async {
    if (_currentUser == null) return;
    final l10n = AppLocalizations.of(context);
    final effective = _mergeProfileWithAuth(
        _currentUser!, context.read<AuthProvider>().currentUser);
    final walletPlaceholder = isWalletPlaceholderEmail(effective.email);

    final token = sl<TokenService>().getAccessToken();
    if (token == null) return;
    final authRepo = sl<AuthRepository>();

    if (!walletPlaceholder) {
      if (!effective.twoFaEnabled) {
        if (mounted) {
          showAppSnackBar(
            context,
            message: l10n.otpRequiredEnable2faFirst,
            type: SnackBarType.error,
          );
        }
        return;
      }

      final otpSent = await authRepo.send2faOtp(token);
      final canContinue = otpSent.fold((f) {
        if (mounted) {
          showAppSnackBar(context,
              message: f.message, type: SnackBarType.error);
        }
        return false;
      }, (_) => true);
      if (!canContinue) return;

      if (mounted) {
        showAppSnackBar(
          context,
          message: l10n.otpSentToEmail,
          type: SnackBarType.success,
        );
      }
      if (!mounted) return;

      final otp = await OtpVerificationDialog.show(context,
          repo: authRepo, token: token);
      if (otp == null || otp.length != 6) return;

      final newEmail = await _showChangeEmailDialog(
        label: l10n.profileChangeEmail,
        hint: l10n.registerEmailHint,
      );
      if (newEmail == null || newEmail.isEmpty) return;

      final result = await authRepo.requestSecurityChange(
        token: token,
        changeType: 'EMAIL_CHANGE',
        payload: {'email': newEmail},
        otpCode: otp,
      );
      result.fold(
        (f) {
          if (mounted) {
            showAppSnackBar(context,
                message: f.message, type: SnackBarType.error);
          }
        },
        (_) {
          if (mounted) {
            showAppSnackBar(
              context,
              message: l10n.requestSentPendingApproval,
              type: SnackBarType.success,
            );
          }
        },
      );
      return;
    }

    // Đăng nhập ví: OTP gửi thẳng tới email mới, cập nhật ngay sau khi xác minh.
    final updated = await WalletContactEmailVerificationDialog.show(
      context,
      authRepo: authRepo,
      token: token,
    );
    if (!mounted || updated == null) return;
    setState(() => _currentUser = updated);
    context.read<AuthProvider>().updateCurrentUser(updated);
    showAppSnackBar(
      context,
      message: l10n.contactEmailUpdatedSuccess,
      type: SnackBarType.success,
    );
  }

  Future<String?> _showChangeEmailDialog({String? label, String? hint}) async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(label ?? AppLocalizations.of(ctx).profileChangeEmail),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: hint ?? AppLocalizations.of(ctx).registerEmailHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(ctx).cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(ctx).submit),
          ),
        ],
      ),
    );
    if (ok != true || controller.text.trim().isEmpty) return null;
    return controller.text.trim();
  }

  Future<String?> _showChangePasswordDialog() async {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    String? errorMsg;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          final l10n = AppLocalizations.of(ctx);
          return AlertDialog(
            title: Text(l10n.profileChangePassword),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: l10n.passwordMinLength,
                    errorText: errorMsg,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: l10n.confirmPassword,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () {
                  final pwd = passwordController.text;
                  final confirm = confirmController.text;
                  if (pwd.length < 8) {
                    setState(() => errorMsg = l10n.passwordMinLength);
                    return;
                  }
                  if (pwd != confirm) {
                    setState(() => errorMsg = l10n.registerPasswordsNoMatch);
                    return;
                  }
                  Navigator.pop(ctx, true);
                },
                child: Text(l10n.submit),
              ),
            ],
          );
        },
      ),
    );
    if (ok != true) return null;
    return passwordController.text.trim();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(_errorMessage ?? l10n.failedToLoadProfile),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _navigateToLogin,
                child: Text(l10n.goToLogin),
              ),
            ],
          ),
        ),
      );
    }

    final authUser = context.watch<AuthProvider>().currentUser;
    final user = _mergeProfileWithAuth(_currentUser!, authUser);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= AppBreakpoints.compact;
          return _buildBody(context, l10n, user, isWide);
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    User user,
    bool isWide,
  ) {
    if (isWide) {
      return _buildWideLayout(context, l10n, user);
    }
    return _buildCompactLayout(context, l10n, user);
  }

  Widget _buildCompactLayout(
    BuildContext context,
    AppLocalizations l10n,
    User user,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildAvatar(context, l10n, user),
          const SizedBox(height: 24),
          _buildWelcomeSection(context, l10n, user),
          const SizedBox(height: 24),
          _buildStatusBadge(context, l10n, user),
          const SizedBox(height: 24),
          _buildSecuritySection(context, l10n, user),
          const SizedBox(height: 16),
          _buildNavigationSection(context, l10n),
          const SizedBox(height: 24),
          _buildLogoutButton(context, l10n),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildWideLayout(
    BuildContext context,
    AppLocalizations l10n,
    User user,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column: Avatar + Welcome
          Expanded(
            flex: 1,
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildAvatar(context, l10n, user),
                const SizedBox(height: 16),
                _buildWelcomeSection(context, l10n, user),
                const SizedBox(height: 16),
                _buildStatusBadge(context, l10n, user),
              ],
            ),
          ),
          const SizedBox(width: 48),
          // Right column: Security + Navigation
          Expanded(
            flex: 1,
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildSecuritySection(context, l10n, user),
                const SizedBox(height: 16),
                _buildNavigationSection(context, l10n),
                const SizedBox(height: 24),
                _buildLogoutButton(context, l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(
    BuildContext context,
    AppLocalizations l10n,
    User user,
  ) {
    return Column(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _pickAndUploadAvatar,
            child: CircleAvatar(
              radius: 60,
              backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
              backgroundImage:
                  user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                      ? (user.avatarUrl!.startsWith('http')
                          ? NetworkImage(user.avatarUrl!)
                          : null)
                      : null,
              child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                  ? Text(
                      _getInitials(user),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer,
                      ),
                    )
                  : null,
            ),
          ),
        ),
        UserEmailVerifiedMark(verified: user.emailVerified),
        const SizedBox(height: 8),
        Text(
          l10n.profileTapToChangeAvatar,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(
    BuildContext context,
    AppLocalizations l10n,
    User user,
  ) {
    return Column(
      children: [
        Text(
          l10n.welcomeBack,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 8),
        Text(
          user.fullName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          user.email,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _editProfileBasic,
          icon: const Icon(Icons.edit, size: 18),
          label: Text(l10n.profileEditName),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(
    BuildContext context,
    AppLocalizations l10n,
    User user,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: user.isActive ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: user.isActive ? Colors.green[300]! : Colors.red[300]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            user.isActive ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: user.isActive ? Colors.green[700] : Colors.red[700],
          ),
          const SizedBox(width: 8),
          Text(
            user.isActive ? l10n.active : l10n.inactive,
            style: TextStyle(
              color: user.isActive ? Colors.green[700] : Colors.red[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection(
    BuildContext context,
    AppLocalizations l10n,
    User user,
  ) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.profileSecurityRequiresApproval,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          if (user.twoFaEnabled) ...[
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: Text(l10n.profileChangeEmail),
              subtitle: Text(l10n.profileOtpAdminReviewRequired),
              trailing: const Icon(Icons.chevron_right),
              mouseCursor: SystemMouseCursors.click,
              onTap: _requestEmailChange,
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: Text(l10n.profileChangePassword),
              subtitle: Text(l10n.profileChangePasswordDirect),
              trailing: const Icon(Icons.chevron_right),
              mouseCursor: SystemMouseCursors.click,
              onTap: _requestPasswordChange,
            ),
          ] else
            ListTile(
              leading: const Icon(Icons.shield_outlined),
              title: Text(l10n.profileEnable2faFirstTitle),
              subtitle: Text(l10n.profileEnable2faFirstDesc),
              trailing: const Icon(Icons.chevron_right),
              mouseCursor: SystemMouseCursors.click,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationSection(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(l10n.settings),
            subtitle: Text(l10n.appSettingsPreferences),
            trailing: const Icon(Icons.chevron_right),
            mouseCursor: SystemMouseCursors.click,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.aboutTitle),
            subtitle: Text(l10n.aboutAppTileSubtitle),
            trailing: const Icon(Icons.chevron_right),
            mouseCursor: SystemMouseCursors.click,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: ListTile(
        leading: Icon(Icons.logout,
            color: Theme.of(context).colorScheme.error),
        title: Text(l10n.logout,
            style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600)),
        mouseCursor: SystemMouseCursors.click,
        onTap: _handleLogout,
      ),
    );
  }
}
