/// Shell route constants for [MainScreen] bottom navigation.
/// Named routes ([GoRouter]) can be introduced incrementally without changing these indices.
abstract final class AppRoutes {
  AppRoutes._();

  /// [MaterialApp] home — single shell with bottom navigation.
  static const String root = '/';

  /// Bottom navigation indices — must stay aligned with `_buildScreens` in MainScreen.
  static const int tabDashboard = 0;
  static const int tabMarkets = 1;
  static const int tabWallets = 2;
  static const int tabProfile = 3;
}
