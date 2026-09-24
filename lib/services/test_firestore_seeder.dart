// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/art_piece_model.dart';
import 'firestore_service.dart';

const _testAudioAssets = [
  'resources_test/audios/audio1.mp3',
  'resources_test/audios/audio2.flac',
  'resources_test/audios/audio3.m4a',
];

const _testImageAssets = [
  'resources_test/images/image1.png',
  'resources_test/images/image2.jpg',
  'resources_test/images/image3.svg',
  'resources_test/images/image4.webp',
  'resources_test/images/image5.jxl',
  'resources_test/images/image6.heif',
  'resources_test/images/image7.heic',
  'resources_test/images/image8.avif',
  'resources_test/images/image9.bmp',
  'resources_test/images/image10.gif',
  'resources_test/images/image11.ico',
  'resources_test/images/image12.tif',
];

const _testTextAsset = 'resources_test/texts/text.txt';
const _testAuthorId = 'test-seed-author';
const _testAuthorName = 'Artex Test Artist';

/// Loads the files in resources_test/ and seeds them into art_pieces.
///
/// Audio and image bytes are stored as Base64 because Firestore is the only
/// media store. Text remains raw text, matching ArtPieceModel's contract.
Future<void> seedTestFirestoreData({
  FirestoreService? firestoreService,
  AssetBundle? assetBundle,
}) async {
  final service = firestoreService ?? FirestoreService();
  final bundle = assetBundle ?? rootBundle;
  final createdAt = DateTime.now();

  for (final assetPath in _testAudioAssets) {
    final bytes = await _loadAsset(bundle, assetPath);
    final contentData = base64Encode(bytes);
    _logSeedSize(assetPath, bytes.length, contentData);
    await service.createArtPiece(
      _createPiece(
        id: _seedId(assetPath),
        title: _titleFor(assetPath),
        type: 'audio',
        contentData: contentData,
        createdAt: createdAt,
      ),
    );
  }

  for (final assetPath in _testImageAssets) {
    final bytes = await _loadAsset(bundle, assetPath);
    final contentData = base64Encode(bytes);
    _logSeedSize(assetPath, bytes.length, contentData);
    await service.createArtPiece(
      _createPiece(
        id: _seedId(assetPath),
        title: _titleFor(assetPath),
        type: 'picture',
        contentData: contentData,
        createdAt: createdAt,
      ),
    );
  }

  final textBytes = await _loadAsset(bundle, _testTextAsset);
  final text = utf8.decode(textBytes);
  print(
    '[test-seed] $_testTextAsset: '
    '${textBytes.length} source bytes, ${utf8.encode(text).length} stored text bytes',
  );
  await service.createArtPiece(
    _createPiece(
      id: _seedId(_testTextAsset),
      title: _titleFor(_testTextAsset),
      type: 'text',
      contentData: text,
      createdAt: createdAt,
    ),
  );
}

Future<Uint8List> _loadAsset(AssetBundle bundle, String assetPath) async {
  final data = await bundle.load(assetPath);
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}

void _logSeedSize(String assetPath, int sourceBytes, String base64Value) {
  final base64Bytes = utf8.encode(base64Value).length;
  print(
    '[test-seed] $assetPath: '
    '$sourceBytes source bytes, $base64Bytes Base64 bytes',
  );
  if (base64Bytes >= 900 * 1024) {
    print('[test-seed] WARNING: Base64 value is approaching Firestore 1 MB limit.');
  }
}

ArtPieceModel _createPiece({
  required String id,
  required String title,
  required String type,
  required String contentData,
  required DateTime createdAt,
}) {
  return ArtPieceModel(
    id: id,
    authorId: _testAuthorId,
    authorName: _testAuthorName,
    authorPicBase64: null,
    title: title,
    description: 'Seeded local test asset: $title',
    type: type,
    contentData: contentData,
    likesCount: 0,
    watchCount: 0,
    isDraft: false,
    createdAt: createdAt,
  );
}

String _seedId(String assetPath) {
  return 'test-seed-${assetPath.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '-')}';
}

String _titleFor(String assetPath) {
  final fileName = assetPath.split('/').last;
  return 'Test ${fileName.split('.').first}';
}
