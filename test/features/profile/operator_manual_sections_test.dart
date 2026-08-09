import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crypto_trading_app/core/enums/user_role.dart';
import 'package:crypto_trading_app/features/profile/presentation/data/operator_manual_sections.dart';

void main() {
  group('ManualSection.filterForRole', () {
    test('keeps entries with empty visibleToRoles for every role (incl. guests via trader fallback)', () {
      for (final role in UserRole.values) {
        final filtered = kOperatorManualSections
            .map((s) => s.filterForRole(role))
            .where((s) => s.entries.isNotEmpty)
            .toList();

        // Glossary/FAQ/Contact use empty role lists and must always be visible.
        final titles = filtered.map((s) => s.icon).toSet();
        // Every role should still see at least the three universal sections
        // (Glossary / FAQ / Contact) plus Getting Started + Dashboard + Markets.
        expect(filtered.length, greaterThanOrEqualTo(3),
            reason: 'role=$role must keep universal sections');
        expect(titles, contains(Icons.menu_book_outlined)); // glossary
        expect(titles, contains(Icons.help_outline)); // faq
        expect(titles, contains(Icons.support_agent_outlined)); // contact
      }
    });

    test('admin sees admin / finance / risk / monitoring / config / broadcast sections', () {
      final filtered = kOperatorManualSections
          .map((s) => s.filterForRole(UserRole.admin))
          .where((s) => s.entries.isNotEmpty)
          .toList();

      final icons = filtered.map((s) => s.icon).toSet();
      expect(icons, contains(Icons.people_outline)); // user management
      expect(icons, contains(Icons.verified_user_outlined)); // security requests
      expect(icons, contains(Icons.payments_outlined)); // payment config
      expect(icons, contains(Icons.vpn_key_outlined)); // treasury E2E
      expect(icons, contains(Icons.tune_outlined)); // system config
      expect(icons, contains(Icons.campaign_outlined)); // broadcast
    });

    test('trader does not see admin-only sections', () {
      final filtered = kOperatorManualSections
          .map((s) => s.filterForRole(UserRole.trader))
          .where((s) => s.entries.isNotEmpty)
          .toList();

      final icons = filtered.map((s) => s.icon).toSet();
      expect(icons, isNot(contains(Icons.tune_outlined)),
          reason: 'trader must not see System Config');
      expect(icons, isNot(contains(Icons.campaign_outlined)),
          reason: 'trader must not see Broadcast');
      expect(icons, isNot(contains(Icons.payments_outlined)),
          reason: 'trader must not see Payment Configuration');
    });

    test('financeManager sees finance sections but not admin-only broadcast', () {
      final filtered = kOperatorManualSections
          .map((s) => s.filterForRole(UserRole.financeManager))
          .where((s) => s.entries.isNotEmpty)
          .toList();

      final icons = filtered.map((s) => s.icon).toSet();
      expect(icons, contains(Icons.payments_outlined)); // payment config
      expect(icons, contains(Icons.vpn_key_outlined)); // treasury E2E
      expect(icons, contains(Icons.account_tree_outlined)); // managed wallets (ops role)
      expect(icons, isNot(contains(Icons.campaign_outlined)),
          reason: 'finance manager must not see Broadcast');
    });

    test('supportAgent sees user management but not system config', () {
      final filtered = kOperatorManualSections
          .map((s) => s.filterForRole(UserRole.supportAgent))
          .where((s) => s.entries.isNotEmpty)
          .toList();

      final icons = filtered.map((s) => s.icon).toSet();
      expect(icons, contains(Icons.people_outline)); // user management
      expect(icons, contains(Icons.monitor_heart_outlined)); // monitoring
      expect(icons, isNot(contains(Icons.tune_outlined)),
          reason: 'support agent must not see System Config');
    });

    test('marketMaker sees market maker and dashboard sections but not admin finance', () {
      final filtered = kOperatorManualSections
          .map((s) => s.filterForRole(UserRole.marketMaker))
          .where((s) => s.entries.isNotEmpty)
          .toList();

      final icons = filtered.map((s) => s.icon).toSet();
      expect(icons, contains(Icons.precision_manufacturing_outlined));
      expect(icons, isNot(contains(Icons.payments_outlined)));
      expect(icons, isNot(contains(Icons.campaign_outlined)));
    });

    test('sections whose entire entry list is filtered out are empty', () {
      for (final role in UserRole.values) {
        for (final section in kOperatorManualSections) {
          final filtered = section.filterForRole(role);
          // Section should never carry entries the role cannot see.
          for (final entry in filtered.entries) {
            expect(
              entry.visibleToRoles.isEmpty ||
                  entry.visibleToRoles.contains(role),
              isTrue,
              reason: 'role=$role saw an entry it should not see in section with icon=${section.icon}',
            );
          }
        }
      }
    });

    test('riskOfficer sees monitoring + security + managed wallets but not admin broadcast', () {
      final filtered = kOperatorManualSections
          .map((s) => s.filterForRole(UserRole.riskOfficer))
          .where((s) => s.entries.isNotEmpty)
          .toList();

      final icons = filtered.map((s) => s.icon).toSet();
      expect(icons, contains(Icons.monitor_heart_outlined));
      expect(icons, contains(Icons.verified_user_outlined));
      expect(icons, contains(Icons.account_tree_outlined));
      expect(icons, isNot(contains(Icons.campaign_outlined)));
      expect(icons, isNot(contains(Icons.payments_outlined)));
    });

    test('unrecognized role falls back to trader-level visibility', () {
      final filtered = kOperatorManualSections
          .map((s) => s.filterForRole(UserRole.unrecognized))
          .where((s) => s.entries.isNotEmpty)
          .toList();

      final icons = filtered.map((s) => s.icon).toSet();
      // Universal entries are still present.
      expect(icons, contains(Icons.menu_book_outlined));
      expect(icons, contains(Icons.help_outline));
      expect(icons, contains(Icons.support_agent_outlined));
      // Admin-only entries are gated by explicit role list, not exposed.
      expect(icons, isNot(contains(Icons.campaign_outlined)));
      expect(icons, isNot(contains(Icons.tune_outlined)));
    });
  });
}