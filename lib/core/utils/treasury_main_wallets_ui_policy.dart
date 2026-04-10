import 'package:crypto_trading_app/core/enums/user_role.dart';

/// Hot-wallet main screen: "pending approval" tab and pending list API are for
/// roles that approve imports; finance and risk no longer use this flow.
bool treasuryMainWalletsShowsPendingTab(UserRole role) {
  switch (role) {
    case UserRole.financeManager:
    case UserRole.riskOfficer:
      return false;
    case UserRole.trader:
    case UserRole.admin:
    case UserRole.supportAgent:
    case UserRole.marketMaker:
      return true;
  }
}
