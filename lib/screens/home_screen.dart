import 'package:flutter/material.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart';
import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/data/repositories/auth_repository_impl.dart';
import 'package:crypto_trading_app/domain/entities/user.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/screens/login_screen.dart';

/// Home Screen - Main application screen for authenticated users
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      // No token, navigate to login
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

          // If authentication failed, navigate to login
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
          message: '${AppLocalizations.of(context).error}: ${e.toString()}',
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
      builder: (context) => AlertDialog(
        title: Text(l10n.homeLogoutConfirmTitle),
        content: Text(l10n.homeLogoutConfirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.homeLogoutCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.homeLogoutConfirm),
          ),
        ],
      ),
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

  /// Generate initials from user's first and last name
  /// Falls back to email initial if names are empty
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
      // Use first character of email as fallback
      return user.email.isNotEmpty ? user.email[0].toUpperCase() : '?';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_currentUser == null) {
      final l10n = AppLocalizations.of(context);
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
              Text(_errorMessage ?? l10n.homeFailedToLoadUser),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _navigateToLogin,
                child: Text(l10n.homeGoToLogin),
              ),
            ],
          ),
        ),
      );
    }

    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeAppTitle),
        centerTitle: true,
        automaticallyImplyLeading: false, // Remove back button when used in MainScreen
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: l10n.logout,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // User Avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  _getInitials(_currentUser!),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Welcome Message
              Text(
                l10n.homeWelcomeBack,
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

              // Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.currency_bitcoin,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.homeCryptoPlatform,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.homeAuthReady,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Account Info
              const Divider(),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Member since'),
                subtitle: Text(
                  '${_currentUser!.createdAt.day}/${_currentUser!.createdAt.month}/${_currentUser!.createdAt.year}',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.update),
                title: Text(l10n.homeLastUpdated),
                subtitle: Text(
                  '${_currentUser!.updatedAt.day}/${_currentUser!.updatedAt.month}/${_currentUser!.updatedAt.year}',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

