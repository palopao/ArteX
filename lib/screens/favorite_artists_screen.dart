import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/user_model.dart';
import '../widgets/home_tab.dart';

class FavoriteArtistsScreen extends StatelessWidget {
  const FavoriteArtistsScreen({
    required this.artists,
    required this.likesByAuthor,
    super.key,
  });

  final List<UserModel> artists;
  final Map<String, int> likesByAuthor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.favouriteArtists)),
      body: artists.isEmpty
          ? Center(child: Text(l10n.noRecommendations))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: artists.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final artist = artists[index];
                return AuthorCard(
                  name: artist.username,
                  profilePicBase64: artist.profilePicBase64,
                  totalLikes: likesByAuthor[artist.id] ?? 0,
                );
              },
            ),
    );
  }
}
