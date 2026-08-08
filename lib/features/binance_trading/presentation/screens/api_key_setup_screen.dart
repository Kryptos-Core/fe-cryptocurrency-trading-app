import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.binanceApiKeySetupTitle),
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
                            l10n.binanceApiKeySetupLabelField,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _labelController,
                            decoration: InputDecoration(
                              hintText: l10n.binanceApiKeySetupLabelHint,
                              border: const OutlineInputBorder(),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? l10n.binanceApiKeySetupLabelRequired
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
                            l10n.binanceApiKeySetupApiKeyField,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _apiKeyController,
                            obscureText: _obscureApiKey,
                            decoration: InputDecoration(
                              hintText: l10n.binanceApiKeySetupApiKeyHint,
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
                            l10n.binanceApiKeySetupApiSecretField,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _apiSecretController,
                            obscureText: _obscureApiSecret,
                            decoration: InputDecoration(
                              hintText: l10n.binanceApiKeySetupApiSecretHint,
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
                            l10n.binanceApiKeySetupPermissionsSection,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          CheckboxListTile(
                            title: Text(l10n.binanceApiKeySetupSpotTradingTitle),
                            subtitle: Text(l10n.binanceApiKeySetupSpotTradingSubtitle),
                            value: _spotPermission,
                            onChanged: (v) =>
                                setState(() => _spotPermission = v ?? true),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                          CheckboxListTile(
                            title: Text(l10n.binanceApiKeySetupFuturesTradingTitle),
                            subtitle: Text(l10n.binanceApiKeySetupFuturesTradingSubtitle),
                            value: _futuresPermission,
                            onChanged: (v) =>
                                setState(() => _futuresPermission = v ?? false),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                          const Divider(),
                          CheckboxListTile(
                            title: Text(l10n.binanceApiKeySetupUseTestnetTitle),
                            subtitle: Text(
                                l10n.binanceApiKeySetupUseTestnetSubtitle),
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
                                l10n.binanceApiKeySetupGuideTitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.binanceApiKeySetupGuideIntro,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          _buildBullet(l10n.binanceApiKeySetupGuideTip1),
                          _buildBullet(l10n.binanceApiKeySetupGuideTip2),
                          _buildBullet(l10n.binanceApiKeySetupGuideTip3),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: _launchBinanceGuide,
                            icon: const Icon(Icons.open_in_new, size: 16),
                            label: Text(l10n.binanceApiKeySetupGuideLink),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (provider.lastTestResult != null)
                    _buildTestResultBanner(provider, l10n),
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
                        : () => _testConnection(provider, l10n),
                    child: provider.isTesting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.binanceApiKeySetupTestConnection),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: provider.isSaving || provider.isTesting
                        ? null
                        : () => _saveCredentials(provider, l10n),
                    child: provider.isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.binanceApiKeySetupSaveAction),
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

  Widget _buildTestResultBanner(
    BinanceCredentialsProvider provider,
    AppLocalizations l10n,
  ) {
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
                  ? l10n.binanceApiKeySetupConnectionSuccessful
                  : l10n.binanceApiKeySetupConnectionFailed(
                      provider.lastTestError ?? l10n.unknownError),
              style: TextStyle(
                color: success ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _testConnection(
    BinanceCredentialsProvider provider,
    AppLocalizations l10n,
  ) async {
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
        SnackBar(
          content: Text(l10n.binanceApiKeySetupConnectionPassedSaved),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _saveCredentials(
    BinanceCredentialsProvider provider,
    AppLocalizations l10n,
  ) async {
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
          SnackBar(
            content: Text(l10n.binanceApiKeySetupSavedSuccess),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.binanceApiKeySetupSavedFailed(result.error ?? l10n.unknownError)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
