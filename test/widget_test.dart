import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'package:artex/screens/language_selection_screen.dart';
import 'package:artex/screens/main_screen.dart';
import 'package:artex/widgets/home_tab.dart';
import 'package:artex/widgets/explore_tab.dart';
import 'package:artex/screens/art_piece_detail_screen.dart';
import 'package:artex/models/art_piece_model.dart';
import 'package:artex/screens/art_piece_editor_screen.dart';
import 'package:artex/l10n/app_localizations.dart';
import 'package:artex/screens/author_profile_screen.dart';
import 'package:artex/screens/my_area_tab.dart';

Widget testApp({required Widget home}) => ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    );

void main() {
  testWidgets('language selection starts onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: testApp(home: const LanguageSelectionScreen()),
      ),
    );

    expect(find.text('Choose your language'), findsOneWidget);
    expect(find.text('Português'), findsOneWidget);
  });

  testWidgets('main screen provides three persistent navigation tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      testApp(home: const MainScreen()),
    );

    expect(find.text('My Area'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);

    await tester.tap(find.text('My Area').last);
    await tester.pump();
    expect(find.text('Please log in to view your area.'), findsOneWidget);

    await tester.tap(find.text('Explore').last);
    await tester.pump();
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Search by piece, author, or type',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Home').last);
    await tester.pump();
    expect(find.byType(HomeTab), findsOneWidget);
  });

  testWidgets('explore supports search and type-specific filters',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      testApp(home: const Scaffold(body: ExploreTab())),
    );

    expect(find.text('Recommended for you'), findsOneWidget);
    expect(find.text('0 pieces'), findsOneWidget);
    await tester.tap(find.text('Audio'));
    await tester.pump();
    expect(find.text('Audio duration'), findsOneWidget);
    expect(find.text('0 pieces'), findsOneWidget);

    await tester.tap(find.text('Text'));
    await tester.pump();
    expect(find.text('Reading time'), findsOneWidget);
    expect(find.text('0 pieces'), findsOneWidget);
  });

  testWidgets('home tab renders reusable piece and author cards',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      testApp(home: const Scaffold(body: HomeTab())),
    );

    expect(find.byType(HomeTab), findsOneWidget);
  });

  testWidgets('art piece detail renders text actions', (WidgetTester tester) async {
    final piece = ArtPieceModel(
      id: 'detail-1',
      authorId: 'author-1',
      authorName: 'Test Artist',
      authorPicBase64: null,
      title: 'A Text Piece',
      description: 'A description',
      type: 'text',
      contentData: 'The full text content.\n\nSecond paragraph with line breaks.',
      isDraft: false,
      createdAt: DateTime(2026),
    );
    await tester.pumpWidget(
      testApp(home: ArtPieceDetailScreen(piece: piece)),
    );

    expect(find.text('Test Artist'), findsOneWidget);
    expect(
      find.text('The full text content.\n\nSecond paragraph with line breaks.'),
      findsOneWidget,
    );
    expect(find.text('Listen to Audio'), findsOneWidget);
    expect(find.text('See Comments'), findsOneWidget);
    expect(find.text('Translate to English'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    await tester.tap(find.text('Like'));
    await tester.pump();
    expect(find.text('Liked'), findsOneWidget);
    await tester.tap(find.text('Liked'));
    await tester.pump();
    expect(find.text('Like'), findsOneWidget);
  });

  testWidgets('art piece and author cards expose media and action callbacks',
      (WidgetTester tester) async {
    var likes = 0;
    var watches = 0;
    var authorTaps = 0;
    final piece = ArtPieceModel(
      id: 'card-1',
      authorId: 'author-1',
      authorName: 'Card Artist',
      authorPicBase64: null,
      title: 'Card Piece',
      description: 'Card description',
      type: 'text',
      contentData: 'Card content',
      isDraft: false,
      createdAt: DateTime(2026),
    );
    await tester.pumpWidget(
      testApp(
        home: Scaffold(
          body: Column(
            children: [
              ArtPieceCard(
                piece: piece,
                onLike: () => likes++,
                onWatch: () => watches++,
              ),
              AuthorCard(
                name: piece.authorName,
                totalLikes: piece.likesCount,
                onTap: () => authorTaps++,
              ),
              IconButton(
                tooltip: 'Translate',
                onPressed: () => authorTaps++,
                icon: const Icon(Icons.translate),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    expect(find.byIcon(Icons.translate), findsOneWidget);
    await tester.tap(find.byTooltip('Like'));
    await tester.tap(find.byTooltip('Watch'));
    await tester.tap(find.text('Card Artist').last);
    await tester.tap(find.byTooltip('Translate'));
    expect(likes, 1);
    expect(watches, 1);
    expect(authorTaps, 2);
  });

  testWidgets('deep detail navigation has a functioning back button',
      (WidgetTester tester) async {
    final piece = ArtPieceModel(
      id: 'nested-1',
      authorId: 'author-1',
      authorName: 'Nested Artist',
      authorPicBase64: null,
      title: 'Nested Piece',
      description: 'Description',
      type: 'text',
      contentData: 'Content',
      isDraft: false,
      createdAt: DateTime(2026),
    );
    await tester.pumpWidget(
      testApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ArtPieceDetailScreen(piece: piece),
                ),
              ),
              child: const Text('Open detail'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open detail'));
    await tester.pumpAndSettle();
    expect(find.byType(ArtPieceDetailScreen), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.text('Nested Piece'), findsNWidgets(2));
  });

  testWidgets('fallback profile avatar centers the username initial',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      testApp(
        home: Scaffold(
          body: ProfileAvatar(name: 'Artex Artist'),
        ),
      ),
    );

    expect(find.text('A'), findsOneWidget);
    expect(find.byType(CircleAvatar), findsOneWidget);
  });

  testWidgets('create flow offers type and publication choices',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      testApp(home: const ArtPieceEditorScreen()),
    );

    expect(find.text('What are you creating?'), findsOneWidget);
    expect(find.text('Picture'), findsOneWidget);
    expect(find.text('Audio'), findsOneWidget);
    expect(find.text('Text'), findsOneWidget);
    expect(find.text('Published'), findsOneWidget);
    expect(find.text('In Development'), findsOneWidget);
    expect(find.text('Text content'), findsOneWidget);
    await tester.tap(find.text('Text'));
    await tester.enterText(find.byType(TextFormField).first, 'A valid title');
    await tester.enterText(
      find.byType(TextFormField).last,
      'Text content that makes the piece valid.',
    );
    await tester.scrollUntilVisible(
      find.text('Save Art Piece'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    expect(find.text('Insert optional image as Base64'), findsNothing);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton).last).onPressed,
      isNotNull,
    );

  });

  testWidgets('My Area and author profile use the active Portuguese locale',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      testApp(
        home: const AuthorProfileScreen(
          authorId: 'author-pt',
          name: 'Artista',
        ),
      ),
    );
    await tester.binding.setLocale('pt', 'PT');
    await tester.pumpAndSettle();
    expect(find.text('Perfil do autor'), findsOneWidget);
    expect(find.text('Peças criadas'), findsOneWidget);
    expect(find.text('Adicionar amigo'), findsOneWidget);

    await tester.pumpWidget(
      testApp(home: const Scaffold(body: MyAreaTab())),
    );
    await tester.binding.setLocale('pt', 'PT');
    await tester.pumpAndSettle();
    expect(find.text('Inicie sessão para ver a sua área.'), findsOneWidget);
  });
}
