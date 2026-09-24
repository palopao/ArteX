import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/art_piece_model.dart';
import '../l10n/app_localizations.dart';
import '../services/firestore_service.dart';
import '../providers/app_providers.dart';
import '../widgets/home_tab.dart';
import 'account_details_screen.dart';
import 'account_settings_screen.dart';
import 'art_piece_editor_screen.dart';
import 'user_connections_screen.dart';

class MyAreaTab extends ConsumerWidget {
  const MyAreaTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);
    final userId = _currentUserId;
    if (userId == null) {
      return Center(child: Text(l10n.pleaseLogIn));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(l10n.myArea, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 20),
        _ActionTile(
          icon: Icons.palette_outlined,
          title: l10n.createdPieces,
          subtitle: l10n.viewPublishedPieces,
          onTap: () => _open(context, const MyPiecesScreen(draftsOnly: false)),
        ),
        _ActionTile(
          icon: Icons.edit_note,
          title: l10n.piecesInDevelopment,
          subtitle: l10n.continueDrafts,
          onTap: () => _open(context, const MyPiecesScreen(draftsOnly: true)),
        ),
        _ActionTile(
          icon: Icons.add_circle_outline,
          title: l10n.createNewArtPiece,
          subtitle: l10n.createPieceSubtitle,
          onTap: () => _createPiece(context),
        ),
        _ActionTile(
          icon: Icons.settings_outlined,
          title: l10n.definitions,
          subtitle: l10n.settingsSubtitle,
          onTap: () => _open(context, const AccountSettingsScreen()),
        ),
        _ActionTile(
          icon: Icons.manage_accounts_outlined,
          title: l10n.accountDetails,
          subtitle: l10n.accountDetailsSubtitle,
          onTap: () => _open(context, const AccountDetailsScreen()),
        ),
        _ActionTile(
          icon: Icons.people_outline,
          title: l10n.friends,
          subtitle: l10n.friendsSubtitle,
          onTap: () => _open(
            context,
            UserConnectionsScreen(
              userId: userId,
              friendRequests: false,
            ),
          ),
        ),
        _ActionTile(
          icon: Icons.person_add_alt_1,
          title: l10n.friendRequests,
          subtitle: l10n.friendRequestsSubtitle,
          onTap: () => _open(
            context,
            UserConnectionsScreen(
              userId: userId,
              friendRequests: true,
            ),
          ),
        ),
      ],
    );
  }

  static void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  Future<void> _createPiece(BuildContext context) async {
    final savedAsDraft = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const ArtPieceEditorScreen(),
      ),
    );
    if (!context.mounted || savedAsDraft == null) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MyPiecesScreen(
          draftsOnly: savedAsDraft,
          showCreatedSuccess: !savedAsDraft,
        ),
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
}

class MyPiecesScreen extends StatefulWidget {
  const MyPiecesScreen({
    required this.draftsOnly,
    this.showCreatedSuccess = false,
    super.key,
  });

  final bool draftsOnly;
  final bool showCreatedSuccess;

  @override
  State<MyPiecesScreen> createState() => _MyPiecesScreenState();
}

class _MyPiecesScreenState extends State<MyPiecesScreen> {
  final _deletedPieceIds = <String>{};
  @override
  void initState() {
    super.initState();
    if (widget.showCreatedSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(
              AppLocalizations.of(context).artPieceCreatedSuccessfully,
            )),
          );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final userId = _currentUserId;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.draftsOnly
            ? l10n.piecesInDevelopment
            : l10n.createdPieces),
      ),
      body: userId == null
          ? Center(child: Text(l10n.pleaseLogInAgain))
          : StreamBuilder<List<ArtPieceModel>>(
              stream: FirestoreServiceForScreen.watchPieces(userId, widget.draftsOnly),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _MyPiecesLoading();
                }
                if (snapshot.hasError) {
                  return _MyPiecesMessage(
                    message: '${l10n.loadPiecesError}\n${snapshot.error}',
                  );
                }
                if (!snapshot.hasData) {
                  return _MyPiecesMessage(message: l10n.noPiecesAvailable);
                }
                final pieces = snapshot.data!
                    .where((piece) => !_deletedPieceIds.contains(piece.id))
                    .toList(growable: false);
                if (pieces.isEmpty) {
                  return Center(
                    child: Text(widget.draftsOnly
                        ? l10n.noDraftsYet
                        : l10n.noPublishedPiecesYet),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pieces.length,
                  itemBuilder: (_, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ArtPieceCard(
                      piece: pieces[index],
                      showAuthor: false,
                      currentUserId: userId,
                      onEdit: widget.draftsOnly
                          ? () => _editDraft(context, pieces[index])
                          : null,
                      onPublish: widget.draftsOnly
                          ? () => _publishDraft(context, pieces[index])
                          : null,
                      onDelete: () => _deletePiece(context, pieces[index]),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _editDraft(BuildContext context, ArtPieceModel piece) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ArtPieceEditorScreen(initialPiece: piece),
      ),
    );
  }

  Future<void> _deletePiece(
    BuildContext context,
    ArtPieceModel piece,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deletePiece),
        content: Text(l10n.areYouSure),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await FirestoreService().deleteArtPiece(piece.id);
      if (!mounted) return;
      setState(() => _deletedPieceIds.add(piece.id));
    } on FirebaseException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${l10n.deletePieceFailed} (${error.code}): '
            '${error.message ?? error.code}',
          ),
        ),
      );
    }

  }

  Future<void> _publishDraft(
    BuildContext context,
    ArtPieceModel piece,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.publish),
        content: Text(l10n.publishDraftConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.publish),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await FirestoreService().publishArtPiece(piece.id);
      if (!context.mounted) return;
      setState(() => _deletedPieceIds.add(piece.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.publishedSuccessfully)),
      );
    } on FirebaseException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${error.code}: ${error.message ?? ''}')),
      );
    }
  }

  String? get _currentUserId {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } on FirebaseException {
      return null;
    }
  }
}

class FirestoreServiceForScreen {
  static Stream<List<ArtPieceModel>> watchPieces(String userId, bool draftsOnly) {
    return FirestoreService().watchUserArtPieces(
      authorId: userId,
      draftsOnly: draftsOnly,
    );
  }
}

class _MyPiecesMessage extends StatelessWidget {
  const _MyPiecesMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

class _MyPiecesLoading extends StatefulWidget {
  const _MyPiecesLoading();

  @override
  State<_MyPiecesLoading> createState() => _MyPiecesLoadingState();
}

class _MyPiecesLoadingState extends State<_MyPiecesLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, _) => _SkeletonCard(progress: _controller.value),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlight = Color.lerp(
      base,
      Theme.of(context).colorScheme.surface,
      (progress * 2 - 1).abs(),
    )!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 18, width: 150, color: highlight),
            const SizedBox(height: 12),
            Container(height: 14, width: double.infinity, color: highlight),
            const SizedBox(height: 8),
            Container(height: 14, width: 220, color: highlight),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(icon, size: 30),
        title: Text(title),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
