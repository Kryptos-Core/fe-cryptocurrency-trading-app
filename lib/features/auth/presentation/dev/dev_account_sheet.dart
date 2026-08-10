import 'package:flutter/material.dart';

import 'package:crypto_trading_app/features/auth/domain/entities/dev_user_pick.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';

/// Bottom-sheet picker for the sandbox-only "Đăng nhập bằng tài khoản test" UI.
///
/// Receives a list of [DevUserPick] entities (loaded from the backend via
/// `GET /auth/sandbox-users` or, on failure, the hardcoded fallback).
/// On tap of a row, calls [onLoginEmailOnly] with the picked email — the
/// parent then drives [AuthProvider.loginEmailOnly] (no password required).
class DevAccountSheet extends StatefulWidget {
  final List<DevUserPick> accounts;
  final bool isLoading;
  final String? loadError;
  final Future<void> Function() onReload;
  final Future<void> Function(String email) onLoginEmailOnly;

  const DevAccountSheet({
    super.key,
    required this.accounts,
    required this.isLoading,
    required this.loadError,
    required this.onReload,
    required this.onLoginEmailOnly,
  });

  @override
  State<DevAccountSheet> createState() => _DevAccountSheetState();
}

class _DevAccountSheetState extends State<DevAccountSheet> {
  bool _isSubmitting = false;

  Future<void> _handleLogin(DevUserPick account) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await widget.onLoginEmailOnly(account.email);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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
                  Expanded(
                    child: Text(
                      l10n.testAccountDev,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800],
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    tooltip: 'Reload',
                    onPressed: widget.isLoading ? null : widget.onReload,
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
                        Icons.password,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Sandbox: mật khẩu bị bỏ qua — click tài khoản để đăng nhập.',
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
              if (widget.loadError != null) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          size: 16, color: Colors.redAccent),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.loadError!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),
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
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: widget.isLoading && widget.accounts.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        controller: scrollController,
                        shrinkWrap: true,
                        itemCount: widget.accounts.length,
                        itemBuilder: (context, index) {
                          final account = widget.accounts[index];
                          return InkWell(
                            onTap: _isSubmitting
                                ? null
                                : () => _handleLogin(account),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: _roleColor(account.role)
                                        .withValues(alpha: 0.15),
                                    child: Icon(
                                      _roleIcon(account.role),
                                      size: 16,
                                      color: _roleColor(account.role),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          account.displayName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        Text(
                                          account.email,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Colors.grey[600],
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                                  if (_isSubmitting) ...[
                                    const SizedBox(width: 8),
                                    const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
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
