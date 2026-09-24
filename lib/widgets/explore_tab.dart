import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/art_piece_model.dart';
import '../providers/app_providers.dart';
import 'home_tab.dart';

class ExploreTab extends ConsumerStatefulWidget {
  const ExploreTab({super.key});

  @override
  ConsumerState<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends ConsumerState<ExploreTab> {
  final _searchController = TextEditingController();
  String _selectedType = 'all';
  String _durationFilter = 'Any duration';
  String _readingFilter = 'Any reading time';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ArtPieceModel> _filteredPieces(List<ArtPieceModel> pieces) {
    final query = _searchController.text.trim().toLowerCase();
    return pieces.where((piece) {
      final matchesType = _selectedType == 'all' || piece.type == _selectedType;
      final matchesSearch = query.isEmpty ||
          piece.title.toLowerCase().contains(query) ||
          piece.authorName.toLowerCase().contains(query) ||
          piece.type.toLowerCase().contains(query);
      final matchesDuration = _selectedType != 'audio' ||
          _matchesAudioDuration(piece.audioDurationSeconds);
      final matchesReading =
          _selectedType != 'text' || _matchesReadingTime(piece.readTimeMinutes);
      return matchesType && matchesSearch && matchesDuration && matchesReading;
    }).toList(growable: false);
  }

  bool _matchesAudioDuration(int? seconds) {
    if (seconds == null || _durationFilter == 'Any duration') return true;
    if (_durationFilter == 'Under 5 min') return seconds < 300;
    if (_durationFilter == '5–15 min') return seconds >= 300 && seconds <= 900;
    return seconds > 900;
  }

  bool _matchesReadingTime(int? minutes) {
    if (minutes == null || _readingFilter == 'Any reading time') return true;
    if (_readingFilter == 'Under 5 min') return minutes < 5;
    if (_readingFilter == '5–15 min') return minutes >= 5 && minutes <= 15;
    return minutes > 15;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Stream<List<ArtPieceModel>> piecesStream;
    try {
      piecesStream =
          ref.read(firestoreServiceProvider).watchPublishedArtPieces();
    } on Object {
      piecesStream = Stream<List<ArtPieceModel>>.value(const []);
    }
    return StreamBuilder<List<ArtPieceModel>>(
      stream: piecesStream,
      builder: (context, snapshot) {
        final pieces = _filteredPieces(snapshot.data ?? const []);
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text(l10n.explore,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: l10n.searchByPieceAuthorType,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: l10n.searchEmpty,
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'all', label: Text(l10n.all)),
                ButtonSegment(value: 'audio', label: Text(l10n.audio)),
                ButtonSegment(value: 'text', label: Text(l10n.text)),
                ButtonSegment(value: 'picture', label: Text(l10n.picture)),
              ],
              selected: {_selectedType},
              onSelectionChanged: (selection) {
                setState(() {
                  _selectedType = selection.first;
                  _durationFilter = 'Any duration';
                  _readingFilter = 'Any reading time';
                });
              },
              showSelectedIcon: false,
            ),
            if (_selectedType == 'audio') _buildAudioFilter(l10n),
            if (_selectedType == 'text') _buildReadingFilter(l10n),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.recommendedForYou,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Text(l10n.piecesCount(pieces.length)),
              ],
            ),
            const SizedBox(height: 12),
            if (snapshot.hasError)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text(l10n.loadPiecesError)),
              )
            else if (!snapshot.hasData)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (pieces.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text(l10n.noRecommendations)),
              )
            else
              ...pieces.map(
                (piece) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ArtPieceCard(piece: piece),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildAudioFilter(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: DropdownButtonFormField<String>(
        initialValue: _durationFilter,
        decoration: InputDecoration(
          labelText: l10n.audioDuration,
          border: const OutlineInputBorder(),
        ),
        items: _durationOptions(l10n)
            .map((value) => DropdownMenuItem(
                  value: value,
                  child: Text(_durationLabel(value, l10n)),
                ))
            .toList(),
        onChanged: (value) => setState(() => _durationFilter = value!),
      ),
    );
  }

  Widget _buildReadingFilter(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: DropdownButtonFormField<String>(
        initialValue: _readingFilter,
        decoration: InputDecoration(
          labelText: l10n.readingTime,
          border: const OutlineInputBorder(),
        ),
        items: _readingOptions(l10n)
            .map((value) => DropdownMenuItem(
                  value: value,
                  child: Text(_readingLabel(value, l10n)),
                ))
            .toList(),
        onChanged: (value) => setState(() => _readingFilter = value!),
      ),
    );
  }
}

List<String> _durationOptions(AppLocalizations l10n) => [
      'Any duration',
      'Under 5 min',
      '5–15 min',
      'Over 15 min',
    ];

List<String> _readingOptions(AppLocalizations l10n) => [
      'Any reading time',
      'Under 5 min',
      '5–15 min',
      'Over 15 min',
    ];

String _durationLabel(String value, AppLocalizations l10n) {
  switch (value) {
    case 'Under 5 min':
      return l10n.underFiveMinutes;
    case '5–15 min':
      return l10n.fiveToFifteenMinutes;
    case 'Over 15 min':
      return l10n.overFifteenMinutes;
    default:
      return l10n.anyDuration;
  }
}

String _readingLabel(String value, AppLocalizations l10n) {
  switch (value) {
    case 'Under 5 min':
      return l10n.underFiveMinutes;
    case '5–15 min':
      return l10n.fiveToFifteenMinutes;
    case 'Over 15 min':
      return l10n.overFifteenMinutes;
    default:
      return l10n.anyReadingTime;
  }
}
