import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/art_piece_model.dart';
import '../widgets/home_tab.dart';

class VerticalListScreen extends StatelessWidget {
  const VerticalListScreen({
    required this.title,
    required this.piecesStream,
    super.key,
  });

  final String title;
  final Stream<List<ArtPieceModel>> piecesStream;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: StreamBuilder<List<ArtPieceModel>>(
        stream: piecesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(l10n.loadPiecesError));
          }
          final pieces = snapshot.data ?? const <ArtPieceModel>[];
          if (pieces.isEmpty) {
            return Center(child: Text(l10n.noPiecesAvailable));
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
