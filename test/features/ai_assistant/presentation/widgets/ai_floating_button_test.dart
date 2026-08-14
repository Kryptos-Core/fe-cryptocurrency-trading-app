import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:crypto_trading_app/app/router/app_routes.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/features/ai_assistant/presentation/widgets/ai_floating_button.dart';
import 'package:crypto_trading_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:crypto_trading_app/features/auth/presentation/providers/auth_provider.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockTokenService extends Mock implements TokenService {}

const Size _testSurface = Size(400, 800);

/// Returns a JWT-shaped string (`header.payload.signature`) where `payload`
/// decodes back to [claims]. The signature segment is filler — AuthProvider
/// only base64-decodes the middle segment to populate [_isAuthenticated].
String _fakeJwt(Map<String, dynamic> claims) {
  String b64(Map<String, dynamic> map) =>
      base64Url.encode(utf8.encode(jsonEncode(map))).replaceAll('=', '');
  final header = <String, dynamic>{'alg': 'none', 'typ': 'JWT'};
  return '${b64(header)}.${b64(claims)}.sig';
}

Future<AuthProvider> _buildAuthProvider({bool isAuthenticated = false}) async {
  final tokenService = _MockTokenService();
  final authRepo = _MockAuthRepository();
  // The provider's restoreSession() fires off a background fetch of the
  // current user profile via [getCurrentUser]; a network stub keeps it
  // from hitting real infrastructure.
  when(() => authRepo.getCurrentUser(any())).thenAnswer((_) async => const Left(ServerFailure()));

  final provider = AuthProvider(
    authRepository: authRepo,
    tokenService: tokenService,
  );
  if (isAuthenticated) {
    when(() => tokenService.getAccessToken())
        .thenReturn(_fakeJwt({'sub': 'test', 'role': 'user'}));
    provider.restoreSession();
  } else {
    when(() => tokenService.getAccessToken()).thenReturn(null);
  }
  return provider;
}

/// Pumps the button inside a real [GoRouter] so `context.push(...)` works
/// and we can inspect the active route page.
Future<void> _pumpButton(
  WidgetTester tester, {
  required AiFloatingButton button,
  Size size = _testSurface,
  bool isAuthenticated = false,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final auth = await _buildAuthProvider(isAuthenticated: isAuthenticated);
  addTearDown(auth.dispose);

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => Scaffold(
          body: Stack(
            children: [
              const ColoredBox(color: Colors.white),
              button,
            ],
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.aiAssistant,
        builder: (_, __) => const Scaffold(
          body: KeyedSubtree(
            key: ValueKey('ai-assistant-screen'),
            child: Text('ai-assistant-screen'),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const Scaffold(
          body: KeyedSubtree(
            key: ValueKey('login-screen'),
            child: Text('login-screen'),
          ),
        ),
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

Finder _fabIconFinder() => find.byIcon(Icons.smart_toy_outlined);

Offset _fabCenter(WidgetTester tester) =>
    tester.getCenter(_fabIconFinder());

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AiFloatingButton visibility', () {
    testWidgets('renders nothing when visible=false', (tester) async {
      await _pumpButton(
        tester,
        button: const AiFloatingButton(visible: false),
      );
      expect(find.byIcon(Icons.smart_toy_outlined), findsNothing);
    });

    testWidgets('renders the AI icon when visible=true', (tester) async {
      await _pumpButton(
        tester,
        button: const AiFloatingButton(),
      );
      expect(find.byIcon(Icons.smart_toy_outlined), findsOneWidget);
    });
  });

  group('AiFloatingButton hint', () {
    testWidgets('shows hint text on first appearance', (tester) async {
      await _pumpButton(
        tester,
        button: const AiFloatingButton(),
      );
      expect(find.text('Drag to move'), findsOneWidget);
    });

    testWidgets('hides hint after the first drag', (tester) async {
      await _pumpButton(
        tester,
        button: const AiFloatingButton(),
      );
      expect(find.text('Drag to move'), findsOneWidget);

      await tester.dragFrom(_fabCenter(tester), const Offset(-150, -200));
      await tester.pumpAndSettle();

      expect(find.text('Drag to move'), findsNothing);
    });

    testWidgets('hint stays hidden across subsequent drags', (tester) async {
      await _pumpButton(
        tester,
        button: const AiFloatingButton(),
      );

      await tester.dragFrom(_fabCenter(tester), const Offset(-150, -200));
      await tester.pumpAndSettle();
      expect(find.text('Drag to move'), findsNothing);

      // Re-locate the FAB (it has moved) and drag again — hint must stay gone.
      await tester.dragFrom(_fabCenter(tester), const Offset(60, 60));
      await tester.pumpAndSettle();
      expect(find.text('Drag to move'), findsNothing);
    });

    testWidgets(
      'hint bubble sits next to the FAB with a [_hintGap] gap (right side)',
      (tester) async {
        await _pumpButton(
          tester,
          button: const AiFloatingButton(),
        );

        // Default FAB position: bottom-right corner. Bubble must therefore
        // extend to the LEFT of the FAB with a small gap so the user
        // visually links "the speech bubble" with "the button".
        final fabRect = tester.getRect(
          find.descendant(
            of: find.byType(AiFloatingButton),
            matching: find.byType(Material),
          ),
        );
        final bubbleRect = tester.getRect(find.text('Drag to move'));

        // The bubble's rounded rect now touches the FAB edge; text is inset
        // by padding (12 px) so there's a small visible gap between text
        // and the FAB. The arrow bridges the remaining 0 px (corner-to-corner).
        final gap = fabRect.left - bubbleRect.right;
        expect(
          gap,
          greaterThanOrEqualTo(8),
          reason: 'Bubble overlaps the FAB. gap=$gap.',
        );
        expect(
          gap,
          lessThanOrEqualTo(30),
          reason: 'Bubble too far from FAB. gap=$gap.',
        );

        // Bubble and FAB must overlap vertically so they read as related.
        final fabCenterY = fabRect.center.dy;
        expect(
          bubbleRect.top <= fabCenterY,
          isTrue,
          reason: 'Bubble top ($bubbleRect) should be above FAB center.',
        );
        expect(
          bubbleRect.bottom >= fabCenterY,
          isTrue,
          reason: 'Bubble bottom ($bubbleRect) should be below FAB center.',
        );
      },
    );
  });

  group('AiFloatingButton tap vs drag', () {
    testWidgets('tap (no drag) pushes the AI assistant route when authed',
        (tester) async {
      await _pumpButton(
        tester,
        button: const AiFloatingButton(),
        isAuthenticated: true,
      );

      await tester.tap(_fabIconFinder());
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('ai-assistant-screen')), findsOneWidget);
    });

    testWidgets('tap (no drag) shows a snackbar with a Sign in action when guest',
        (tester) async {
      await _pumpButton(
        tester,
        button: const AiFloatingButton(),
        isAuthenticated: false,
      );

      // Sanity-check: provider should report unauthenticated.
      final authBefore = tester
          .element(find.byType(AiFloatingButton))
          .read<AuthProvider>();
      expect(authBefore.isAuthenticated, isFalse,
          reason: 'fixture should be guest');

      await tester.tap(_fabIconFinder());
      await tester.pumpAndSettle();

      // A snackbar is shown with a "Sign in" action that pushes the login route.
      expect(find.byType(SnackBar), findsOneWidget);
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('login-screen')), findsOneWidget);
    });

    testWidgets('drag does not push the AI assistant route', (tester) async {
      await _pumpButton(
        tester,
        button: const AiFloatingButton(),
      );

      await tester.dragFrom(_fabCenter(tester), const Offset(-150, -150));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('ai-assistant-screen')), findsNothing);
    });
  });

  group('AiFloatingButton snap-to-edge', () {
    testWidgets('snaps toward left edge when released on the left half',
        (tester) async {
      await _pumpButton(
        tester,
        button: const AiFloatingButton(),
      );
      const inset = 16.0;

      // Drag from default bottom-right toward the upper-left.
      await tester.dragFrom(_fabCenter(tester), const Offset(-300, -200));
      await tester.pumpAndSettle();

      final positioned = tester.widget<Positioned>(
        find.descendant(
          of: find.byType(AiFloatingButton),
          matching: find.byType(Positioned),
        ).last,
      );

      expect(positioned.left, inset);
      expect(positioned.top, isNotNull);
    });

    testWidgets('snaps toward right edge when released on the right half',
        (tester) async {
      await _pumpButton(
        tester,
        button: const AiFloatingButton(),
      );
      const fabSize = 56.0;
      const inset = 16.0;

      // Drag right then up — stays in the right half — and the button
      // should snap back to the right edge.
      await tester.dragFrom(_fabCenter(tester), const Offset(40, -200));
      await tester.pumpAndSettle();

      final positioned = tester.widget<Positioned>(
        find.descendant(
          of: find.byType(AiFloatingButton),
          matching: find.byType(Positioned),
        ).last,
      );

      expect(positioned.left, _testSurface.width - fabSize - inset);
    });
  });

  group('AiFloatingButton clamp', () {
    testWidgets('clamps drag past the upper-left corner', (tester) async {
      await _pumpButton(
        tester,
        button: const AiFloatingButton(),
      );

      const fabSize = 56.0;
      const inset = 16.0;
      const topPadding = 8.0;
      const bottomPadding = 80.0;

      // Drag far past the upper-left corner to force clamping.
      await tester.dragFrom(
        _fabCenter(tester),
        const Offset(-500, -800),
      );
      await tester.pumpAndSettle();

      final positioned = tester.widget<Positioned>(
        find.descendant(
          of: find.byType(AiFloatingButton),
          matching: find.byType(Positioned),
        ).last,
      );

      final maxX = _testSurface.width - fabSize - inset;
      const minY = topPadding;
      final maxY = _testSurface.height - fabSize - bottomPadding;

      expect(positioned.left, greaterThanOrEqualTo(inset));
      expect(positioned.left, lessThanOrEqualTo(maxX));
      expect(positioned.top, isNotNull);
      expect(positioned.top!, greaterThanOrEqualTo(minY));
      expect(positioned.top!, lessThanOrEqualTo(maxY));
    });

    testWidgets('clamps drag past the lower-right corner', (tester) async {
      await _pumpButton(
        tester,
        button: const AiFloatingButton(),
      );

      const fabSize = 56.0;
      const inset = 16.0;
      const topPadding = 8.0;
      const bottomPadding = 80.0;

      await tester.dragFrom(
        _fabCenter(tester),
        const Offset(500, 800),
      );
      await tester.pumpAndSettle();

      final positioned = tester.widget<Positioned>(
        find.descendant(
          of: find.byType(AiFloatingButton),
          matching: find.byType(Positioned),
        ).last,
      );

      final maxX = _testSurface.width - fabSize - inset;
      const minY = topPadding;
      final maxY = _testSurface.height - fabSize - bottomPadding;

      expect(positioned.left, greaterThanOrEqualTo(inset));
      expect(positioned.left, lessThanOrEqualTo(maxX));
      expect(positioned.top, isNotNull);
      expect(positioned.top!, greaterThanOrEqualTo(minY));
      expect(positioned.top!, lessThanOrEqualTo(maxY));
    });
  });
}