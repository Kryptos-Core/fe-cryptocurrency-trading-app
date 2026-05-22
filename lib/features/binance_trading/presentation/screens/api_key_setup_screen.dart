import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../application/providers/binance_credentials_provider.dart';

class ApiKeySetupScreen extends StatefulWidget {
  const ApiKeySetupScreen({super.key});

  @override
  State<ApiKeySetupScreen> createState() => _ApiKeySetupScreenState();
}

class _ApiKeySetupScreenState extends State<ApiKeySetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController(text: 'Main Spot Account');
  final _apiKeyController = TextEditingController();
  final _apiSecretController = TextEditingController();

  bool _obscureApiKey = true;
  bool _obscureApiSecret = true;
  bool _spotPermission = true;
  bool _futuresPermission = false;
  bool _isTestnet = false;

  @override
  void dispose() {
    _labelController.dispose();
    _apiKeyController.dispose();
    _apiSecretController.dispose();
    super.dispose();
  }

  Future<void> _launchBinanceGuide() async {
    final url = Uri.parse('https://www.binance.com/en/support/faq/how-to-create-api-keys-on-binance-115000140832');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  List<String> _buildPermissions() {
    final perms = <String>[];
    if (_spotPermission) perms.add('SPOT');
    if (_futuresPermission) perms.add('FUTURES');
    return perms.isEmpty ? ['SPOT'] : perms;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Binance API'),
        elevation: 0,
      ),
      body: Consumer<BinanceCredentialsProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Label',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _labelController,
                            decoration: const InputDecoration(
                              hintText: 'e.g. Main Spot Account',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Label is required'
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'API Key',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _apiKeyController,
                            obscureText: _obscureApiKey,
                            decoration: InputDecoration(
                              hintText: 'Enter your Binance API Key',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureApiKey
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () =>
                                    setState(() => _obscureApiKey = !_obscureApiKey),
                              ),
                            ),
                            validator: provider.validateApiKey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'API Secret',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _apiSecretController,
                            obscureText: _obscureApiSecret,
                            decoration: InputDecoration(
                              hintText: 'Enter your Binance API Secret',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureApiSecret
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () => setState(
                                    () => _obscureApiSecret = !_obscureApiSecret),
                              ),
                            ),
                            validator: provider.validateApiSecret,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Permissions',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          CheckboxListTile(
                            title: const Text('Spot Trading'),
                            subtitle: const Text('Enable spot market trading'),
                            value: _spotPermission,
                            onChanged: (v) =>
                                setState(() => _spotPermission = v ?? true),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                          CheckboxListTile(
                            title: const Text('Futures Trading'),
                            subtitle: const Text('Enable USD-M futures trading'),
                            value: _futuresPermission,
                            onChanged: (v) =>
                                setState(() => _futuresPermission = v ?? false),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                          const Divider(),
                          CheckboxListTile(
                            title: const Text('Use Testnet'),
                            subtitle: const Text(
                                'Connect to Binance testnet instead of mainnet'),
                            value: _isTestnet,
                            onChanged: (v) =>
                                setState(() => _isTestnet = v ?? false),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Theme.of(context).colorScheme.error,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'API Key Setup Guide',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'When creating your API key on Binance:',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          _buildBullet('Disable all Withdrawal permissions'),
                          _buildBullet('Enable: Spot/Futures Trading'),
                          _buildBullet('Enable: Read-only market data'),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: _launchBinanceGuide,
                            icon: const Icon(Icons.open_in_new, size: 16),
                            label: const Text('View Binance API Guide'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (provider.lastTestResult != null)
                    _buildTestResultBanner(provider),
                  if (provider.error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: provider.isSaving || provider.isTesting
                        ? null
                        : () => _testConnection(provider),
                    child: provider.isTesting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Test Connection'),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: provider.isSaving || provider.isTesting
                        ? null
                        : () => _saveCredentials(provider),
                    child: provider.isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save API Key'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('  •  '),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildTestResultBanner(BinanceCredentialsProvider provider) {
    final success = provider.lastTestResult == true;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: success
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: success ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            success ? Icons.check_circle : Icons.error,
            color: success ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              success
                  ? 'Connection successful!'
                  : 'Connection failed: ${provider.lastTestError ?? "Unknown error"}',
              style: TextStyle(
                color: success ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _testConnection(BinanceCredentialsProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final result = await provider.saveCredentials(
      apiKey: _apiKeyController.text.trim(),
      apiSecret: _apiSecretController.text.trim(),
      label: _labelController.text.trim(),
      permissions: _buildPermissions(),
      testnet: _isTestnet,
    );

    if (result.success && mounted) {
      provider.clearError();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection test passed! Credentials saved.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _saveCredentials(BinanceCredentialsProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final result = await provider.saveCredentials(
      apiKey: _apiKeyController.text.trim(),
      apiSecret: _apiSecretController.text.trim(),
      label: _labelController.text.trim(),
      permissions: _buildPermissions(),
      testnet: _isTestnet,
    );

    if (mounted) {
      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API Key saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${result.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
