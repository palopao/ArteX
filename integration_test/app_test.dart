import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:artex/firebase_options.dart';
import 'package:artex/l10n/app_localizations.dart';
import 'package:artex/screens/auth_screen.dart';
import 'package:artex/screens/art_piece_detail_screen.dart';
import 'package:artex/screens/main_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('user can log in, browse home, like a piece, and go back',
      (tester) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final email = const String.fromEnvironment('ARTEX_TEST_EMAIL');
    final password = const String.fromEnvironment('ARTEX_TEST_PASSWORD');
    expect(
      email.isNotEmpty && password.isNotEmpty,
      isTrue,
      reason:
          'Run with --dart-define=ARTEX_TEST_EMAIL=... --dart-define=ARTEX_TEST_PASSWORD=...',
    );

    await FirebaseAuth.instance.signOut();
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AuthScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), email);
    await tester.enterText(find.byType(TextFormField).at(1), password);
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(MainScreen), findsOneWidget);

    await tester.tap(find.text('My Area'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Quiet Geometry'));
    await tester.pumpAndSettle();
    expect(find.byType(ArtPieceDetailScreen), findsOneWidget);

    await tester.tap(find.text('Like'));
    await tester.pump();
    expect(find.text('Liked'), findsOneWidget);

    expect(find.byTooltip('Back'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(MainScreen), findsOneWidget);
    expect(find.text('Currently watching'), findsOneWidget);
  });
}
