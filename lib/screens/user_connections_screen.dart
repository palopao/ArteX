import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../l10n/app_localizations.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import 'author_profile_screen.dart';
import 'chat_screen.dart';

class UserConnectionsScreen extends StatefulWidget {
  const UserConnectionsScreen({
    required this.userId,
    required this.friendRequests,
    super.key,
  });

  final String userId;
  final bool friendRequests;

  @override
  State<UserConnectionsScreen> createState() => _UserConnectionsScreenState();
}

class _UserConnectionsScreenState extends State<UserConnectionsScreen> {
  final Set<String> _handledRequestIds = {};
  bool _actionInProgress = false;

  Future<void> _handleRequest(
    String senderUserId, {
    required bool accept,
  }) async {
    setState(() => _actionInProgress = true);
    try {
      final service = FirestoreService();
      if (accept) {
        await service.acceptFriendRequest(
          currentUserId: widget.userId,
          senderUserId: senderUserId,
        );
      } else {
        await service.rejectFriendRequest(
          currentUserId: widget.userId,
          senderUserId: senderUserId,
        );
      }

      if (!mounted) return;
      setState(() => _handledRequestIds.add(senderUserId));
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            accept ? l10n.friendRequestAccepted : l10n.friendRequestRejected,
          ),
        ),
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${error.code}: ${error.message ?? ''}')),
      );
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }

  }

  Future<void> _removeFriend(UserModel friend) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.removeFriend),
        content: Text(l10n.removeFriendConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.remove),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _actionInProgress = true);
    try {
      await FirestoreService().removeFriend(
        currentUserId: widget.userId,
        friendId: friend.id,
      );
      if (!mounted) return;
      setState(() => _handledRequestIds.add(friend.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.friendRemoved)),
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${error.code}: ${error.message ?? ''}')),
      );
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.friendRequests ? l10n.friendRequests : l10n.friends),
      ),
      body: FutureBuilder<UserModel?>(
        future: FirestoreService().getUser(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(l10n.loadPiecesError));
          }
          final user = snapshot.data;
          if (user == null) return Center(child: Text(l10n.pleaseLogInAgain));
          final ids = (widget.friendRequests
                  ? user.friendRequests
                  : user.friendsList)
              .where((id) => !_handledRequestIds.contains(id))
              .toList(growable: false);
          if (ids.isEmpty) {
            return Center(
              child: Text(widget.friendRequests ? l10n.noFriendRequests : l10n.noFriends),
            );
          }
          return FutureBuilder<List<UserModel>>(
            future: FirestoreService().getUsersByIds(ids),
            builder: (context, usersSnapshot) {
              if (usersSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (usersSnapshot.hasError) {
                return Center(child: Text(l10n.loadPiecesError));
              }
              final users = usersSnapshot.data ?? const <UserModel>[];
              if (users.isEmpty) {
                return Center(
                  child: Text(widget.friendRequests ? l10n.noFriendRequests : l10n.noFriends),
                );
              }
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (_, index) {
                  final requestedUser = users[index];
                  return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      requestedUser.username.isEmpty
                          ? '?'
                          : requestedUser.username[0].toUpperCase(),
                    ),
                  ),
                  title: Text(requestedUser.username),
                  subtitle: Text(requestedUser.email),
                  onTap: widget.friendRequests
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => AuthorProfileScreen(
                                authorId: requestedUser.id,
                                name: requestedUser.username,
                                profilePicBase64:
                                    requestedUser.profilePicBase64,
                              ),
                            ),
                          ),
                  trailing: widget.friendRequests
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton.icon(
                              onPressed: _actionInProgress
                                  ? null
                                  : () => _handleRequest(
                                        requestedUser.id,
                                        accept: true,
                                      ),
                              icon: const Icon(Icons.check),
                              label: Text(l10n.accept),
                            ),
                            IconButton(
                              tooltip: l10n.reject,
                              onPressed: _actionInProgress
                                  ? null
                                  : () => _handleRequest(
                                        requestedUser.id,
                                        accept: false,
                                      ),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: _actionInProgress
                                  ? null
                                  : () => Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => AuthorProfileScreen(
                                            authorId: requestedUser.id,
                                            name: requestedUser.username,
                                            profilePicBase64:
                                                requestedUser.profilePicBase64,
                                          ),
                                        ),
                                      ),
                              child: Text(l10n.viewProfile),
                            ),
                            TextButton(
                              onPressed: _actionInProgress
                                  ? null
                                  : () => Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => ChatScreen(
                                            recipientId: requestedUser.id,
                                          ),
                                        ),
                                      ),
                              child: Text(l10n.chat),
                            ),
                            IconButton(
                              tooltip: l10n.removeFriend,
                              onPressed: _actionInProgress
                                  ? null
                                  : () => _removeFriend(requestedUser),
                              icon: const Icon(Icons.person_remove_outlined),
                            ),
                          ],
                        ),
                );
                },
              );
            },
          );
        },
      ),
    );
  }
}
