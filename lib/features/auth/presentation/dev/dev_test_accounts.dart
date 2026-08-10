// Dev-only test accounts for login screen — stripped from production builds
// via kDebugMode compile-time constant and the `kDebugMode` guard in
// `LoginScreen._showDevAccounts()`.
//
// Used as OFFLINE FALLBACK when `GET /auth/sandbox-users` fails (e.g. backend
// not in sandbox mode, or no DB). The primary source is the live endpoint.
//
// The flag `isSandboxLogin` is false because this fallback requires the
// password; the picker in `DevAccountSheet` only does password-less login when
// the list comes from the live endpoint.

import 'package:crypto_trading_app/features/auth/domain/entities/dev_user_pick.dart';

class DevTestAccount {
  final String email;
  final String password;
  final String displayName;
  final String role;

  const DevTestAccount({
    required this.email,
    required this.password,
    required this.displayName,
    required this.role,
  });

  DevUserPick toPick() => DevUserPick(
        userId: 'fallback-${email.hashCode}',
        email: email,
        firstName: null,
        lastName: null,
        role: role,
        status: 'ACTIVE',
        avatarUrl: null,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      );
}

const List<DevTestAccount> devTestAccounts = [
  DevTestAccount(
    email: 'hsondz1910@gmail.com',
    password: 'ChangeMeAdmin!',
    displayName: 'Admin User',
    role: 'ADMIN',
  ),
  DevTestAccount(
    email: 'hoangsondz1910@gmail.com',
    password: 'ChangeMeTrader!',
    displayName: 'Trader One',
    role: 'TRADER',
  ),
  DevTestAccount(
    email: 'trader2@example.com',
    password: 'ChangeMeTrader!',
    displayName: 'Trader Two',
    role: 'TRADER',
  ),
  DevTestAccount(
    email: 'maxnoah901@gmail.com',
    password: 'ChangeMeRisk!',
    displayName: 'Risk Officer',
    role: 'RISK_OFFICER',
  ),
  DevTestAccount(
    email: 'support@example.com',
    password: 'ChangeMeSupport!',
    displayName: 'Support Agent',
    role: 'SUPPORT_AGENT',
  ),
  DevTestAccount(
    email: 'maker@example.com',
    password: 'ChangeMeMaker!',
    displayName: 'Market Maker',
    role: 'MARKET_MAKER',
  ),
  DevTestAccount(
    email: 'paperclip.health.dev@gmail.com',
    password: 'ChangeMeFinance!',
    displayName: 'Finance Manager',
    role: 'FINANCE_MANAGER',
  ),
];
