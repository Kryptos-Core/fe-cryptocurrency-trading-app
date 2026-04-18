import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/auth/presentation/providers/auth_provider.dart';

/// Debug screen to verify JWT user and token info
class WalletDebugScreen extends StatelessWidget {
  const WalletDebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.walletDebugTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            final u = auth.currentUser;
            final userHint = u != null
                ? 'Logged in as: ${u.email}\nUser id (JWT): ${u.id}\nUse this id in SQL / API checks below.'
                : 'Not signed in. Log in to see your user id and email from the session.';
            final walletSql = u != null
                ? "SELECT user_id, currency_id, available, frozen FROM wallets WHERE user_id = '${u.id}';"
                : 'Sign in first; then query wallets with your user_id from the users table or JWT.';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'User Info',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          userHint,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  '⚠️ Debug Checklist:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildCheckItem(
                  'Wallet rows for this user?',
                  walletSql,
                ),
                _buildCheckItem(
                  'Currency mapping correct?',
                  r"SELECT currency_id, symbol FROM currencies WHERE symbol IN ('BTC','ETH','USDT','BNB');",
                ),
                _buildCheckItem(
                  'Backend .env database correct?',
                  'Ensure the API uses the same database you inspect in SQL.',
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  '📝 Balances',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  u != null
                      ? 'Use the app Wallets screen or GET /wallets (with your token) — do not rely on fixed seed numbers here.'
                      : 'Sign in to verify balances in the app or via the API.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCheckItem(String title, String detail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              detail,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
