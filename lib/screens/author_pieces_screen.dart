import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/art_piece_model.dart';
import '../services/firestore_service.dart';
import '../widgets/home_tab.dart';

class AuthorPiecesScreen extends StatelessWidget {
  const AuthorPiecesScreen({
    required this.authorId,
    required this.authorName,
    super.key,
  });

  final String authorId;
  final String authorName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createdPiecesProfile)),
      body: StreamBuilder<List<ArtPieceModel>>(
        stream: FirestoreService().watchUserArtPieces(
          authorId: authorId,
          draftsOnly: false,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(l10n.loadPiecesError));
          }
          final pieces = snapshot.data ?? const <ArtPieceModel>[];
          if (pieces.isEmpty) {
            return Center(child: Text(l10n.noPublishedPiecesYet));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pieces.length,
            itemBuilder: (_, index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ArtPieceCard(piece: pieces[index]),
            ),
          );
        },
      ),
    );
  }
}
