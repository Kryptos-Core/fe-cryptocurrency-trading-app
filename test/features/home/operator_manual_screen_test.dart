import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:crypto_trading_app/app/router/app_routes.dart';
import 'package:crypto_trading_app/core/enums/user_role.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/features/home/presentation/screens/about_screen.dart';
import 'package:crypto_trading_app/features/home/presentation/screens/manual_detail_screen.dart';
import 'package:crypto_trading_app/features/profile/presentation/data/operator_manual_sections.dart';

/// Minimal AuthProvider stub — we only need [isAuthenticated] and [role].
class _StubAuthProvider extends ChangeNotifier implements AuthProvider {
  _StubAuthProvider({
    required this.isAuthenticated,
    required this.role,
  });

  @override
  final bool isAuthenticated;
  @override
  final UserRole role;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Future<void> _pumpManual(
  WidgetTester tester, {
  required UserRole role,
  required bool authenticated,
  required Size size,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: ChangeNotifierProvider<AuthProvider>.value(
        value: _StubAuthProvider(isAuthenticated: authenticated, role: role),
        child: const OperatorManualScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Pumps the manual screen inside a real [GoRouter] so the regression
/// test can verify that pushing the detail screen does not throw
/// `!keyReservation.contains(key)`.
Future<void> _pumpManualWithRouter(
  WidgetTester tester, {
  required UserRole role,
  required bool authenticated,
  required Size size,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final auth =
      _StubAuthProvider(isAuthenticated: authenticated, role: role);
  final router = GoRouter(
    initialLocation: AppRoutes.manual,
    refreshListenable: auth,
    routes: [
      GoRoute(
        path: AppRoutes.manual,
        builder: (_, __) => const OperatorManualScreen(),
        routes: [
          GoRoute(
            path: 'detail/:topic',
            builder: (_, state) {
              final extra = state.extra;
              if (extra is ManualDetailTopic) {
                return ManualDetailScreen(topic: extra);
              }
              return const ManualDetailScreen(
                topic: ManualDetailTopic.glossary,
              );
            },
          ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ChangeNotifierProvider<AuthProvider>.value(
      value: auth,
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders AppBar + intro tile + first section card on compact',
      (tester) async {
    await _pumpManual(
      tester,
      role: UserRole.trader,
      authenticated: true,
      size: const Size(400, 800),
    );

    // AppBar title is "Operator Manual" — appears in AppBar AND in intro tile.
    expect(find.text('Operator Manual'), findsWidgets);
    // Intro tile subtitle is "Step-by-step guide for every role and tab".
    expect(
        find.text('Step-by-step guide for every role and tab'), findsOneWidget);
    // First section card is "Getting Started".
    expect(find.text('Getting Started'), findsOneWidget);
  });

  testWidgets('compact trader does not see admin-only sections in first viewport',
      (tester) async {
    await _pumpManual(
      tester,
      role: UserRole.trader,
      authenticated: true,
      size: const Size(400, 800),
    );

    // Admin-only section cards are way down the list and not visible in a
    // compact 800-tall viewport without scrolling.
    expect(find.text('System Configuration'), findsNothing);
    expect(find.text('Broadcast Notification'), findsNothing);
    expect(find.text('Payment Configuration'), findsNothing);
    expect(find.text('User Management'), findsNothing);
  });

  testWidgets('wide admin layout shows admin sections in first viewport',
      (tester) async {
    await _pumpManual(
      tester,
      role: UserRole.admin,
      authenticated: true,
      size: const Size(1600, 1200),
    );

    // Wide layout splits sections into two columns — most fit on screen.
    expect(find.text('User Management'), findsWidgets);
    expect(find.text('System Configuration'), findsWidgets);
    expect(find.text('Broadcast Notification'), findsWidgets);
    expect(find.text('Payment Configuration'), findsWidgets);
  });

  testWidgets('finance manager sees Payment Config and Treasury E2E on wide',
      (tester) async {
    await _pumpManual(
      tester,
      role: UserRole.financeManager,
      authenticated: true,
      size: const Size(1600, 1200),
    );

    expect(find.text('Payment Configuration'), findsWidgets);
    expect(find.text('Treasury E2E Configuration'), findsWidgets);
    expect(find.text('Broadcast Notification'), findsNothing);
    expect(find.text('System Configuration'), findsNothing);
  });

  testWidgets('catalogue exposes consistent, non-empty role-aware sections',
      (tester) async {
    expect(kOperatorManualSections, isNotEmpty);
    for (final section in kOperatorManualSections) {
      expect(section.entries, isNotEmpty,
          reason: 'section with icon=${section.icon} must have entries');
      for (final entry in section.entries) {
        if (entry.kind == ManualEntryKind.route) {
          expect(entry.target, isNotNull);
        }
      }
    }
  });

  // Regression test for the `!keyReservation.contains(key)` assertion that
  // fired when the manual screen pushed [ManualDetailScreen] via raw
  // Navigator.push instead of GoRouter.push. The fix nests the detail
  // route under `/manual` and pushes with `state.extra`.
  testWidgets('opening a Glossary entry renders ManualDetailScreen without throwing',
      (tester) async {
    await _pumpManualWithRouter(
      tester,
      role: UserRole.trader,
      authenticated: true,
      size: const Size(1600, 1200),
    );

    // Find the first Glossary ListTile and tap it. Wide layout puts every
    // section on screen so the tile is built and tappable.
    final glossaryTile = find.widgetWithText(ListTile, 'Glossary').first;
    expect(glossaryTile, findsOneWidget);

    await tester.tap(glossaryTile);
    await tester.pumpAndSettle();

    // Detail screen has its own AppBar with the localized title.
    expect(find.text('Glossary'), findsWidgets);
    // The body renders Markdown — make sure the renderer produced SOMETHING.
    expect(find.byType(SelectableText), findsWidgets);
  });
}