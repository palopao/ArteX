import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';

import '../l10n/app_localizations.dart';
import '../models/art_piece_model.dart';
import '../services/firestore_service.dart';
import '../services/profile_image_service.dart';

class ArtPieceEditorScreen extends StatefulWidget {
  const ArtPieceEditorScreen({this.initialPiece, super.key});

  final ArtPieceModel? initialPiece;

  @override
  State<ArtPieceEditorScreen> createState() => _ArtPieceEditorScreenState();
}

class _ArtPieceEditorScreenState extends State<ArtPieceEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _content = TextEditingController();
  final _imageService = ProfileImageService();
  final _recorder = AudioRecorder();
  final _audioPlayer = AudioPlayer();
  String _type = 'text';
  bool _isDraft = true;
  bool _saving = false;
  bool _isRecording = false;
  bool _isPickingMedia = false;
  bool _isAudioPlaying = false;
  String? _contentBase64;
  List<int>? _audioBytes;
  String? _error;
  Timer? _recordingTimer;
  int _recordingSeconds = 0;

  bool get _canSubmit {
    if (_title.text.trim().isEmpty) return false;
    if (_type == 'text') return _textContent().trim().isNotEmpty;
    return _contentBase64 != null;
  }

  @override
  void initState() {
    super.initState();
    final piece = widget.initialPiece;
    if (piece != null) {
      _title.text = piece.title;
      _description.text = piece.description;
      _content.text = piece.type == 'text' ? piece.contentData : '';
      _type = piece.type;
      _isDraft = piece.isDraft;
      _contentBase64 = piece.type == 'text' ? null : piece.contentData;
      if (piece.type == 'audio') {
        try {
          _audioBytes = base64Decode(piece.contentData);
        } on FormatException {
          _audioBytes = null;
        }
      }
    }
    _title.addListener(_refreshSubmitState);
    _content.addListener(_refreshSubmitState);
  }

  void _refreshSubmitState() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _recorder.dispose();
    _audioPlayer.dispose();
    _title.removeListener(_refreshSubmitState);
    _content.removeListener(_refreshSubmitState);
    _title.dispose();
    _description.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _pickPicture({required ImageSource source}) async {
    if (_isPickingMedia || _saving) return;
    setState(() => _isPickingMedia = true);
    try {
      final value = await _imageService.pickAndCompressForArtPiece(source);
      if (mounted && value != null) setState(() => _contentBase64 = value);
    } on FormatException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _isPickingMedia = false);
    }
  }

  Future<void> _pickAudio() async {
    if (_isPickingMedia || _saving) return;
    setState(() => _isPickingMedia = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        withData: true,
      );
      final bytes = result?.files.single.bytes;
      if (bytes != null) _setAudioBytes(bytes);
    } finally {
      if (mounted) setState(() => _isPickingMedia = false);
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      _recordingTimer?.cancel();
      if (path != null) {
        final bytes = await File(path).readAsBytes();
        _setAudioBytes(bytes);
      }
      if (mounted) setState(() => _isRecording = false);
      return;
    }
    if (!await _recorder.hasPermission()) {
      setState(() => _error = AppLocalizations.of(context).microphonePermissionRequired);
      return;
    }
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: 'artex_recording.m4a',
    );
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _recordingSeconds++);
      if (_recordingSeconds >= 120) _toggleRecording();
    });
    setState(() {
      _isRecording = true;
      _recordingSeconds = 0;
      _error = AppLocalizations.of(context).audioSizeGuidance;
    });
  }

  void _setAudioBytes(List<int> bytes) {
    if (bytes.length > 700 * 1024) {
      setState(() => _error = AppLocalizations.of(context).audioTooLarge);
      return;
    }
    setState(() {
      _audioBytes = bytes;
      _contentBase64 = base64Encode(bytes);
      _error = null;
    });
  }

  String _textContent() {
    return _content.text.trim();
  }

  Future<void> _save() async {
    if (_saving || !_canSubmit) return;
    if (!_formKey.currentState!.validate()) return;
    final author = FirebaseAuth.instance.currentUser;
    if (author == null) {
      setState(() => _error = AppLocalizations.of(context).pleaseLogInAgain);
      return;
    }
    if (_type != 'text' && _contentBase64 == null) {
      setState(() => _error = AppLocalizations.of(context).mediaContentRequired);
      return;
    }
    if (_type == 'text' && _textContent().isEmpty) {
      setState(() => _error = AppLocalizations.of(context).textContentRequired);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final user = await FirestoreService().getUser(author.uid);
      final piece = ArtPieceModel(
        id: widget.initialPiece?.id ??
            FirebaseFirestore.instance.collection('art_pieces').doc().id,
        authorId: author.uid,
        authorName: user?.username ?? author.displayName ?? author.email ?? 'Artist',
        authorPicBase64: user?.profilePicBase64,
        title: _title.text.trim(),
        description: _description.text.trim(),
        type: _type,
        contentData: _type == 'text' ? _textContent() : _contentBase64!,
        isDraft: _isDraft,
        readTimeMinutes: _type == 'text' ? _estimateReadTime(_textContent()) : null,
        audioDurationSeconds: _type == 'audio' ? _recordingSeconds : null,
        createdAt: DateTime.now(),
      );
      final service = FirestoreService();
      if (widget.initialPiece == null) {
        await service.createArtPiece(piece);
      } else {
        await service.updateArtPiece(piece);
      }
      if (mounted) Navigator.pop(context, _isDraft);
    } on Object catch (error) {
      if (mounted) setState(() => _error = '${AppLocalizations.of(context).savePieceFailed}: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  int _estimateReadTime(String text) =>
      (text.trim().split(RegExp(r'\s+')).length / 200).ceil().clamp(1, 999);

  Widget _buildImagePreview() {
    try {
      return Container(
        height: 220,
        margin: const EdgeInsets.only(top: 12),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4,
          child: Image.memory(
            base64Decode(_contentBase64!),
            fit: BoxFit.contain,
            width: double.infinity,
            errorBuilder: (_, error, stack) => Center(
              child: Text(AppLocalizations.of(context).invalidBase64),
            ),
          ),
        ),
      );
    } on FormatException {
      return Text(AppLocalizations.of(context).invalidBase64);
    }
  }

  Widget _buildAudioPreview() {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: ListTile(
        leading: IconButton(
          tooltip: _isAudioPlaying ? l10n.pauseAudio : l10n.playAudio,
          icon: Icon(_isAudioPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: () async {
            try {
              if (_isAudioPlaying) {
                await _audioPlayer.pause();
              } else {
                await _audioPlayer.play(
                  BytesSource(Uint8List.fromList(_audioBytes!)),
                );
              }
              if (mounted) {
                setState(() => _isAudioPlaying = !_isAudioPlaying);
              }
            } on Object {
              if (mounted) {
                setState(() => _error = l10n.audioInitFailed);
              }
            }
          },
        ),
        title: Text(l10n.audioReady),
        subtitle: Text(l10n.audioBytes(_audioBytes!.length)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createArtPiece)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(l10n.whatCreating,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'picture', label: Text(l10n.picture)),
                ButtonSegment(value: 'audio', label: Text(l10n.audio)),
                ButtonSegment(value: 'text', label: Text(l10n.text)),
              ],
              selected: {_type},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  setState(() => _type = selection.first),
            ),
            const SizedBox(height: 20),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: false, label: Text(l10n.published)),
                ButtonSegment(value: true, label: Text(l10n.inDevelopment)),
              ],
              selected: {_isDraft},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  setState(() => _isDraft = selection.first),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _title,
              decoration: InputDecoration(labelText: l10n.title),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? l10n.titleRequired : null,
            ),
            TextFormField(
              controller: _description,
              decoration: InputDecoration(labelText: l10n.description),
            ),
            const SizedBox(height: 16),
            _buildTypeContent(),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Colors.red.shade700)),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving || !_canSubmit ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.saveArtPiece),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeContent() {
    switch (_type) {
      case 'picture':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              onPressed: () => _pickPicture(source: ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(AppLocalizations.of(context).chooseFromGallery),
            ),
            OutlinedButton.icon(
              onPressed: () => _pickPicture(source: ImageSource.camera),
              icon: const Icon(Icons.camera_alt_outlined),
              label: Text(AppLocalizations.of(context).takePicture),
            ),
            if (_contentBase64 != null) ...[
              Text(AppLocalizations.of(context).pictureReady),
              _buildImagePreview(),
            ],
          ],
        );
      case 'audio':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              onPressed: _pickAudio,
              icon: const Icon(Icons.audio_file_outlined),
              label: Text(AppLocalizations.of(context).chooseAudioFile),
            ),
            OutlinedButton.icon(
              onPressed: _toggleRecording,
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              label: Text(_isRecording
                  ? AppLocalizations.of(context).stopRecording
                  : AppLocalizations.of(context).recordAudio),
            ),
            Text(AppLocalizations.of(context).audioSizeGuidance),
            if (_audioBytes != null) _buildAudioPreview(),
          ],
        );
      default:
        return Column(
          children: [
            TextFormField(
              controller: _content,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).textContent,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );
    }
  }
}
