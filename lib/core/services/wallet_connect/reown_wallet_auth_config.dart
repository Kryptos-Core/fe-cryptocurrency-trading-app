import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:reown_appkit/reown_appkit.dart';

/// Cấu hình Reown AppKit cho đăng nhập EVM (Sepolia) — URI/QR từ SDK, không dùng URI giả từ Nest.
///
/// Reown dùng [webview_flutter], hiện **chỉ** có implementation ổn định cho **Android / iOS**.
/// Trên **Windows / Linux / macOS desktop**, [WebViewPlatform.instance] không được gán → gọi
/// [ReownAppKitModal.init] sẽ assert. Luôn kiểm tra [isRuntimeSupported] trước khi init.
class ReownWalletAuthConfig {
  ReownWalletAuthConfig._();

  static const String sepoliaCaip2 = 'eip155:11155111';

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

  static Map<String, RequiredNamespace> get optionalNamespacesEvmSepolia => {
        'eip155': const RequiredNamespace(
          chains: [sepoliaCaip2],
          methods: [
            'personal_sign',
            'eth_sendTransaction',
            'eth_signTypedData',
            'eth_signTypedData_v4',
          ],
          events: ['accountsChanged', 'chainChanged'],
        ),
      };

  static PairingMetadata get defaultMetadata => const PairingMetadata(
        name: 'Kryptos Core',
        description: 'Cryptocurrency trading',
        url: 'https://reown.com',
        icons: ['https://reown.com/reown-logo.svg'],
      );

  /// Tạo modal; gọi [ReownAppKitModal.init] ở ngoài. [dispose] khi không dùng.
  static ReownAppKitModal createModal(
    BuildContext context, {
    required String projectId,
  }) {
    return ReownAppKitModal(
      context: context,
      projectId: projectId,
      metadata: defaultMetadata,
      optionalNamespaces: optionalNamespacesEvmSepolia,
      enableAnalytics: false,
      disconnectOnDispose: true,
    );
  }
}
