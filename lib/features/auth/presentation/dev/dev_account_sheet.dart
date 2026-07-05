import 'package:flutter/material.dart';

import 'package:crypto_trading_app/features/auth/presentation/dev/dev_test_accounts.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';

class DevAccountSheet extends StatefulWidget {
  final List<DevTestAccount> accounts;
  final void Function(String email, String password) onLogin;

  const DevAccountSheet({
    super.key,
    required this.accounts,
    required this.onLogin,
  });

  @override
  State<DevAccountSheet> createState() => _DevAccountSheetState();
}

class _DevAccountSheetState extends State<DevAccountSheet> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      return;
    }
    setState(() => _isLoading = true);
    widget.onLogin(_emailController.text.trim(), _passwordController.text);
  }

  void _fillAccount(DevTestAccount account) {
    setState(() {
      _emailController.text = account.email;
      _passwordController.text = account.password;
      _obscurePassword = false; // reveal so user can see and edit
    });
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'ADMIN':
        return Colors.red;
      case 'TRADER':
        return Colors.blue;
      case 'RISK_OFFICER':
        return Colors.orange;
      case 'SUPPORT_AGENT':
        return Colors.green;
      case 'MARKET_MAKER':
        return Colors.purple;
      case 'FINANCE_MANAGER':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _roleIcon(String role) {
    switch (role) {
      case 'ADMIN':
        return Icons.admin_panel_settings;
      case 'TRADER':
        return Icons.trending_up;
      case 'RISK_OFFICER':
        return Icons.shield;
      case 'SUPPORT_AGENT':
        return Icons.support_agent;
      case 'MARKET_MAKER':
        return Icons.show_chart;
      case 'FINANCE_MANAGER':
        return Icons.account_balance;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.bug_report, color: Colors.orange, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    l10n.testAccountDev,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    tooltip: _obscurePassword ? l10n.hidePassword : l10n.showPassword,
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.edit_note,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.youCanEditCredentialsAbove,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.orange[800],
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: l10n.email,
                              prefixIcon: const Icon(Icons.email_outlined, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(
                                  color: Colors.orange.withValues(alpha: 0.5),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(
                                  color: Colors.orange.withValues(alpha: 0.5),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(
                                  color: Colors.orange,
                                  width: 2,
                                ),
                              ),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Clear',
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => setState(
                            () => _emailController.clear(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: l10n.password,
                              prefixIcon: const Icon(Icons.lock_outlined, size: 20),
                              border: const OutlineInputBorder(),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            textInputAction: TextInputAction.done,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Clear',
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => setState(
                            () => _passwordController.clear(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isLoading ? null : _handleLogin,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.login, size: 18),
                        label: Text(
                          _isLoading ? l10n.loggingIn : l10n.login,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      l10n.selectAccount,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      l10n.youCanEditCredentialsAbove,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  shrinkWrap: true,
                  itemCount: widget.accounts.length,
                  itemBuilder: (context, index) {
                    final account = widget.accounts[index];
                    final isSelected =
                        _emailController.text == account.email &&
                            _passwordController.text == account.password;
                    return InkWell(
                      onTap: () => _fillAccount(account),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: isSelected
                            ? BoxDecoration(
                                color:
                                    _roleColor(account.role).withValues(alpha: 0.08),
                                border: Border(
                                  left: BorderSide(
                                    color: _roleColor(account.role),
                                    width: 3,
                                  ),
                                ),
                              )
                            : null,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor:
                                  _roleColor(account.role).withValues(alpha: 0.15),
                              child: Icon(
                                _roleIcon(account.role),
                                size: 16,
                                color: _roleColor(account.role),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    account.displayName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    account.email,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _roleColor(account.role)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    account.role,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _roleColor(account.role),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _obscurePassword
                                      ? '\u2022' * 12
                                      : account.password,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontFamily: 'monospace',
                                        color: Colors.grey[700],
                                      ),
                                ),
                              ],
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 6),
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: _roleColor(account.role),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
