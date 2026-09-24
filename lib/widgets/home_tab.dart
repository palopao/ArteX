import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/art_piece_model.dart';
import '../models/user_model.dart';
import '../screens/art_piece_detail_screen.dart';
import '../screens/vertical_list_screen.dart';
import '../screens/favorite_artists_screen.dart';
import '../services/firestore_service.dart';
import '../services/media_decode_service.dart';
import '../l10n/app_localizations.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Stream<List<ArtPieceModel>>? _piecesStream;
  Stream<List<UserModel>>? _usersStream;
  Stream<List<ArtPieceModel>>? _recentlyViewedStream;
  Object? _initializationError;

  @override
  void initState() {
    super.initState();
    try {
      final service = FirestoreService();
      _piecesStream = service.watchArtPieces();
      _usersStream = service.watchUsers();
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        _recentlyViewedStream = service.watchRecentlyViewedPieces(userId);
      }
    } on Object catch (error) {
      _initializationError = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_initializationError != null) {
      return Center(child: Text(l10n.loadPiecesError));
    }
    final piecesStream = _piecesStream;
    final usersStream = _usersStream;
    if (piecesStream == null || usersStream == null) {
      return Center(child: Text(l10n.loadPiecesError));
    }
    return StreamBuilder<List<ArtPieceModel>>(
      stream: piecesStream,
      builder: (context, piecesSnapshot) {
        if (piecesSnapshot.connectionState == ConnectionState.waiting) {
          return const _HomeLoading();
        }
        if (piecesSnapshot.hasError) {
          return _homeError(context, piecesSnapshot.error!, l10n);
        }
        final pieces = piecesSnapshot.data ?? const <ArtPieceModel>[];
        if (pieces.isEmpty) {
          return Center(child: Text(l10n.noPiecesAvailable));
        }
        final top = [...pieces]
          ..sort((a, b) => b.likesCount.compareTo(a.likesCount));
        final topPieces = top.take(3).toList(growable: false);
        return StreamBuilder<List<ArtPieceModel>>(
          stream: _recentlyViewedStream ?? Stream.value(pieces),
          builder: (context, recentlyViewedSnapshot) {
            if (recentlyViewedSnapshot.hasError) {
              return _homeError(
                context,
                recentlyViewedSnapshot.error!,
                l10n,
              );
            }
            final watching = (recentlyViewedSnapshot.data ?? pieces)
                .where((piece) => !piece.isDraft)
                .take(5)
                .toList(growable: false);
            return StreamBuilder<List<UserModel>>(
              stream: usersStream,
              builder: (context, usersSnapshot) {
            if (usersSnapshot.connectionState == ConnectionState.waiting) {
              return const _HomeLoading();
            }
            if (usersSnapshot.hasError) {
              return _homeError(context, usersSnapshot.error!, l10n);
            }

                return _HomeContent(
              watchingPieces: watching,
              topPieces: topPieces,
              userId: FirebaseAuth.instance.currentUser?.uid,
              allPieces: pieces,
              users: usersSnapshot.data ?? const <UserModel>[],
              onLike: _likePiece,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _homeError(
    BuildContext context,
    Object error,
    AppLocalizations l10n,
  ) {
    if (error is FirebaseException) {
      final details = '${error.code}: ${error.message ?? error.toString()}';
      if (error.code == 'failed-precondition') {
        final indexUrl =
            RegExp(r'https?://\S+').firstMatch(error.message ?? '')?.group(0);
        debugPrint('Firestore index required: $details');
        if (indexUrl != null) {
          debugPrint('Create the required Firestore index here: $indexUrl');
        }
      } else {
        debugPrint('Home Firestore error: $details');
      }
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: SelectableText(
            '${l10n.loadPiecesError}\n\n$details',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    debugPrint('Home stream error: $error');
    return Center(child: Text('${l10n.loadPiecesError}\n\n$error'));
  }

  Future<void> _likePiece(ArtPieceModel piece) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == piece.authorId) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).cannotLikeOwnPiece)),
      );
      return;
    }
    try {
      if (userId == null) return;
      await FirestoreService()
          .incrementArtPieceLikes(piece.id, requesterId: userId);
    } on FirebaseException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).likeFailed)),
      );
    }
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.watchingPieces,
    required this.topPieces,
    required this.allPieces,
    required this.users,
    required this.onLike,
    required this.userId,
  });

  final List<ArtPieceModel> watchingPieces;
  final List<ArtPieceModel> topPieces;
  final List<ArtPieceModel> allPieces;
  final List<UserModel> users;
  final Future<void> Function(ArtPieceModel piece) onLike;
  final String? userId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final likesByAuthor = <String, int>{};
    for (final piece in allPieces) {
      likesByAuthor.update(
        piece.authorId,
        (likes) => likes + piece.likesCount,
        ifAbsent: () => piece.likesCount,
      );
    }
    final artists = users
        .where((user) => likesByAuthor.containsKey(user.id))
        .toList(growable: false)
      ..sort((a, b) => (likesByAuthor[b.id] ?? 0).compareTo(likesByAuthor[a.id] ?? 0));
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        _SectionHeader(
          title: l10n.currentlyWatching,
          actionLabel: l10n.seeMore,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => VerticalListScreen(
                title: l10n.currentlyWatching,
                piecesStream: FirestoreService().watchArtPieces(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 272,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: watchingPieces.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, index) => SizedBox(
              width: 260,
              child: ArtPieceCard(
                piece: watchingPieces[index],
                onLike: () => onLike(watchingPieces[index]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _ActionButton(
          icon: Icons.favorite_border,
          label: l10n.likedPieces,
          onPressed: userId == null
              ? null
              : () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => VerticalListScreen(
                        title: l10n.likedPieces,
                        piecesStream:
                            FirestoreService().watchLikedPieces(userId!),
                      ),
                    ),
                  ),
        ),
        const SizedBox(height: 28),
        _SectionHeader(
          title: l10n.topLikedPieces,
          actionLabel: l10n.seeMore,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => VerticalListScreen(
                title: l10n.topLikedPieces,
                piecesStream:
                    FirestoreService().watchTopLikedPiecesAfter(3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          topPieces.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ArtPieceCard(
              piece: topPieces[index],
              rank: index + 1,
              onLike: () => onLike(topPieces[index]),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.favouriteArtists,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        if (artists.isEmpty)
          Text(l10n.noRecommendations)
        else
          ...artists.take(5).map(
                (artist) => AuthorCard(
                  name: artist.username,
                  profilePicBase64: artist.profilePicBase64,
                  totalLikes: likesByAuthor[artist.id] ?? 0,
                ),
              ),
        const SizedBox(height: 12),
        _ActionButton(
          icon: Icons.people_alt_outlined,
          label: l10n.favouriteArtists,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => FavoriteArtistsScreen(
                artists: artists,
                likesByAuthor: likesByAuthor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => Card(
        child: SizedBox(
          height: 100,
          child: Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
      ),
    );
  }
}

class ArtPieceCard extends StatefulWidget {
  const ArtPieceCard({
    required this.piece,
    this.showAuthor = true,
    this.rank,
    this.currentUserId,
    this.onEdit,
    this.onDelete,
    this.onPublish,
    this.onLike,
    this.onWatch,
    super.key,
  });

  final ArtPieceModel piece;
  final bool showAuthor;
  final int? rank;
  final String? currentUserId;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onPublish;
  final VoidCallback? onLike;
  final VoidCallback? onWatch;

  @override
  State<ArtPieceCard> createState() => _ArtPieceCardState();
}

class _ArtPieceCardState extends State<ArtPieceCard> {
  bool _likeBusy = false;
  bool _watchBusy = false;
  Timer? _actionTimer;
  Stream<UserModel?>? _authorStream;

  @override
  void initState() {
    super.initState();
    try {
      _authorStream = FirestoreService().watchUser(widget.piece.authorId);
    } on Object {
      _authorStream = null;
    }
  }

  @override
  void dispose() {
    _actionTimer?.cancel();
    super.dispose();
  }

  Future<void> _runAction({
    required VoidCallback? callback,
    required bool like,
  }) async {
    if (callback == null || (like ? _likeBusy : _watchBusy)) return;
    setState(() {
      if (like) {
        _likeBusy = true;
      } else {
        _watchBusy = true;
      }
    });
    callback();
    _actionTimer?.cancel();
    _actionTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        if (like) {
          _likeBusy = false;
        } else {
          _watchBusy = false;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final piece = widget.piece;
    final rank = widget.rank;
    final borderColor = rank == null
        ? Theme.of(context).colorScheme.outlineVariant
        : _rankColor(rank);
    return StreamBuilder<UserModel?>(
      stream: _authorStream,
      builder: (context, snapshot) {
        final author = snapshot.data;
        final authorName = author?.username.isNotEmpty == true
            ? author!.username
            : piece.authorName.isNotEmpty
                ? piece.authorName
                : piece.authorId;
        final authorPic = author?.profilePicBase64 ?? piece.authorPicBase64;
        return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: rank == null ? 1 : 2),
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ArtPieceDetailScreen(piece: piece),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showAuthor)
                Row(
                children: [
                  ProfileAvatar(
                    name: authorName,
                    profilePicBase64: authorPic,
                    radius: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      authorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (rank != null)
                    Text(
                      '#$rank',
                      style: TextStyle(
                        color: borderColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                piece.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 52,
                child: Text(
                  piece.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 10),
              if (widget.currentUserId == piece.authorId &&
                  (widget.onEdit != null ||
                      widget.onDelete != null ||
                      widget.onPublish != null))
                Row(
                  children: [
                    if (widget.onEdit != null)
                      OutlinedButton.icon(
                        onPressed: widget.onEdit,
                        icon: const Icon(Icons.edit, size: 16),
                        label: Text(AppLocalizations.of(context).edit),
                      ),
                    if (widget.onEdit != null && widget.onDelete != null)
                      const SizedBox(width: 8),
                    if (widget.onDelete != null)
                      OutlinedButton.icon(
                        onPressed: widget.onDelete,
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: Text(AppLocalizations.of(context).delete),
                      ),
                    if (widget.onPublish != null)
                      OutlinedButton.icon(
                        onPressed: widget.onPublish,
                        icon: const Icon(Icons.publish, size: 16),
                        label: Text(AppLocalizations.of(context).publish),
                      ),
                  ],
                )
              else
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Like',
                      onPressed: widget.onLike == null
                          ? null
                          : () => _runAction(
                                callback: widget.onLike,
                                like: true,
                              ),
                      icon: _likeBusy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.favorite_border),
                    ),
                    Text('${piece.likesCount}'),
                    const SizedBox(width: 8),
                    const Icon(Icons.visibility, size: 16),
                    const SizedBox(width: 4),
                    Text('${piece.viewsCount}'),
                    if (widget.onWatch != null) ...[
                      const SizedBox(width: 14),
                      IconButton(
                        tooltip: 'Watch',
                        onPressed: () => _runAction(
                          callback: widget.onWatch,
                          like: false,
                        ),
                        icon: _watchBusy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.bookmark_border),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
        );
      },
    );
  }

  static Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      default:
        return const Color(0xFFCD7F32);
    }
  }
}

class AuthorCard extends StatelessWidget {
  const AuthorCard({
    required this.name,
    required this.totalLikes,
    this.profilePicBase64,
    this.onTap,
    super.key,
  });

  final String name;
  final String? profilePicBase64;
  final int totalLikes;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: ProfileAvatar(name: name, profilePicBase64: profilePicBase64),
        title: Text(name),
        subtitle: Text('$totalLikes total likes'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    required this.name,
    this.profilePicBase64,
    this.radius = 22,
    super.key,
  });

  final String name;
  final String? profilePicBase64;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: decodeBase64InIsolate(profilePicBase64 ?? ''),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        return CircleAvatar(
          radius: radius,
          backgroundColor: bytes == null ? _avatarColor(name, context) : null,
          backgroundImage: bytes == null ? null : MemoryImage(bytes),
          child: bytes == null
              ? Text(
                  name.isEmpty ? '?' : name[0].toUpperCase(),
                  style: TextStyle(fontSize: radius * 0.8),
                )
              : null,
        );
      },
    );
  }

  Color _avatarColor(String value, BuildContext context) {
    final palette = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
      Colors.teal,
      Colors.indigo,
      Colors.deepOrange,
    ];
    final index = value.isEmpty ? 0 : value.codeUnitAt(0) % palette.length;
    return palette[index];
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        TextButton(onPressed: onPressed, child: Text(actionLabel)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
    );
  }
}
