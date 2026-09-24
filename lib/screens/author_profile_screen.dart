import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/art_piece_model.dart';
import '../models/user_model.dart';
import '../providers/app_providers.dart';
import '../services/firestore_service.dart';
import '../widgets/home_tab.dart';
import 'author_pieces_screen.dart';
import 'chat_screen.dart';

class AuthorProfileScreen extends ConsumerStatefulWidget {
  const AuthorProfileScreen({
    required this.authorId,
    required this.name,
    this.profilePicBase64,
    super.key,
  });

  final String authorId;
  final String name;
  final String? profilePicBase64;

  @override
  ConsumerState<AuthorProfileScreen> createState() =>
      _AuthorProfileScreenState();
}

class _AuthorProfileScreenState extends ConsumerState<AuthorProfileScreen> {
  bool _isSendingRequest = false;
  Stream<UserModel?>? _targetUserStream;

  @override
  void initState() {
    super.initState();
    try {
      _targetUserStream = FirestoreService().watchUser(widget.authorId);
    } on FirebaseException {
      _targetUserStream = null;
    }
  }

  Future<void> _sendFriendRequest() async {
    final requesterId = _currentUserId;
    if (requesterId == null || requesterId == widget.authorId) return;
    setState(() => _isSendingRequest = true);
    try {
      await FirestoreService().sendFriendRequest(
        targetUserId: widget.authorId,
        requesterUserId: requesterId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).friendRequestSent)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).friendRequestFailed)),
      );
    } finally {
      if (mounted) setState(() => _isSendingRequest = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);
    final isSelf = _currentUserId == widget.authorId;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.authorProfile)),
      body: StreamBuilder<UserModel?>(
        stream: _targetUserStream ?? Stream.value(null),
        builder: (context, snapshot) {
          final targetUser = snapshot.data;
          final isFriend =
              targetUser?.friendsList.contains(_currentUserId) ?? false;
          final requestPending =
              targetUser?.friendRequests.contains(_currentUserId) ?? false;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
          Center(
            child: ProfileAvatar(
              name: widget.name,
              profilePicBase64: widget.profilePicBase64,
              radius: 48,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              widget.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 8),
          Center(child: Text(l10n.artistProfile)),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: Text(l10n.createdPiecesProfile),
              subtitle: Text(l10n.viewPublishedWork(widget.name)),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AuthorPiecesScreen(
                    authorId: widget.authorId,
                    authorName: widget.name,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (!isSelf && !isFriend && !requestPending)
            OutlinedButton.icon(
              onPressed: _isSendingRequest ? null : _sendFriendRequest,
              icon: const Icon(Icons.person_add_alt_1),
              label: _isSendingRequest
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.addFriend),
            ),
          if (!isSelf)
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ChatScreen(recipientId: widget.authorId),
                ),
              ),
              icon: const Icon(Icons.chat_bubble_outline),
              label: Text(l10n.chat),
            ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.favorite_border),
              title: Text(l10n.totalLikesLabel),
              subtitle: Text(l10n.likesAcrossPublishedPieces),
              onTap: () => _showAuthorStats(context),
            ),
          ),
            ],
          );
        },
      ),
    );
  }

  String? get _currentUserId {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } on FirebaseException {
      return null;
    }
  }

  void _showAuthorStats(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => StreamBuilder<List<ArtPieceModel>>(
        stream: FirestoreService().watchUserArtPieces(
          authorId: widget.authorId,
          draftsOnly: false,
        ),
        builder: (context, snapshot) {
          final pieces = snapshot.data ?? const <ArtPieceModel>[];
          final likes = pieces.fold<int>(
            0,
            (sum, piece) => sum + piece.likesCount,
          );
          final l10n = AppLocalizations.of(context);
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '${l10n.createdPiecesProfile}: ${pieces.length}\n'
              '${l10n.totalLikesLabel}: $likes',
            ),
          );
        },
      ),
    );
  }
}
