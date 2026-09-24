import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../models/comment_model.dart';
import '../l10n/app_localizations.dart';
import '../services/firestore_service.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({required this.artPieceId, super.key});

  final String artPieceId;

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    final text = _controller.text.trim();
    final user = FirebaseAuth.instance.currentUser;
    if (text.isEmpty || user == null || _saving) return;
    setState(() => _saving = true);
    try {
      await FirestoreService().addComment(
        artPieceId: widget.artPieceId,
        authorId: user.uid,
        authorName: await _commentAuthorName(user),
        text: text,
      );
      if (mounted) _controller.clear();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).commentFailed)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }

  }

  Future<String> _commentAuthorName(User user) async {
    final profile = await FirestoreService().getUser(user.uid);
    return profile?.username ?? user.displayName ?? _emailLocalPart(user.email);
  }

  String _emailLocalPart(String? email) {
    final value = email?.trim() ?? '';
    final at = value.indexOf('@');
    return at > 0 ? value.substring(0, at) : (value.isEmpty ? 'User' : value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.seeComments)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: FirestoreService().watchComments(widget.artPieceId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text(l10n.commentsLoadFailed));
                }
                final comments = snapshot.data ?? const [];
                if (comments.isEmpty) {
                  return Center(child: Text(l10n.noComments));
                }
                final ids = comments
                    .map((comment) => comment['authorId'] as String?)
                    .whereType<String>()
                    .toSet();
                return FutureBuilder<List<UserModel>>(
                  future: FirestoreService().getUsersByIds(ids),
                  builder: (context, usersSnapshot) {
                    final users = <String, String>{
                      for (final user in usersSnapshot.data ?? const [])
                        user.id: user.username,
                    };
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: comments.length,
                      itemBuilder: (_, index) {
                        final comment = CommentModel.fromMap(
                          comments[index]['id'] as String? ?? '',
                          comments[index],
                        );
                        final authorName = users[comment.authorId] ??
                            _emailLocalPart(comment.authorName);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      authorName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (comment.createdAt != null)
                                    Text(
                                      _formatDate(comment.createdAt!),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(comment.text),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: l10n.writeComment,
                        border: const OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _addComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _saving ? null : _addComment,
                    tooltip: l10n.addComment,
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year} '
        '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
  }
}
