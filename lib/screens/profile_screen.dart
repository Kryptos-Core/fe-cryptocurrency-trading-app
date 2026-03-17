import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart';
import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/data/repositories/auth_repository_impl.dart';
import 'package:crypto_trading_app/domain/entities/user.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/screens/login_screen.dart';
import 'package:crypto_trading_app/screens/currencies_list_screen.dart';
import 'package:crypto_trading_app/screens/settings_screen.dart';
import 'package:crypto_trading_app/screens/about_screen.dart';
import 'package:crypto_trading_app/core/enums/user_role.dart';
import 'package:crypto_trading_app/presentation/providers/managed_wallets_provider.dart';
import 'package:crypto_trading_app/presentation/screens/managed_wallets/managed_wallets_screen.dart';

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
            TextField(controller: first, decoration: const InputDecoration(labelText: 'First name')),
            const SizedBox(height: 12),
            TextField(controller: last, decoration: const InputDecoration(labelText: 'Last name')),
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

  Future<void> _requestSecurityChange(String changeType, {String? label, String? hint, bool isPassword = false}) async {
    if (_currentUser == null) return;
    if (!_currentUser!.twoFaEnabled) {
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

    final otpController = TextEditingController();
    final otpOk = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx).otpVerificationTitle),
        content: TextField(
          controller: otpController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(ctx).otpEnterCodeHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(ctx).cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(ctx).otpVerify),
          ),
        ],
      ),
    );
    if (otpOk != true || otpController.text.trim().length != 6) {
      return;
    }

    final controller = TextEditingController();
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(label ?? changeType),
        content: TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.of(ctx).cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Submit request')),
        ],
      ),
    );
    if (ok != true || controller.text.trim().isEmpty) return;
    final payload = isPassword ? {'password': controller.text.trim()} : {'email': controller.text.trim()};
    final result = await authRepo.requestSecurityChange(
      token: token,
      changeType: changeType,
      payload: payload,
      otpCode: otpController.text.trim(),
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
          message: AppLocalizations.of(context).requestSentPendingApproval,
          type: SnackBarType.success,
        );
        }
      },
    );
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

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // User Avatar (tap to change)
            GestureDetector(
              onTap: _pickAndUploadAvatar,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                backgroundImage: _currentUser!.avatarUrl != null && _currentUser!.avatarUrl!.isNotEmpty
                    ? (_currentUser!.avatarUrl!.startsWith('http')
                        ? NetworkImage(_currentUser!.avatarUrl!)
                        : null)
                    : null,
                child: _currentUser!.avatarUrl == null || _currentUser!.avatarUrl!.isEmpty
                    ? Text(
                        _getInitials(_currentUser!),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      )
                    : null,
              ),
            ),
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
              _currentUser!.fullName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _currentUser!.email,
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
                color: _currentUser!.isActive
                    ? Colors.green[50]
                    : Colors.red[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _currentUser!.isActive
                      ? Colors.green[300]!
                      : Colors.red[300]!,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _currentUser!.isActive
                        ? Icons.check_circle
                        : Icons.cancel,
                    size: 16,
                    color: _currentUser!.isActive
                        ? Colors.green[700]
                        : Colors.red[700],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _currentUser!.isActive ? l10n.active : l10n.inactive,
                    style: TextStyle(
                      color: _currentUser!.isActive
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
                '${_currentUser!.createdAt.day}/${_currentUser!.createdAt.month}/${_currentUser!.createdAt.year}',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.update),
              title: Text(l10n.lastUpdated),
              subtitle: Text(
                '${_currentUser!.updatedAt.day}/${_currentUser!.updatedAt.month}/${_currentUser!.updatedAt.year}',
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
            if (_currentUser!.twoFaEnabled) ...[
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: Text(l10n.profileChangeEmail),
                subtitle: Text(l10n.profileOtpAdminReviewRequired),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _requestSecurityChange(
                  'EMAIL_CHANGE',
                  label: 'New email',
                  hint: 'Enter new email',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: Text(l10n.profileChangePassword),
                subtitle: Text(l10n.profileOtpAdminReviewRequired),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _requestSecurityChange(
                  'PASSWORD_CHANGE',
                  label: 'New password',
                  hint: 'Min 8 characters',
                  isPassword: true,
                ),
              ),
            ] else
              ListTile(
                leading: const Icon(Icons.shield_outlined),
                title: Text(l10n.profileEnable2faFirstTitle),
                subtitle: Text(l10n.profileEnable2faFirstDesc),
                trailing: const Icon(Icons.chevron_right),
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
            // Additional Options
            if (UserRole.fromString(_currentUser!.role) == UserRole.riskOfficer)
              ListTile(
                leading: Icon(
                  Icons.account_balance_wallet,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Treasury Management'),
                subtitle: const Text('Manage company wallets & deposit settings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider<ManagedWalletsProvider>.value(
                        value: context.read<ManagedWalletsProvider>(),
                        child: const ManagedWalletsScreen(),
                      ),
                    ),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.currency_bitcoin),
              title: Text(l10n.currencies),
              subtitle: Text(l10n.viewAllCurrencies),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CurrenciesListScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(l10n.settings),
              subtitle: Text(l10n.appSettingsPreferences),
              trailing: const Icon(Icons.chevron_right),
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
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
    );
  }
}
