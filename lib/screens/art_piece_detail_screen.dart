import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/art_piece_model.dart';
import '../models/user_model.dart';
import '../services/media_decode_service.dart';
import '../services/firestore_service.dart';
import '../services/error_logging_service.dart';
import '../services/translation_service.dart';
import '../widgets/home_tab.dart';
import 'author_profile_screen.dart';
import 'comments_screen.dart';
import '../l10n/app_localizations.dart';

class ArtPieceDetailScreen extends StatefulWidget {
  const ArtPieceDetailScreen({
    required this.piece,
    this.appLanguage = 'English',
    super.key,
  });

  final ArtPieceModel piece;
  final String appLanguage;

  @override
  State<ArtPieceDetailScreen> createState() => _ArtPieceDetailScreenState();
}

Future<void> _deleteTemporaryFile(File file) async {
  try {
    if (await file.exists()) await file.delete();
  } on FileSystemException {
    // The temporary file is best-effort cleanup after the player is closed.
  }
}

class _ArtPieceDetailScreenState extends State<ArtPieceDetailScreen> {
  final _audioPlayer = AudioPlayer();
  final _tts = FlutterTts();
  final _translationService = TranslationService();
  File? _temporaryAudioFile;
  bool _showTranscript = false;
  bool _isTranslated = false;
  bool _isTranslating = false;
  String? _translatedTitle;
  String? _translatedDescription;
  String? _translatedContent;
  bool _isSpeaking = false;
  bool _isAudioPlaying = false;
  bool _isLiked = false;
  bool _isLikeLoading = false;
  Duration _audioPosition = Duration.zero;
  Duration _audioDuration = Duration.zero;
  String? _error;
  Stream<UserModel?>? _authorStream;
  late final StreamSubscription<PlayerState> _playerStateSubscription;
  late final StreamSubscription<Duration> _positionSubscription;
  late final StreamSubscription<Duration> _durationSubscription;

  ArtPieceModel get piece => widget.piece;

  String get _displayTitle => _translatedTitle ?? piece.title;
  String get _displayDescription => _translatedDescription ?? piece.description;

  @override
  void initState() {
    super.initState();
    String? userId;
    try {
      userId = FirebaseAuth.instance.currentUser?.uid;
    } on FirebaseException {
      userId = null;
    }
    if (userId != null) {
      unawaited(
        Future.wait([
          FirestoreService().recordUniqueArtPieceView(
            pieceId: piece.id,
            userId: userId,
          ),
          FirestoreService().recordArtPieceView(
            userId: userId,
            pieceId: piece.id,
          ),
          _loadLikeState(userId),
        ]),
      );
    }

    try {
      _authorStream = FirestoreService().watchUser(piece.authorId);
    } on Object {
      _authorStream = null;
    }
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((
      state,
    ) {
      if (mounted) {
        setState(() => _isAudioPlaying = state == PlayerState.playing);
      }
    });
    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) setState(() => _audioPosition = position);
    });
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) setState(() => _audioDuration = duration);
    });
  }

  Future<void> _loadLikeState(String userId) async {
    final liked = await FirestoreService().isArtPieceLiked(
      artPieceId: piece.id,
      userId: userId,
    );
    if (mounted) setState(() => _isLiked = liked);
  }

  Future<void> _toggleLike() async {
    String? userId;
    try {
      userId = FirebaseAuth.instance.currentUser?.uid;
    } on FirebaseException {
      if (mounted) setState(() => _isLiked = !_isLiked);
      return;
    }
    if (userId == null || _isLikeLoading || _isOwnPiece) return;
    setState(() => _isLikeLoading = true);
    try {
      final liked = await FirestoreService().toggleArtPieceLike(
        artPieceId: piece.id,
        userId: userId,
      );
      if (mounted) setState(() => _isLiked = liked);
    } on Object catch (error) {
      if (mounted) _showError('$error');
    } finally {
      if (mounted) setState(() => _isLikeLoading = false);
    }
  }

  String get _displayText {
    final text = piece.type == 'audio' ? piece.description : piece.contentData;
    return _translatedContent ?? text;
  }

  Future<void> _toggleTranslation() async {
    if (_isTranslated) {
      setState(() {
        _isTranslated = false;
        _translatedTitle = null;
        _translatedDescription = null;
        _translatedContent = null;
      });
      return;
    }

    setState(() => _isTranslating = true);
    try {
      final translated = await _translationService.translatePiece(
        title: piece.title,
        description: piece.description,
        content: piece.type == 'text' ? piece.contentData : piece.description,
        targetLanguage: Localizations.localeOf(context).languageCode,
      );
      if (!mounted) return;
      setState(() {
        _translatedTitle = translated.title;
        _translatedDescription = translated.description;
        if (piece.type == 'text') _translatedContent = translated.content;
        _isTranslated = true;
      });
    } on Object catch (error) {
      _showError('Translation failed: $error');
    } finally {
      if (mounted) setState(() => _isTranslating = false);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _playerStateSubscription.cancel();
    _positionSubscription.cancel();
    _durationSubscription.cancel();
    _tts.stop();
    final file = _temporaryAudioFile;
    if (file != null) {
      unawaited(_deleteTemporaryFile(file));
    }
    super.dispose();
  }

  Future<void> _playAudio() async {
    try {
      final bytes = await decodeBase64InIsolate(piece.contentData);
      if (bytes == null) {
        _showError('This audio file has invalid Base64 data.');
        return;
      }
      final format = MediaFormat.detectAudio(bytes);
      if (format == null) {
        unawaited(ErrorLoggingService.recordUnsupportedAudio(
          StackTrace.current,
          source: piece.id,
        ));
        if (mounted) {
          _showError('Unsupported audio format. Expected MP3, FLAC, or M4A.');
        }
        return;
      }
      _temporaryAudioFile ??= File(
        '${Directory.systemTemp.path}${Platform.pathSeparator}'
        'artex_${piece.id}$format',
      )..writeAsBytesSync(bytes, flush: true);
      if (_isAudioPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(DeviceFileSource(_temporaryAudioFile!.path));
      }
      if (mounted) setState(() => _error = null);
    } on Object catch (error) {
      _showError('Audio could not be initialized: $error');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() => _error = message);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _speakText() async {
    try {
      if (_isSpeaking) {
        await _tts.stop();
        if (mounted) setState(() => _isSpeaking = false);
        return;
      }
      await _tts.setLanguage(_ttsLocale(widget.appLanguage));
      await _tts.speak(_displayText);
      if (mounted) setState(() => _isSpeaking = true);
    } on Object catch (error) {
      _showError('Text-to-speech is unavailable: $error');
    }
  }

  String _ttsLocale(String language) {
    switch (language.toLowerCase()) {
      case 'portuguese':
        return 'pt-PT';
      case 'spanish':
        return 'es-ES';
      default:
        return 'en-US';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(_displayTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          StreamBuilder<UserModel?>(
            stream: _authorStream,
            builder: (context, snapshot) {
              final author = snapshot.data;
              final authorName = author?.username.isNotEmpty == true
                  ? author!.username
                  : piece.authorName.isNotEmpty
                      ? piece.authorName
                      : piece.authorId;
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => AuthorProfileScreen(
                      authorId: piece.authorId,
                      name: authorName,
                      profilePicBase64: author?.profilePicBase64 ??
                          piece.authorPicBase64,
                    ),
                  ),
                ),
                child: AuthorCard(
                  name: authorName,
                  profilePicBase64:
                      author?.profilePicBase64 ?? piece.authorPicBase64,
                  totalLikes: piece.likesCount,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(_displayTitle, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(_displayDescription),
          const SizedBox(height: 20),
          _buildContent(context),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: Colors.red.shade700)),
          ],
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => CommentsScreen(artPieceId: piece.id),
              ),
            ),
            icon: const Icon(Icons.comment_outlined),
            label: Text(l10n.seeComments),
          ),
          OutlinedButton.icon(
            onPressed: _isOwnPiece
                ? null
                : _toggleLike,
            icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border),
            label: Text(_isLiked ? 'Liked' : 'Like'),
          ),
          OutlinedButton.icon(
            onPressed: _isTranslating ? null : _toggleTranslation,
            icon: const Icon(Icons.translate),
            label: _isTranslating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_isTranslated
                    ? l10n.showOriginal
                    : l10n.translateTo(
                        _activeLanguageName(Localizations.localeOf(context)),
                      )),
          ),
        ],
      ),
    );
  }

  String _activeLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'pt':
        return 'Portuguese';
      case 'es':
        return 'Spanish';
      default:
        return 'English';
    }
  }

  bool get _isOwnPiece {
    try {
      return FirebaseAuth.instance.currentUser?.uid == piece.authorId;
    } on FirebaseException {
      return false;
    }
  }

  Widget _buildContent(BuildContext context) {
    switch (piece.type) {
      case 'picture':
        return FutureBuilder<Uint8List?>(
          future: decodeBase64InIsolate(piece.contentData),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const _MediaLoadingPlaceholder();
            }
            final bytes = snapshot.data;
            return bytes == null
                ? const _ContentMessage('This picture has invalid Base64 data.')
                : ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _buildPicture(bytes),
                  );
          },
        );
      case 'audio':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              onPressed: _playAudio,
              icon: Icon(_isAudioPlaying ? Icons.pause : Icons.play_arrow),
              label: Text(_isAudioPlaying ? 'Pause Audio' : 'Play Audio'),
            ),
            if (_audioDuration > Duration.zero) _buildAudioControls(),
            OutlinedButton(
              onPressed: () =>
                  setState(() => _showTranscript = !_showTranscript),
              child: Text(_showTranscript ? 'Hide Text' : 'Read Text'),
            ),
            if (_showTranscript) _textPanel(context),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _textPanel(context),
            OutlinedButton.icon(
              onPressed: _speakText,
              icon: Icon(_isSpeaking ? Icons.stop : Icons.volume_up),
              label: Text(_isSpeaking ? 'Stop Audio' : 'Listen to Audio'),
            ),
          ],
        );
    }
  }

  Widget _textPanel(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(_displayText),
      ),
    );
  }

  Widget _buildPicture(Uint8List bytes) {
    final format = MediaFormat.detectImage(bytes);
    if (format == 'svg') {
      try {
        return SvgPicture.string(utf8.decode(bytes), fit: BoxFit.contain);
      } on Object {
        return const _UnsupportedMedia(format: 'SVG');
      }
    }
    if (format == null) {
      return const _UnsupportedMedia(format: 'unknown image');
    }
    if (!MediaFormat.supportedRasterFormats.contains(format)) {
      return _UnsupportedMedia(format: format.toUpperCase());
    }
    return Image.memory(
      bytes,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) =>
          _UnsupportedMedia(format: format.toUpperCase()),
    );
  }

  Widget _buildAudioControls() {
    final maxSeconds = _audioDuration.inMilliseconds.toDouble();
    final position = _audioPosition.inMilliseconds
        .clamp(0, _audioDuration.inMilliseconds)
        .toDouble();
    return Column(
      children: [
        Slider(
          min: 0,
          max: maxSeconds,
          value: position,
          onChanged: (value) =>
              _audioPlayer.seek(Duration(milliseconds: value.round())),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatDuration(_audioPosition)),
            Text(_formatDuration(_audioDuration)),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration value) {
    final minutes = value.inMinutes.toString().padLeft(2, '0');
    final seconds = (value.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _MediaLoadingPlaceholder extends StatelessWidget {
  const _MediaLoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: Text('Loading media…')),
    );
  }
}

class _UnsupportedMedia extends StatelessWidget {
  const _UnsupportedMedia({required this.format});

  final String format;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.broken_image_outlined, size: 48),
          const SizedBox(height: 12),
          Text('Format $format is not natively supported'),
          const SizedBox(height: 4),
          const Text(
            'This file can remain stored, but cannot be previewed here.',
          ),
        ],
      ),
    );
  }
}

class MediaFormat {
  const MediaFormat._();

  static const supportedRasterFormats = {'png', 'jpg', 'webp', 'gif', 'bmp'};

  static String? detectImage(Uint8List bytes) {
    if (_startsWith(bytes, [0x89, 0x50, 0x4E, 0x47])) {
      return 'png';
    }
    if (_startsWith(bytes, [0xFF, 0xD8, 0xFF])) {
      return 'jpg';
    }
    if (_startsWith(bytes, [0x47, 0x49, 0x46, 0x38])) {
      return 'gif';
    }
    if (_startsWith(bytes, [0x42, 0x4D])) {
      return 'bmp';
    }
    if (_startsWith(bytes, [0x52, 0x49, 0x46, 0x46]) &&
        _containsAscii(bytes, 'WEBP')) {
      return 'webp';
    }
    final text = _tryDecodeText(bytes);
    if (text != null &&
        RegExp(r'<svg(?:\s|>)', caseSensitive: false).hasMatch(text)) {
      return 'svg';
    }
    if (_startsWith(bytes, [0x00, 0x00, 0x01, 0x00])) {
      return 'ico';
    }
    if (_startsWith(bytes, [0x49, 0x49, 0x2A, 0x00]) ||
        _startsWith(bytes, [0x4D, 0x4D, 0x00, 0x2A])) {
      return 'tif';
    }
    if (_isFtyp(bytes, 'avif')) {
      return 'avif';
    }
    if (_isFtyp(bytes, 'heic') || _isFtyp(bytes, 'heif')) return 'heic/heif';
    if (_startsWith(bytes, [0xFF, 0x0A]) ||
        _startsWith(bytes, [0x00, 0x00, 0x00, 0x0C])) {
      return 'jxl';
    }
    return null;
  }

  static String? detectAudio(Uint8List bytes) {
    if (_startsWith(bytes, [0x49, 0x44, 0x33]) || _looksLikeMp3Frame(bytes)) {
      return '.mp3';
    }
    if (_startsWith(bytes, [0x66, 0x4C, 0x61, 0x43])) return '.flac';
    if (_isFtyp(bytes, 'M4A') ||
        _isFtyp(bytes, 'mp42') ||
        _isFtyp(bytes, 'isom')) {
      return '.m4a';
    }
    return null;
  }

  static bool _looksLikeMp3Frame(Uint8List bytes) {
    return bytes.length > 1 && bytes[0] == 0xFF && (bytes[1] & 0xE0) == 0xE0;
  }

  static bool _isFtyp(Uint8List bytes, String brand) {
    return bytes.length >= 12 &&
        bytes[4] == 0x66 &&
        bytes[5] == 0x74 &&
        bytes[6] == 0x79 &&
        bytes[7] == 0x70 &&
        _containsAscii(
          bytes.sublist(8, bytes.length > 32 ? 32 : bytes.length),
          brand,
        );
  }

  static bool _containsAscii(Uint8List bytes, String value) {
    final haystack = String.fromCharCodes(bytes).toLowerCase();
    return haystack.contains(value.toLowerCase());
  }

  static bool _startsWith(Uint8List bytes, List<int> signature) {
    if (bytes.length < signature.length) return false;
    for (var index = 0; index < signature.length; index++) {
      if (bytes[index] != signature[index]) return false;
    }
    return true;
  }

  static String? _tryDecodeText(Uint8List bytes) {
    try {
      return utf8.decode(bytes);
    } on FormatException {
      return null;
    }
  }
}

class _ContentMessage extends StatelessWidget {
  const _ContentMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) => Center(child: Text(message));
}
