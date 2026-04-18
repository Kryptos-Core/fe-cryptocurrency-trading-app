import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/responsive/app_responsive.dart';
import 'package:crypto_trading_app/core/utils/avatar_url_helper.dart';
import 'package:crypto_trading_app/features/user/domain/entities/user.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/admin/users/presentation/providers/admin_users_provider.dart';
import 'package:crypto_trading_app/features/admin/shared/presentation/providers/admin_enums_provider.dart';
import 'package:crypto_trading_app/core/widgets/app_dropdown_field.dart';
import 'admin_user_detail_screen.dart';

// ── Constants ──────────────────────────────────────────────────────────────────

List<(String, String?)> _rolesFallback(AppLocalizations l10n) => [
  (l10n.adminUserListRoleAll, null),
  (l10n.adminUserListRoleTrader, 'TRADER'),
  (l10n.adminUserListRoleMarketMaker, 'MARKET_MAKER'),
  (l10n.adminUserListRoleSupport, 'SUPPORT_AGENT'),
  (l10n.adminUserListRoleRiskOfficer, 'RISK_OFFICER'),
  (l10n.adminUserListRoleFinanceManager, 'FINANCE_MANAGER'),
  (l10n.adminUserListRoleAdmin, 'ADMIN'),
];

List<(String, String?)> _rolesFromEnums(
  AppLocalizations l10n,
  List<String> values,
) {
  if (values.isEmpty) return _rolesFallback(l10n);
  return [
    (l10n.adminUserListRoleAll, null),
    ...values.map((r) => (UserRoleChip.roleLabel(l10n, r), r)),
  ];
}

String _adminUserStatusFilterLabel(AppLocalizations l10n, String v) {
  switch (v) {
    case 'ACTIVE':
      return l10n.adminUserListStatusActive;
    case 'BANNED':
      return l10n.adminUserListStatusBanned;
    case 'PENDING':
      return l10n.adminUserListStatusPending;
    default:
      return v.replaceAll('_', ' ').toLowerCase();
  }
}

List<(String, String?)> _statusesFallback(AppLocalizations l10n) => [
  (l10n.adminFilterAll, null),
  (l10n.adminUserListStatusActive, 'ACTIVE'),
  (l10n.adminUserListStatusBanned, 'BANNED'),
  (l10n.adminUserListStatusPending, 'PENDING'),
];

List<(String, String?)> _statusesFromEnums(
  AppLocalizations l10n,
  List<String> values,
) {
  if (values.isEmpty) return _statusesFallback(l10n);
  return [
    (l10n.adminFilterAll, null),
    ...values.map((s) => (_adminUserStatusFilterLabel(l10n, s), s)),
  ];
}

// ── Screen ────────────────────────────────────────────────────────────────────

class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  // For master-detail: track the selected user locally to render inline detail.
  User? _inlineSelected;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminEnumsProvider>().ensureLoaded();
      context.read<AdminUsersProvider>().fetchUsers(refresh: true);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<AdminUsersProvider>().updateSearch(value.trim());
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<AdminUsersProvider>().loadMoreUsers();
    }
  }

  void _selectUser(BuildContext context, User user, bool isWide) {
    final provider = context.read<AdminUsersProvider>();
    provider.selectUser(user);
    if (isWide) {
      setState(() => _inlineSelected = user);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AdminUserDetailScreen(user: user),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminUserListTitle),
        actions: [
          Consumer<AdminUsersProvider>(
            builder: (_, p, __) => p.totalUsers > 0
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Chip(
                      label: Text('${p.totalUsers}'),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide =
              constraints.maxWidth >= AppBreakpoints.wideLayout;
          if (isWide) {
            return _buildMasterDetail(context, l10n);
          }
          return _buildListPanel(context, l10n, isWide: false);
        },
      ),
    );
  }

  // ── Wide layout: list panel + inline detail ──────────────────────────────────

  Widget _buildMasterDetail(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: user list (fixed 300px)
        SizedBox(
          width: 300,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: _buildListPanel(context, l10n, isWide: true),
          ),
        ),
        // Right: detail panel
        Expanded(
          child: _inlineSelected == null
              ? _EmptyDetailPlaceholder()
              : AdminUserDetailScreen(
                  key: ValueKey(_inlineSelected!.id),
                  user: _inlineSelected!,
                  embedded: true,
                ),
        ),
      ],
    );
  }

  // ── Narrow layout: list only ──────────────────────────────────────────────

  Widget _buildListPanel(BuildContext context, AppLocalizations l10n, {required bool isWide}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        _buildSearchBar(context, colorScheme),
        _buildFilterSection(context, l10n),
        const Divider(height: 1),
        _buildStatsSummary(context, l10n),
        Expanded(child: _buildUserList(context, l10n, isWide: isWide)),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: l10n.adminUserListSearchHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<AdminUsersProvider>().updateSearch('');
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, AppLocalizations l10n) {
    const filterPadding =
        EdgeInsets.symmetric(horizontal: 12, vertical: 10);
    final enums = context.watch<AdminEnumsProvider>();
    return Consumer<AdminUsersProvider>(
      builder: (_, provider, __) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppDropdownField<String?>(
                value: provider.roleFilter,
                labelText: l10n.adminUserListRoleLabel,
                menuMaxHeight: 320,
                contentPadding: filterPadding,
                items: _rolesFromEnums(l10n, enums.userRoles)
                    .map(
                      (e) => DropdownMenuItem<String?>(
                        value: e.$2,
                        child: Text(
                          e.$1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => provider.applyFilters(role: v),
              ),
              const SizedBox(height: 10),
              AppDropdownField<String?>(
                value: provider.statusFilter,
                labelText: l10n.adminUserListStatusLabel,
                menuMaxHeight: 240,
                contentPadding: filterPadding,
                items: _statusesFromEnums(l10n, enums.userStatuses)
                    .map(
                      (e) => DropdownMenuItem<String?>(
                        value: e.$2,
                        child: Text(
                          e.$1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => provider.applyFilters(status: v),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsSummary(BuildContext context, AppLocalizations l10n) {
    return Consumer<AdminUsersProvider>(
      builder: (_, provider, __) {
        if (provider.totalUsers == 0) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Icon(Icons.people_outline,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                l10n.adminUserListTotalUsers(provider.totalUsers),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserList(BuildContext context, AppLocalizations l10n, {required bool isWide}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer<AdminUsersProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingList && provider.users.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.listError != null && provider.users.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                const SizedBox(height: 12),
                Text(provider.listError!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => provider.fetchUsers(refresh: true),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          );
        }

        if (provider.users.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 12),
                Text(l10n.adminUserListNoUsersFound,
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchUsers(refresh: true),
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: provider.users.length + (provider.hasMore ? 1 : 0),
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 68),
            itemBuilder: (context, i) {
              if (i >= provider.users.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final user = provider.users[i];
              final isSelected =
                  isWide && _inlineSelected?.id == user.id;
              return _UserCard(
                user: user,
                isSelected: isSelected,
                onTap: () => _selectUser(context, user, isWide),
              );
            },
          ),
        );
      },
    );
  }
}

// ── Empty detail placeholder ──────────────────────────────────────────────────

class _EmptyDetailPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_search_outlined,
              size: 72,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            l10n.adminUserListSelectUserPlaceholder,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ── User Card ─────────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  final User user;
  final VoidCallback onTap;
  final bool isSelected;

  const _UserCard({
    required this.user,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final avatarUrl = resolveAvatarUrl(user.avatarUrl);

    return ListTile(
      onTap: onTap,
      mouseCursor: SystemMouseCursors.click,
      selected: isSelected,
      selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
      leading: CircleAvatar(
        backgroundImage:
            avatarUrl != null ? NetworkImage(avatarUrl) : null,
        backgroundColor: colorScheme.primaryContainer,
        onBackgroundImageError: avatarUrl != null
            ? (_, __) {} // silently fall back to initials
            : null,
        child: avatarUrl == null
            ? Text(
                _initials(user),
                style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold),
              )
            : null,
      ),
      title: Text(
        user.fullName,
        style:
            theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.email,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: colorScheme.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: UserRoleChip(role: user.role),
              ),
              const SizedBox(width: 8),
              UserStatusBadge(status: user.status),
            ],
          ),
        ],
      ),
      isThreeLine: true,
      trailing: Icon(Icons.chevron_right,
          color: isSelected
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant),
    );
  }

  String _initials(User u) {
    final first = u.firstName.trim();
    final last = u.lastName.trim();
    if (first.isNotEmpty && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    } else if (first.isNotEmpty) {
      return first[0].toUpperCase();
    } else if (u.email.isNotEmpty) {
      return u.email[0].toUpperCase();
    }
    return '?';
  }
}

// ── Shared role / status badge widgets (public — reused in detail screen) ─────

class UserRoleChip extends StatelessWidget {
  final String role;
  const UserRoleChip({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = roleLabel(l10n, role);
    final color = roleAccentColor(role);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static String roleLabel(AppLocalizations l10n, String role) {
    switch (role) {
      case 'ADMIN':
        return l10n.adminUserListRoleAdmin;
      case 'RISK_OFFICER':
        return l10n.adminUserListRoleRiskOfficer;
      case 'SUPPORT_AGENT':
        return l10n.adminUserListRoleSupport;
      case 'MARKET_MAKER':
        return l10n.adminUserListRoleMarketMaker;
      case 'TRADER':
        return l10n.adminUserListRoleTrader;
      case 'FINANCE_MANAGER':
        return l10n.adminUserListRoleFinanceManager;
      case 'GUEST':
        return l10n.adminUserListRoleGuest;
      default:
        return _humanizeRoleCode(role);
    }
  }

  static String _humanizeRoleCode(String role) {
    if (role.isEmpty) return role;
    return role
        .split('_')
        .map((part) {
          if (part.isEmpty) return part;
          final lower = part.toLowerCase();
          return '${lower[0].toUpperCase()}${lower.length > 1 ? lower.substring(1) : ''}';
        })
        .join(' ');
  }

  static Color roleAccentColor(String role) {
    switch (role) {
      case 'ADMIN':
        return Colors.deepOrange;
      case 'RISK_OFFICER':
        return Colors.purple;
      case 'SUPPORT_AGENT':
        return Colors.blue;
      case 'MARKET_MAKER':
        return Colors.indigo;
      case 'TRADER':
        return Colors.green;
      case 'FINANCE_MANAGER':
        return const Color(0xFFF57C00);
      case 'GUEST':
      case 'VERIFIED_USER':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class UserStatusBadge extends StatelessWidget {
  final String status;
  const UserStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (label, color) = _statusInfo(l10n, status);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: color)),
      ],
    );
  }

  static (String, Color) _statusInfo(AppLocalizations l10n, String status) {
    switch (status) {
      case 'ACTIVE':
        return (l10n.adminUserListStatusActive, Colors.green);
      case 'BANNED':
        return (l10n.adminUserListStatusBanned, Colors.red);
      case 'PENDING':
        return (l10n.adminUserListStatusPending, Colors.orange);
      default:
        return (_humanizeStatusCode(status), Colors.grey);
    }
  }

  static String _humanizeStatusCode(String status) {
    if (status.isEmpty) return status;
    return status
        .split('_')
        .map((part) {
          if (part.isEmpty) return part;
          final lower = part.toLowerCase();
          return '${lower[0].toUpperCase()}${lower.length > 1 ? lower.substring(1) : ''}';
        })
        .join(' ');
  }
}
