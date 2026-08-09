import 'package:flutter/material.dart';

import 'package:crypto_trading_app/core/enums/user_role.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';

/// Where a manual entry should navigate.
///
/// - [route] entries deep-link into an existing screen via [AppRoutes].
/// - [detail] entries open the in-app [ManualDetailScreen] that renders the
///   long-form Markdown body (used for Glossary / FAQ / Contact).
enum ManualEntryKind { route, detail }

/// A single row inside a manual section.
///
/// Title / subtitle are resolved through [AppLocalizations] getters to keep
/// the data layer string-free and ready for translation.
class ManualEntry {
  const ManualEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.visibleToRoles,
    required this.kind,
    this.target,
  }) : assert(
          kind == ManualEntryKind.detail || (kind == ManualEntryKind.route && target != null),
          'route entries must provide a target; detail entries must not',
        );

  /// ARB key selector for the title text.
  final String Function(AppLocalizations l10n) title;

  /// ARB key selector for the subtitle text.
  final String Function(AppLocalizations l10n) subtitle;

  /// Leading icon.
  final IconData icon;

  /// Which roles see this entry. An empty list means "everyone, including guests".
  final List<UserRole> visibleToRoles;

  /// [ManualEntryKind.route] deep-links to an existing screen;
  /// [ManualEntryKind.detail] opens the in-app markdown detail screen.
  final ManualEntryKind kind;

  /// The path / route to push for [ManualEntryKind.route]. Ignored for
  /// [ManualEntryKind.detail] — detail entries resolve to the detail screen.
  final String? target;
}

/// A grouped section on the operator manual screen.
class ManualSection {
  const ManualSection({
    required this.title,
    required this.description,
    required this.icon,
    required this.entries,
  });

  /// ARB key selector for the section title.
  final String Function(AppLocalizations l10n) title;

  /// ARB key selector for a 1-line description under the title.
  final String Function(AppLocalizations l10n) description;

  /// Section icon (currently only used by callers that want to decorate
  /// the hero — the manual screen itself does not render it).
  final IconData icon;

  /// Raw, unfiltered entries. Visibility is applied via [filterForRole].
  final List<ManualEntry> entries;

  /// Returns a copy of this section with only the entries visible to
  /// [role]. Roles listed in [visibleToRoles] see the entry; everyone
  /// else does not. An entry with an empty [ManualEntry.visibleToRoles]
  /// list is visible to **all** roles (including guests).
  ManualSection filterForRole(UserRole role) {
    final filtered = entries
        .where(
          (e) => e.visibleToRoles.isEmpty || e.visibleToRoles.contains(role),
        )
        .toList(growable: false);
    return ManualSection(
      title: title,
      description: description,
      icon: icon,
      entries: filtered,
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────

/// Roles that share trader-level access (any authenticated user).
const List<UserRole> _kAuthenticatedRoles = [
  UserRole.trader,
  UserRole.admin,
  UserRole.riskOfficer,
  UserRole.supportAgent,
  UserRole.marketMaker,
  UserRole.financeManager,
];

/// Roles that may access admin-only sections (matches `canViewOpsDashboard`).
const List<UserRole> _kOpsRoles = [
  UserRole.admin,
  UserRole.riskOfficer,
  UserRole.financeManager,
  UserRole.supportAgent,
];

// ── Public catalogue ─────────────────────────────────────────────────────

/// Static catalogue of operator manual sections.
///
/// Order = display order. Section and entry visibility is driven by role;
/// see [ManualSection.filterForRole].
const List<ManualSection> kOperatorManualSections = [
  // 1. Getting Started — every user, including guests.
  ManualSection(
    title: _gettingStartedTitle,
    description: _gettingStartedDesc,
    icon: Icons.rocket_launch_outlined,
    entries: [
      ManualEntry(
        title: _setupAccountTitle,
        subtitle: _setupAccountDesc,
        icon: Icons.person_outline,
        kind: ManualEntryKind.route,
        target: '/profile',
        visibleToRoles: [],
      ),
      ManualEntry(
        title: _enable2faTitle,
        subtitle: _enable2faDesc,
        icon: Icons.shield_outlined,
        kind: ManualEntryKind.route,
        target: '/settings',
        visibleToRoles: [],
      ),
      ManualEntry(
        title: _changeLanguageTitle,
        subtitle: _changeLanguageDesc,
        icon: Icons.language_outlined,
        kind: ManualEntryKind.route,
        target: '/settings',
        visibleToRoles: [],
      ),
      ManualEntry(
        title: _changeThemeTitle,
        subtitle: _changeThemeDesc,
        icon: Icons.palette_outlined,
        kind: ManualEntryKind.route,
        target: '/settings',
        visibleToRoles: [],
      ),
    ],
  ),

  // 2. Dashboard — guests + authenticated.
  ManualSection(
    title: _dashboardTitle,
    description: _dashboardDesc,
    icon: Icons.dashboard_outlined,
    entries: [
      ManualEntry(
        title: _dashboardOverviewTitle,
        subtitle: _dashboardOverviewDesc,
        icon: Icons.pie_chart_outline,
        kind: ManualEntryKind.route,
        target: '/',
        visibleToRoles: [],
      ),
      ManualEntry(
        title: _dashboardPullRefreshTitle,
        subtitle: _dashboardPullRefreshDesc,
        icon: Icons.refresh_outlined,
        kind: ManualEntryKind.route,
        target: '/',
        visibleToRoles: [],
      ),
    ],
  ),

  // 3. Markets — guests + authenticated.
  ManualSection(
    title: _marketsTitle,
    description: _marketsDesc,
    icon: Icons.show_chart_outlined,
    entries: [
      ManualEntry(
        title: _marketsSearchTitle,
        subtitle: _marketsSearchDesc,
        icon: Icons.search_outlined,
        kind: ManualEntryKind.route,
        target: '/',
        visibleToRoles: [],
      ),
      ManualEntry(
        title: _marketsFilterTitle,
        subtitle: _marketsFilterDesc,
        icon: Icons.filter_alt_outlined,
        kind: ManualEntryKind.route,
        target: '/currencies',
        visibleToRoles: [],
      ),
      ManualEntry(
        title: _marketsSortTitle,
        subtitle: _marketsSortDesc,
        icon: Icons.sort_outlined,
        kind: ManualEntryKind.route,
        target: '/admin/markets',
        visibleToRoles: [UserRole.admin],
      ),
    ],
  ),

  // 4. Wallets — authenticated only.
  ManualSection(
    title: _walletsTitle,
    description: _walletsDesc,
    icon: Icons.account_balance_wallet_outlined,
    entries: [
      ManualEntry(
        title: _walletsViewTitle,
        subtitle: _walletsViewDesc,
        icon: Icons.account_balance_wallet_outlined,
        kind: ManualEntryKind.route,
        target: '/',
        visibleToRoles: _kAuthenticatedRoles,
      ),
      ManualEntry(
        title: _walletsHistoryTitle,
        subtitle: _walletsHistoryDesc,
        icon: Icons.history_outlined,
        kind: ManualEntryKind.route,
        target: '/',
        visibleToRoles: _kAuthenticatedRoles,
      ),
    ],
  ),

  // 5. Orders / Trading — authenticated only.
  ManualSection(
    title: _ordersTitle,
    description: _ordersDesc,
    icon: Icons.swap_horiz_outlined,
    entries: [
      ManualEntry(
        title: _ordersPlaceTitle,
        subtitle: _ordersPlaceDesc,
        icon: Icons.add_circle_outline,
        kind: ManualEntryKind.route,
        target: '/orders',
        visibleToRoles: _kAuthenticatedRoles,
      ),
      ManualEntry(
        title: _ordersCancelTitle,
        subtitle: _ordersCancelDesc,
        icon: Icons.cancel_outlined,
        kind: ManualEntryKind.route,
        target: '/orders',
        visibleToRoles: _kAuthenticatedRoles,
      ),
    ],
  ),

  // 6. Account Settings — authenticated only.
  ManualSection(
    title: _accountSettingsTitle,
    description: _accountSettingsDesc,
    icon: Icons.settings_outlined,
    entries: [
      ManualEntry(
        title: _settings2faTitle,
        subtitle: _settings2faDesc,
        icon: Icons.shield_outlined,
        kind: ManualEntryKind.route,
        target: '/settings',
        visibleToRoles: _kAuthenticatedRoles,
      ),
      ManualEntry(
        title: _settingsSyncTitle,
        subtitle: _settingsSyncDesc,
        icon: Icons.sync_outlined,
        kind: ManualEntryKind.route,
        target: '/settings',
        visibleToRoles: [UserRole.admin],
      ),
    ],
  ),

  // 7. User Management — admin + support + risk.
  ManualSection(
    title: _userManagementTitle,
    description: _userManagementDesc,
    icon: Icons.people_outline,
    entries: [
      ManualEntry(
        title: _adminUsersTitle,
        subtitle: _adminUsersDesc,
        icon: Icons.people_outline,
        kind: ManualEntryKind.route,
        target: '/admin/users',
        visibleToRoles: [
          UserRole.admin,
          UserRole.supportAgent,
          UserRole.riskOfficer,
        ],
      ),
      ManualEntry(
        title: _adminRolesTitle,
        subtitle: _adminRolesDesc,
        icon: Icons.admin_panel_settings_outlined,
        kind: ManualEntryKind.route,
        target: '/admin/users',
        visibleToRoles: [UserRole.admin],
      ),
      ManualEntry(
        title: _adminBanTitle,
        subtitle: _adminBanDesc,
        icon: Icons.lock_outline,
        kind: ManualEntryKind.route,
        target: '/admin/users',
        visibleToRoles: [UserRole.admin],
      ),
    ],
  ),

  // 8. Security Requests — admin + risk.
  ManualSection(
    title: _securityRequestsTitle,
    description: _securityRequestsDesc,
    icon: Icons.verified_user_outlined,
    entries: [
      ManualEntry(
        title: _securityRequestsReviewTitle,
        subtitle: _securityRequestsReviewDesc,
        icon: Icons.fact_check_outlined,
        kind: ManualEntryKind.route,
        target: '/admin/security-requests',
        visibleToRoles: [UserRole.admin, UserRole.riskOfficer],
      ),
    ],
  ),

  // 9. Managed Wallets — admin + risk + finance.
  ManualSection(
    title: _managedWalletsTitle,
    description: _managedWalletsDesc,
    icon: Icons.account_tree_outlined,
    entries: [
      ManualEntry(
        title: _managedWalletsOpsTitle,
        subtitle: _managedWalletsOpsDesc,
        icon: Icons.account_tree_outlined,
        kind: ManualEntryKind.route,
        target: '/managed-wallets',
        visibleToRoles: _kOpsRoles,
      ),
    ],
  ),

  // 10. Payment Configuration — admin + finance.
  ManualSection(
    title: _paymentConfigTitle,
    description: _paymentConfigDesc,
    icon: Icons.payments_outlined,
    entries: [
      ManualEntry(
        title: _paymentConfigSaveTitle,
        subtitle: _paymentConfigSaveDesc,
        icon: Icons.payments_outlined,
        kind: ManualEntryKind.route,
        target: '/admin/payment-config',
        visibleToRoles: [UserRole.admin, UserRole.financeManager],
      ),
    ],
  ),

  // 11. Treasury E2E — admin + finance.
  ManualSection(
    title: _treasuryE2ETitle,
    description: _treasuryE2EDesc,
    icon: Icons.vpn_key_outlined,
    entries: [
      ManualEntry(
        title: _treasuryE2EConfigTitle,
        subtitle: _treasuryE2EConfigDesc,
        icon: Icons.vpn_key_outlined,
        kind: ManualEntryKind.route,
        target: '/treasury',
        visibleToRoles: [UserRole.admin, UserRole.financeManager],
      ),
    ],
  ),

  // 12. Market Maker Hub — market maker + admin.
  ManualSection(
    title: _marketMakerTitle,
    description: _marketMakerDesc,
    icon: Icons.precision_manufacturing_outlined,
    entries: [
      ManualEntry(
        title: _marketMakerPairTitle,
        subtitle: _marketMakerPairDesc,
        icon: Icons.add_box_outlined,
        kind: ManualEntryKind.route,
        target: '/market-maker',
        visibleToRoles: [UserRole.admin, UserRole.marketMaker],
      ),
      ManualEntry(
        title: _marketMakerSyncTitle,
        subtitle: _marketMakerSyncDesc,
        icon: Icons.sync_outlined,
        kind: ManualEntryKind.route,
        target: '/admin/markets',
        visibleToRoles: [UserRole.admin, UserRole.marketMaker],
      ),
    ],
  ),

  // 13. Monitoring — admin + risk + finance + support.
  ManualSection(
    title: _monitoringTitle,
    description: _monitoringDesc,
    icon: Icons.monitor_heart_outlined,
    entries: [
      ManualEntry(
        title: _adminTransactionsTitle,
        subtitle: _adminTransactionsDesc,
        icon: Icons.receipt_long_outlined,
        kind: ManualEntryKind.route,
        target: '/admin/transactions',
        visibleToRoles: _kOpsRoles,
      ),
      ManualEntry(
        title: _adminCurrenciesTitle,
        subtitle: _adminCurrenciesDesc,
        icon: Icons.toll_outlined,
        kind: ManualEntryKind.route,
        target: '/admin/currencies',
        visibleToRoles: _kOpsRoles,
      ),
      ManualEntry(
        title: _adminDepositWatcherTitle,
        subtitle: _adminDepositWatcherDesc,
        icon: Icons.visibility_outlined,
        kind: ManualEntryKind.route,
        target: '/admin/deposit-watcher',
        visibleToRoles: _kOpsRoles,
      ),
    ],
  ),

  // 14. System Config — admin only.
  ManualSection(
    title: _systemConfigTitle,
    description: _systemConfigDesc,
    icon: Icons.tune_outlined,
    entries: [
      ManualEntry(
        title: _systemConfigSaveTitle,
        subtitle: _systemConfigSaveDesc,
        icon: Icons.tune_outlined,
        kind: ManualEntryKind.route,
        target: '/admin/system-config',
        visibleToRoles: [UserRole.admin],
      ),
    ],
  ),

  // 15. Broadcast — admin only.
  ManualSection(
    title: _broadcastTitle,
    description: _broadcastDesc,
    icon: Icons.campaign_outlined,
    entries: [
      ManualEntry(
        title: _broadcastSendTitle,
        subtitle: _broadcastSendDesc,
        icon: Icons.campaign_outlined,
        kind: ManualEntryKind.route,
        target: '/admin/broadcast',
        visibleToRoles: [UserRole.admin],
      ),
    ],
  ),

  // 16. Glossary / FAQ / Contact — everyone, including guests. These render
  //     the long-form Markdown body via ManualDetailScreen.
  ManualSection(
    title: _glossaryTitle,
    description: _glossaryDesc,
    icon: Icons.menu_book_outlined,
    entries: [
      ManualEntry(
        title: _glossaryTitle,
        subtitle: _glossaryDesc,
        icon: Icons.translate_outlined,
        kind: ManualEntryKind.detail,
        target: 'glossary',
        visibleToRoles: [],
      ),
    ],
  ),
  ManualSection(
    title: _faqTitle,
    description: _faqDesc,
    icon: Icons.help_outline,
    entries: [
      ManualEntry(
        title: _faqTitle,
        subtitle: _faqDesc,
        icon: Icons.help_outline,
        kind: ManualEntryKind.detail,
        target: 'faq',
        visibleToRoles: [],
      ),
    ],
  ),
  ManualSection(
    title: _contactTitle,
    description: _contactDesc,
    icon: Icons.support_agent_outlined,
    entries: [
      ManualEntry(
        title: _contactTitle,
        subtitle: _contactDesc,
        icon: Icons.support_agent_outlined,
        kind: ManualEntryKind.detail,
        target: 'contact',
        visibleToRoles: [],
      ),
    ],
  ),
];

// ── ARB key selectors (one-line helpers, kept at the bottom for
//    readability; AppLocalizations is generated from app_en.arb / app_vi.arb) ──

String _gettingStartedTitle(AppLocalizations l) => l.manualGettingStartedTitle;
String _gettingStartedDesc(AppLocalizations l) => l.manualGettingStartedDesc;
String _dashboardTitle(AppLocalizations l) => l.manualDashboardTitle;
String _dashboardDesc(AppLocalizations l) => l.manualDashboardDesc;
String _marketsTitle(AppLocalizations l) => l.manualMarketsTitle;
String _marketsDesc(AppLocalizations l) => l.manualMarketsDesc;
String _walletsTitle(AppLocalizations l) => l.manualWalletsTitle;
String _walletsDesc(AppLocalizations l) => l.manualWalletsDesc;
String _ordersTitle(AppLocalizations l) => l.manualOrdersTitle;
String _ordersDesc(AppLocalizations l) => l.manualOrdersDesc;
String _accountSettingsTitle(AppLocalizations l) => l.manualAccountSettingsTitle;
String _accountSettingsDesc(AppLocalizations l) => l.manualAccountSettingsDesc;
String _userManagementTitle(AppLocalizations l) => l.manualUserManagementTitle;
String _userManagementDesc(AppLocalizations l) => l.manualUserManagementDesc;
String _securityRequestsTitle(AppLocalizations l) => l.manualSecurityRequestsTitle;
String _securityRequestsDesc(AppLocalizations l) => l.manualSecurityRequestsDesc;
String _managedWalletsTitle(AppLocalizations l) => l.manualManagedWalletsTitle;
String _managedWalletsDesc(AppLocalizations l) => l.manualManagedWalletsDesc;
String _paymentConfigTitle(AppLocalizations l) => l.manualPaymentConfigTitle;
String _paymentConfigDesc(AppLocalizations l) => l.manualPaymentConfigDesc;
String _treasuryE2ETitle(AppLocalizations l) => l.manualTreasuryE2ETitle;
String _treasuryE2EDesc(AppLocalizations l) => l.manualTreasuryE2EDesc;
String _marketMakerTitle(AppLocalizations l) => l.manualMarketMakerTitle;
String _marketMakerDesc(AppLocalizations l) => l.manualMarketMakerDesc;
String _monitoringTitle(AppLocalizations l) => l.manualMonitoringTitle;
String _monitoringDesc(AppLocalizations l) => l.manualMonitoringDesc;
String _systemConfigTitle(AppLocalizations l) => l.manualSystemConfigTitle;
String _systemConfigDesc(AppLocalizations l) => l.manualSystemConfigDesc;
String _broadcastTitle(AppLocalizations l) => l.manualBroadcastTitle;
String _broadcastDesc(AppLocalizations l) => l.manualBroadcastDesc;
String _glossaryTitle(AppLocalizations l) => l.manualGlossaryTitle;
String _glossaryDesc(AppLocalizations l) => l.manualGlossaryDesc;
String _faqTitle(AppLocalizations l) => l.manualFaqTitle;
String _faqDesc(AppLocalizations l) => l.manualFaqDesc;
String _contactTitle(AppLocalizations l) => l.manualContactTitle;
String _contactDesc(AppLocalizations l) => l.manualContactDesc;

String _setupAccountTitle(AppLocalizations l) => l.manualEntrySetupAccountTitle;
String _setupAccountDesc(AppLocalizations l) => l.manualEntrySetupAccountDesc;
String _enable2faTitle(AppLocalizations l) => l.manualEntryEnable2faTitle;
String _enable2faDesc(AppLocalizations l) => l.manualEntryEnable2faDesc;
String _changeLanguageTitle(AppLocalizations l) => l.manualEntryChangeLanguageTitle;
String _changeLanguageDesc(AppLocalizations l) => l.manualEntryChangeLanguageDesc;
String _changeThemeTitle(AppLocalizations l) => l.manualEntryChangeThemeTitle;
String _changeThemeDesc(AppLocalizations l) => l.manualEntryChangeThemeDesc;
String _dashboardOverviewTitle(AppLocalizations l) =>
    l.manualEntryDashboardOverviewTitle;
String _dashboardOverviewDesc(AppLocalizations l) =>
    l.manualEntryDashboardOverviewDesc;
String _dashboardPullRefreshTitle(AppLocalizations l) =>
    l.manualEntryDashboardPullRefreshTitle;
String _dashboardPullRefreshDesc(AppLocalizations l) =>
    l.manualEntryDashboardPullRefreshDesc;
String _marketsSearchTitle(AppLocalizations l) => l.manualEntryMarketsSearchTitle;
String _marketsSearchDesc(AppLocalizations l) => l.manualEntryMarketsSearchDesc;
String _marketsFilterTitle(AppLocalizations l) => l.manualEntryMarketsFilterTitle;
String _marketsFilterDesc(AppLocalizations l) => l.manualEntryMarketsFilterDesc;
String _marketsSortTitle(AppLocalizations l) => l.manualEntryMarketsSortTitle;
String _marketsSortDesc(AppLocalizations l) => l.manualEntryMarketsSortDesc;
String _walletsViewTitle(AppLocalizations l) => l.manualEntryWalletsViewTitle;
String _walletsViewDesc(AppLocalizations l) => l.manualEntryWalletsViewDesc;
String _walletsHistoryTitle(AppLocalizations l) => l.manualEntryWalletsHistoryTitle;
String _walletsHistoryDesc(AppLocalizations l) => l.manualEntryWalletsHistoryDesc;
String _ordersPlaceTitle(AppLocalizations l) => l.manualEntryOrdersPlaceTitle;
String _ordersPlaceDesc(AppLocalizations l) => l.manualEntryOrdersPlaceDesc;
String _ordersCancelTitle(AppLocalizations l) => l.manualEntryOrdersCancelTitle;
String _ordersCancelDesc(AppLocalizations l) => l.manualEntryOrdersCancelDesc;
String _settings2faTitle(AppLocalizations l) => l.manualEntrySettings2faTitle;
String _settings2faDesc(AppLocalizations l) => l.manualEntrySettings2faDesc;
String _settingsSyncTitle(AppLocalizations l) => l.manualEntrySettingsSyncTitle;
String _settingsSyncDesc(AppLocalizations l) => l.manualEntrySettingsSyncDesc;
String _adminUsersTitle(AppLocalizations l) => l.manualEntryAdminUsersTitle;
String _adminUsersDesc(AppLocalizations l) => l.manualEntryAdminUsersDesc;
String _adminRolesTitle(AppLocalizations l) => l.manualEntryAdminRolesTitle;
String _adminRolesDesc(AppLocalizations l) => l.manualEntryAdminRolesDesc;
String _adminBanTitle(AppLocalizations l) => l.manualEntryAdminBanTitle;
String _adminBanDesc(AppLocalizations l) => l.manualEntryAdminBanDesc;
String _securityRequestsReviewTitle(AppLocalizations l) =>
    l.manualEntrySecurityRequestsReviewTitle;
String _securityRequestsReviewDesc(AppLocalizations l) =>
    l.manualEntrySecurityRequestsReviewDesc;
String _managedWalletsOpsTitle(AppLocalizations l) =>
    l.manualEntryManagedWalletsOpsTitle;
String _managedWalletsOpsDesc(AppLocalizations l) =>
    l.manualEntryManagedWalletsOpsDesc;
String _paymentConfigSaveTitle(AppLocalizations l) =>
    l.manualEntryPaymentConfigSaveTitle;
String _paymentConfigSaveDesc(AppLocalizations l) =>
    l.manualEntryPaymentConfigSaveDesc;
String _treasuryE2EConfigTitle(AppLocalizations l) =>
    l.manualEntryTreasuryE2EConfigTitle;
String _treasuryE2EConfigDesc(AppLocalizations l) =>
    l.manualEntryTreasuryE2EConfigDesc;
String _marketMakerPairTitle(AppLocalizations l) =>
    l.manualEntryMarketMakerPairTitle;
String _marketMakerPairDesc(AppLocalizations l) =>
    l.manualEntryMarketMakerPairDesc;
String _marketMakerSyncTitle(AppLocalizations l) =>
    l.manualEntryMarketMakerSyncTitle;
String _marketMakerSyncDesc(AppLocalizations l) =>
    l.manualEntryMarketMakerSyncDesc;
String _adminTransactionsTitle(AppLocalizations l) =>
    l.manualEntryAdminTransactionsTitle;
String _adminTransactionsDesc(AppLocalizations l) =>
    l.manualEntryAdminTransactionsDesc;
String _adminCurrenciesTitle(AppLocalizations l) =>
    l.manualEntryAdminCurrenciesTitle;
String _adminCurrenciesDesc(AppLocalizations l) =>
    l.manualEntryAdminCurrenciesDesc;
String _adminDepositWatcherTitle(AppLocalizations l) =>
    l.manualEntryAdminDepositWatcherTitle;
String _adminDepositWatcherDesc(AppLocalizations l) =>
    l.manualEntryAdminDepositWatcherDesc;
String _systemConfigSaveTitle(AppLocalizations l) =>
    l.manualEntrySystemConfigSaveTitle;
String _systemConfigSaveDesc(AppLocalizations l) =>
    l.manualEntrySystemConfigSaveDesc;
String _broadcastSendTitle(AppLocalizations l) => l.manualEntryBroadcastSendTitle;
String _broadcastSendDesc(AppLocalizations l) => l.manualEntryBroadcastSendDesc;