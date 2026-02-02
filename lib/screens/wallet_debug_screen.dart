import 'package:flutter/material.dart';

/// Debug screen to verify JWT user and token info
class WalletDebugScreen extends StatelessWidget {
  const WalletDebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet Debug Info'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'User Info',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Check console logs for:\n🐛 Data: {user_id: 2, email: yen@example.com, ...}\n\nYour JWT user_id should match wallet seed.',
                      style: TextStyle(
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
              'Database seed matches this user ID?',
              'Run: SELECT user_id, currency_id, available, frozen FROM wallets WHERE user_id = 2;',
            ),
            _buildCheckItem(
              'Currency mapping correct?',
              'Run: SELECT currency_id, symbol FROM currencies WHERE symbol IN (\'BTC\',\'ETH\',\'USDT\',\'BNB\');',
            ),
            _buildCheckItem(
              'Backend .env database correct?',
              'Ensure backend is connected to the same DB where you ran seed-wallets.sql',
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              '📝 Expected Seed for User 2:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '''• currencyId=1 (BTC): available 0.25
• currencyId=2 (ETH): available 8
• currencyId=3 (BNB): available 120
• currencyId=4 (SOL): available 150''',
              style: TextStyle(fontFamily: 'monospace'),
            ),
          ],
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
