import 'package:flutter/material.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart';
import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/core/services/toast_service.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/domain/usecases/auth_usecases.dart';
import 'package:crypto_trading_app/domain/entities/user.dart';
import 'package:crypto_trading_app/screens/login_screen.dart';
import 'package:crypto_trading_app/screens/currencies_list_screen.dart';

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
      final getCurrentUserUseCase = sl<GetCurrentUserUseCase>();
      final result = await getCurrentUserUseCase(token);

      result.fold(
        (failure) {
          setState(() {
            _errorMessage = failure.message;
            _isLoading = false;
          });

          if (mounted) {
            ToastService().show(
              context,
              message: 'Failed to load profile: ${failure.message}',
              type: ToastType.error,
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
        ToastService().show(
          context,
          message: 'Error: ${e.toString()}',
          type: ToastType.error,
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final tokenService = sl<TokenService>();
      await tokenService.clearTokens();
      
      if (mounted) {
        ToastService().show(
          context,
          message: 'Logged out successfully',
          type: ToastType.success,
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
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
              Text(_errorMessage ?? 'Failed to load user'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _navigateToLogin,
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
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
              'Welcome back,',
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
                    _currentUser!.isActive ? 'Active' : 'Inactive',
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
              title: const Text('Member since'),
              subtitle: Text(
                '${_currentUser!.createdAt.day}/${_currentUser!.createdAt.month}/${_currentUser!.createdAt.year}',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.update),
              title: const Text('Last updated'),
              subtitle: Text(
                '${_currentUser!.updatedAt.day}/${_currentUser!.updatedAt.month}/${_currentUser!.updatedAt.year}',
              ),
            ),
            const Divider(),
            // Additional Options
            ListTile(
              leading: const Icon(Icons.currency_bitcoin),
              title: const Text('Currencies'),
              subtitle: const Text('View all available currencies'),
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
              title: const Text('Settings'),
              subtitle: const Text('App settings and preferences'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to settings
              },
            ),
          ],
        ),
      ),
    );
  }
}
