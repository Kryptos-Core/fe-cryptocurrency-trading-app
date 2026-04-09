import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:reown_appkit/reown_appkit.dart';

/// Cấu hình Reown AppKit cho đăng nhập EVM — URI/QR từ SDK, không dùng URI giả từ Nest.
/// Pairing gồm các mạng EVM mà backend hỗ trợ; chuỗi thực tế khi ký lấy từ session (CAIP-2).
///
/// Reown dùng [webview_flutter], hiện **chỉ** có implementation ổn định cho **Android / iOS**.
/// Trên **Windows / Linux / macOS desktop**, [WebViewPlatform.instance] không được gán → gọi
/// [ReownAppKitModal.init] sẽ assert. Luôn kiểm tra [isRuntimeSupported] trước khi init.
class ReownWalletAuthConfig {
  ReownWalletAuthConfig._();

  static const String sepoliaCaip2 = 'eip155:11155111';

  /// Chuỗi EVM dùng cho optional namespace (đăng nhập / personal_sign).
  static const List<String> evmAuthCaip2Chains = [
    'eip155:1',
    sepoliaCaip2,
    'eip155:56',
    'eip155:97',
  ];

  /// `true` khi có thể gọi [ReownAppKitModal.init] an toàn (mobile).
  static bool get isRuntimeSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static String? get projectId {
    final a = dotenv.env['WALLETCONNECT_PROJECT_ID']?.trim();
    if (a != null && a.isNotEmpty) return a;
    final b = dotenv.env['REOWN_PROJECT_ID']?.trim();
    if (b != null && b.isNotEmpty) return b;
    return null;
  }

  static Map<String, RequiredNamespace> get optionalNamespacesEvmAuth => const {
        'eip155': RequiredNamespace(
          chains: evmAuthCaip2Chains,
          methods: [
            'personal_sign',
            'eth_sendTransaction',
            'eth_signTypedData',
            'eth_signTypedData_v4',
          ],
          events: ['accountsChanged', 'chainChanged'],
        ),
      };

  /// WalletConnect pairing metadata; override with `.env` APP_NAME, APP_URL, APP_ICON_URL.
  static PairingMetadata get pairingMetadata {
    final name = dotenv.env['APP_NAME']?.trim();
    final url = dotenv.env['APP_URL']?.trim();
    final icon = dotenv.env['APP_ICON_URL']?.trim();
    return PairingMetadata(
      name: (name != null && name.isNotEmpty) ? name : 'Kryptos Core',
      description: 'Cryptocurrency trading',
      url: (url != null && url.isNotEmpty) ? url : 'https://reown.com',
      icons: [
        if (icon != null && icon.isNotEmpty)
          icon
        else
          'https://reown.com/reown-logo.svg',
      ],
    );
  }

  /// Tạo modal; gọi [ReownAppKitModal.init] ở ngoài. [dispose] khi không dùng.
  static ReownAppKitModal createModal(
    BuildContext context, {
    required String projectId,
  }) {
    return ReownAppKitModal(
      context: context,
      projectId: projectId,
      metadata: pairingMetadata,
      optionalNamespaces: optionalNamespacesEvmAuth,
      enableAnalytics: false,
      disconnectOnDispose: true,
    );
  }
}
