import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final WebviewController _controller = WebviewController();
  bool _loading = true;
  String? _error;

  bool get _useEmbeddedWebview => !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  @override
  void initState() {
    super.initState();
    if (_useEmbeddedWebview) {
      _initWebview();
    }
  }

  Future<void> _initWebview() async {
    try {
      await _controller.initialize();
      await _controller.loadUrl(ApiConstants.aboutUrl);
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(ApiConstants.aboutUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  void dispose() {
    if (_useEmbeddedWebview) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aboutTitle),
        actions: [
          IconButton(
            onPressed: _openInBrowser,
            icon: const Icon(Icons.open_in_new),
            tooltip: l10n.aboutOpenInBrowser,
          ),
        ],
      ),
      body: _useEmbeddedWebview
          ? (_loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: _openInBrowser,
                              child: Text(l10n.aboutOpenInBrowser),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Webview(_controller))
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.appTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.aboutPolicyGuideHint,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _openInBrowser,
                      icon: const Icon(Icons.open_in_new),
                      label: Text(l10n.aboutOpenInBrowser),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
