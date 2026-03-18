import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/utils/avatar_url_helper.dart';
import 'package:crypto_trading_app/domain/entities/user.dart';
import 'package:crypto_trading_app/presentation/providers/admin_users_provider.dart';
import 'admin_user_detail_screen.dart';

// ── Constants ──────────────────────────────────────────────────────────────────

const _kRoles = [
  ('Tất cả', null),
  ('Trader', 'TRADER'),
  ('Verified', 'VERIFIED_USER'),
  ('Market Maker', 'MARKET_MAKER'),
  ('Support', 'SUPPORT_AGENT'),
  ('Risk Officer', 'RISK_OFFICER'),
  ('Admin', 'ADMIN'),
];

const _kStatuses = [
  ('Tất cả', null),
  ('Hoạt động', 'ACTIVE'),
  ('Bị khoá', 'BANNED'),
  ('Chờ duyệt', 'PENDING'),
];

// Responsive breakpoint: above this width, show master-detail side-by-side.
const _kWideBreakpoint = 720.0;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Người dùng'),
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
          final isWide = constraints.maxWidth >= _kWideBreakpoint;
          if (isWide) {
            return _buildMasterDetail(context);
          }
          return _buildListPanel(context, isWide: false);
        },
      ),
    );
  }

  // ── Wide layout: list panel + inline detail ──────────────────────────────────

  Widget _buildMasterDetail(BuildContext context) {
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
            child: _buildListPanel(context, isWide: true),
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

  Widget _buildListPanel(BuildContext context, {required bool isWide}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        _buildSearchBar(colorScheme),
        _buildFilterSection(),
        const Divider(height: 1),
        _buildStatsSummary(),
        Expanded(child: _buildUserList(isWide: isWide)),
      ],
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Tìm theo email hoặc tên...',
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

  Widget _buildFilterSection() {
    return Consumer<AdminUsersProvider>(
      builder: (_, provider, __) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterGroup(
                label: 'Role',
                chips: _kRoles,
                selected: provider.roleFilter,
                onSelect: (v) => provider.applyFilters(role: v),
              ),
              const SizedBox(height: 4),
              _buildFilterGroup(
                label: 'Trạng thái',
                chips: _kStatuses,
                selected: provider.statusFilter,
                onSelect: (v) => provider.applyFilters(status: v),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterGroup({
    required String label,
    required List<(String, String?)> chips,
    required String? selected,
    required void Function(String?) onSelect,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$label:',
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 2,
            children: chips.map((chip) {
              final isSelected = selected == chip.$2;
              return FilterChip(
                label: Text(chip.$1),
                selected: isSelected,
                onSelected: (_) => onSelect(chip.$2),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSummary() {
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
                'Tổng: ${provider.totalUsers} người dùng',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserList({required bool isWide}) {
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
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (provider.users.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                SizedBox(height: 12),
                Text('Không tìm thấy người dùng',
                    style: TextStyle(color: Colors.grey)),
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
            'Chọn một người dùng để xem chi tiết',
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
          const SizedBox(height: 4),
          Row(
            children: [
              UserRoleChip(role: user.role),
              const SizedBox(width: 6),
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
    final (label, color) = _roleInfo(role);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style:
            TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  static (String, Color) _roleInfo(String role) {
    switch (role) {
      case 'ADMIN':
        return ('Admin', Colors.deepOrange);
      case 'RISK_OFFICER':
        return ('Risk Officer', Colors.purple);
      case 'SUPPORT_AGENT':
        return ('Support', Colors.blue);
      case 'VERIFIED_USER':
        return ('Verified', Colors.teal);
      case 'MARKET_MAKER':
        return ('Market Maker', Colors.indigo);
      case 'TRADER':
        return ('Trader', Colors.green);
      default:
        return (role, Colors.grey);
    }
  }
}

class UserStatusBadge extends StatelessWidget {
  final String status;
  const UserStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = _statusInfo(status);
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

  static (String, Color) _statusInfo(String status) {
    switch (status) {
      case 'ACTIVE':
        return ('Active', Colors.green);
      case 'BANNED':
        return ('Banned', Colors.red);
      case 'PENDING':
        return ('Pending', Colors.orange);
      default:
        return (status, Colors.grey);
    }
  }
}
