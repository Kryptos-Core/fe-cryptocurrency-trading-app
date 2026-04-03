import 'package:flutter/foundation.dart';

/// Flutter desktop native (không web): không có extension injected như trình duyệt.
bool isWalletDesktopNative() {
  if (kIsWeb) return false;
  switch (defaultTargetPlatform) {
    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
      return true;
    default:
      return false;
  }
}
