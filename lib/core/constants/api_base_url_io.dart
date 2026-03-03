import 'dart:io';

/// Default API server origin (host:port, no path) for VM platforms.
/// Android Emulator must use 10.0.2.2 to reach host machine; others use localhost.
String getDefaultApiServerOrigin() {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:3000';
  }
  return 'http://localhost:3000';
}
