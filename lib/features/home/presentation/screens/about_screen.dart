import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:crypto_trading_app/app/router/app_routes.dart';
import 'package:crypto_trading_app/core/enums/user_role.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/responsive/app_responsive.dart';
import 'package:crypto_trading_app/core/widgets/app_empty_state.dart';
import 'package:crypto_trading_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/features/home/presentation/screens/manual_detail_screen.dart';
import 'package:crypto_trading_app/features/profile/presentation/data/operator_manual_sections.dart';
import 'package:crypto_trading_app/features/profile/presentation/widgets/manual_intro_tile.dart';
import 'package:crypto_trading_app/features/profile/presentation/widgets/manual_list_tile.dart';
import 'package:crypto_trading_app/features/profile/presentation/widgets/manual_section_card.dart';

/// In-app operator manual.
///
/// Replaces the old `AboutScreen` that only opened an external GitHub URL.
/// Now shows a role-aware catalogue of [ManualSection]s rendered through
/// [ManualSectionCard] + [ManualListTile] so the screen is visually
/// consistent with the rest of the app (Profile, Settings).
class OperatorManualScreen extends StatelessWidget {
  const OperatorManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final role = _resolveRole(context);

    final visibleSections = kOperatorManualSections
        .map((s) => s.filterForRole(role))
        .where((s) => s.entries.isNotEmpty)
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.manualTitle)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= AppBreakpoints.compact;
          if (visibleSections.isEmpty) {
            return AppEmptyState(
              icon: Icons.help_outline,
              title: l10n.manualTitle,
              message: l10n.manualEmptyForRole,
            );
          }
          return AppCenteredContent(
            child: isWide
                ? _buildWideLayout(context, l10n, visibleSections)
                : _buildCompactLayout(context, l10n, visibleSections),
          );
        },
      ),
    );
  }

  // ── Layouts ───────────────────────────────────────────────────────────────

  Widget _buildCompactLayout(
    BuildContext context,
    AppLocalizations l10n,
    List<ManualSection> sections,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ManualIntroTile(
          title: l10n.manualTitle,
          subtitle: l10n.manualSubtitle,
          description: l10n.manualIntroHeroDesc,
        ),
        const SizedBox(height: 16),
        for (final section in sections) ...[
          _buildSectionCard(context, l10n, section),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildWideLayout(
    BuildContext context,
    AppLocalizations l10n,
    List<ManualSection> sections,
  ) {
    // Two columns: split sections evenly; odd section goes to the left.
    final mid = (sections.length / 2).ceil();
    final left = sections.sublist(0, mid);
    final right = sections.sublist(mid);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                for (final s in left) ...[
                  _buildSectionCard(context, l10n, s),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: [
                for (final s in right) ...[
                  _buildSectionCard(context, l10n, s),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section rendering ─────────────────────────────────────────────────────

  Widget _buildSectionCard(
    BuildContext context,
    AppLocalizations l10n,
    ManualSection section,
  ) {
    return ManualSectionCard(
      title: section.title(l10n),
      description: section.description(l10n),
      children: [
        for (final entry in section.entries)
          ManualListTile(
            icon: entry.icon,
            title: entry.title(l10n),
            subtitle: entry.subtitle(l10n),
            onTap: () => _onEntryTap(context, entry),
          ),
      ],
    );
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _onEntryTap(BuildContext context, ManualEntry entry) {
    final goRouter = GoRouter.of(context);
    switch (entry.kind) {
      case ManualEntryKind.route:
        final target = entry.target;
        if (target == null) return;
        // Most manual entries deep-link into a normal screen on top of
        // the current one; we keep `push` for those so the user can
        // pop back to where they came from. The exception is the
        // root shell route (`/`): pushing another MainScreen on top of
        // the existing one leaves **two** `_MainScreenState`s alive in
        // the Navigator stack at the same time, which triggers
        // `Multiple widgets used the same GlobalKey` (flutter#140586
        // — the same State<StatefulWidget> auto-GlobalKey is reserved
        // for both Elements). Using `go` clears the stack and replaces
        // it with a single MainScreen, eliminating the duplicate.
        if (target == AppRoutes.root) {
          goRouter.go(target);
        } else {
          goRouter.push(target);
        }
      case ManualEntryKind.detail:
        final topic = _topicFromTarget(entry.target);
        if (topic == null) return;
        // Use `pushReplacement` rather than `push` so the manual page is
        // replaced by the detail page instead of stacked on top of it.
        // This is the workaround for go_router 14.x's known bug where
        // pushing a top-level detail route from a sibling top-level route
        // while the ShellRoute is already in the navigation stack trips
        // `NavigatorState._debugCheckDuplicatedPageKeys`
        // (`'!keyReservation.contains(key)': is not true`, flutter#140586):
        // the shell page key is reused briefly during the transition and
        // collides with the existing page in `widget.pages`. Replacing the
        // current page avoids having two sibling top-level pages in the
        // root Navigator at the same time. The detail widget still receives
        // the topic via `state.extra` so it rebuilds identically.
        goRouter.pushReplacement(_detailPath(topic), extra: topic);
    }
  }

  String _detailPath(ManualDetailTopic topic) {
    switch (topic) {
      case ManualDetailTopic.glossary:
        return AppRoutes.manualDetailGlossary;
      case ManualDetailTopic.faq:
        return AppRoutes.manualDetailFaq;
      case ManualDetailTopic.contact:
        return AppRoutes.manualDetailContact;
    }
  }

  ManualDetailTopic? _topicFromTarget(String? target) {
    switch (target) {
      case 'glossary':
        return ManualDetailTopic.glossary;
      case 'faq':
        return ManualDetailTopic.faq;
      case 'contact':
        return ManualDetailTopic.contact;
      default:
        return null;
    }
  }

  // ── Role resolution ──────────────────────────────────────────────────────

  UserRole _resolveRole(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isAuthenticated) return UserRole.trader;
    return auth.role;
  }
}

/// Legacy alias kept so existing imports (`const AboutScreen()`) keep
/// compiling while the router and call-sites migrate to the manual.
typedef AboutScreen = OperatorManualScreen;