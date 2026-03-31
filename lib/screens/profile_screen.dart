import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart';
import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/core/utils/wallet_placeholder_email.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/data/repositories/auth_repository_impl.dart';
import 'package:crypto_trading_app/domain/entities/user.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/screens/login_screen.dart';
import 'package:crypto_trading_app/presentation/widgets/otp_verification_dialog.dart';
import 'package:crypto_trading_app/presentation/widgets/wallet_contact_email_verification_dialog.dart';
import 'package:crypto_trading_app/presentation/widgets/user_email_verified_mark.dart';
import 'package:crypto_trading_app/screens/settings_screen.dart';
import 'package:crypto_trading_app/screens/about_screen.dart';

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
    final token = tokenService.getAccessToken();

    if (token == null || token.isEmpty) {
      _navigateToLogin();
      return;
    }

    try {
      final authRepository = sl<AuthRepository>();
      final result = await authRepository.getCurrentUser(token);

      result.fold(
        (failure) {
          setState(() {
            _errorMessage = failure.message;
            _isLoading = false;
          });

          if (mounted) {
            showAppSnackBar(
              context,
              message: '${AppLocalizations.of(context).failedToLoadProfile}: ${failure.message}',
              type: SnackBarType.error,
              duration: const Duration(seconds: 3),
            );
          }

          if (failure is AuthenticationFailure) {
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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _handleLogout() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final l10nDialog = AppLocalizations.of(dialogContext);
        return AlertDialog(
          title: Text(l10nDialog.logout),
          content: Text(l10nDialog.areYouSureLogout),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10nDialog.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10nDialog.logout),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final tokenService = sl<TokenService>();
      await tokenService.clearTokens();
      
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
    final xFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, imageQuality: 85);
    if (xFile == null || !mounted) return;
    final bytes = await xFile.readAsBytes();
    final ext = xFile.name.split('.').last.toLowerCase();
    final mime = ext == 'jpg' || ext == 'jpeg' ? 'image/jpeg' : ext == 'png' ? 'image/png' : ext == 'webp' ? 'image/webp' : 'image/jpeg';
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
          showAppSnackBar(context, message: f.message, type: SnackBarType.error);
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
            TextField(controller: first, decoration: InputDecoration(labelText: AppLocalizations.of(ctx).profileFirstName)),
            const SizedBox(height: 12),
            TextField(controller: last, decoration: InputDecoration(labelText: AppLocalizations.of(ctx).profileLastName)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.of(ctx).cancel)),
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
          showAppSnackBar(context, message: f.message, type: SnackBarType.error);
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

  /// Đổi mật khẩu trực tiếp (không cần xét duyệt)
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

    final otpSent = await authRepo.send2faOtp(token);
    final canContinue = otpSent.fold((f) {
      if (mounted) showAppSnackBar(context, message: f.message, type: SnackBarType.error);
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

    final otp = await OtpVerificationDialog.show(context, repo: authRepo, token: token);
    if (otp == null || otp.length != 6) return;

    final newPassword = await _showChangePasswordDialog();
    if (newPassword == null || newPassword.isEmpty) return;

    final result = await authRepo.changePassword(
      token: token,
      newPassword: newPassword,
      otpCode: otp,
    );
    result.fold(
      (f) {
        if (mounted) showAppSnackBar(context, message: f.message, type: SnackBarType.error);
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
          showAppSnackBar(context, message: f.message, type: SnackBarType.error);
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

      final otp = await OtpVerificationDialog.show(context, repo: authRepo, token: token);
      if (otp == null || otp.length != 6) return;

      final newEmail =
          await _showChangeEmailDialog(label: 'New email', hint: 'Enter new email');
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
            showAppSnackBar(context, message: f.message, type: SnackBarType.error);
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
        title: Text(label ?? 'New email'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(hintText: hint ?? 'Enter new email'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(ctx).cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Submit request'),
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
                child: const Text('Submit request'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // User Avatar (tap to change)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _pickAndUploadAvatar,
                child: CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                    ? (user.avatarUrl!.startsWith('http')
                        ? NetworkImage(user.avatarUrl!)
                        : null)
                    : null,
                child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                    ? Text(
                        _getInitials(user),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Welcome Message
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
            const SizedBox(height: 32),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: user.isActive
                    ? Colors.green[50]
                    : Colors.red[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: user.isActive
                      ? Colors.green[300]!
                      : Colors.red[300]!,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    user.isActive
                        ? Icons.check_circle
                        : Icons.cancel,
                    size: 16,
                    color: user.isActive
                        ? Colors.green[700]
                        : Colors.red[700],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user.isActive ? l10n.active : l10n.inactive,
                    style: TextStyle(
                      color: user.isActive
                          ? Colors.green[700]
                          : Colors.red[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Account Info
            const Divider(),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(l10n.memberSince),
              subtitle: Text(
                '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.update),
              title: Text(l10n.lastUpdated),
              subtitle: Text(
                '${user.updatedAt.day}/${user.updatedAt.month}/${user.updatedAt.year}',
              ),
            ),
            const Divider(),
            // Security (requires approval)
            Text(
              l10n.profileSecurityRequiresApproval,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
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
            const Divider(),
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
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
              title: Text(l10n.logout, style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600)),
              mouseCursor: SystemMouseCursors.click,
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
    );
  }
}
