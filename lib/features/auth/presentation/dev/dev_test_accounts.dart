// Dev-only test accounts for login screen — stripped from production builds
// via kDebugMode compile-time constant.

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
