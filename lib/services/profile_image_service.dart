import 'dart:convert';

import 'package:image/image.dart' as image;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class ProfileImageService {
  ProfileImageService({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  static const maxBytes = 200 * 1024;
  final ImagePicker _picker;

  Future<String?> pickAndCompress(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return null;

    final originalBytes = await pickedFile.readAsBytes();
    return compute(_compressProfileImage, originalBytes);
  }

  Future<String?> pickAndCompressForArtPiece(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return null;

    final originalBytes = await pickedFile.readAsBytes();
    return compute(_compressArtPieceImage, originalBytes);
  }
}

String _compressProfileImage(Uint8List originalBytes) {
  final decoded = image.decodeImage(originalBytes);
  if (decoded == null) {
    throw const FormatException('The selected file is not a supported image.');
  }
  var current = decoded;
  var quality = 85;
  for (var attempt = 0; attempt < 8; attempt++) {
    final encoded = Uint8List.fromList(
      image.encodeJpg(current, quality: quality),
    );
    if (encoded.lengthInBytes <= ProfileImageService.maxBytes) {
      return base64Encode(encoded);
    }
    if (quality > 35) {
      quality -= 10;
    } else {
      final nextWidth = (current.width * 0.8).round();
      final nextHeight = (current.height * 0.8).round();
      if (nextWidth < 120 || nextHeight < 120) break;
      current = image.copyResize(current, width: nextWidth, height: nextHeight);
      quality = 75;
    }
  }
  throw const FormatException(
    'The image could not be compressed below 200 KB. Please choose a smaller image.',
  );
}

String _compressArtPieceImage(Uint8List originalBytes) {
  final decoded = image.decodeImage(originalBytes);
  if (decoded == null) {
    throw const FormatException('The selected file is not a supported image.');
  }
  final scale = decoded.width > 800 || decoded.height > 800
      ? 800 / (decoded.width > decoded.height ? decoded.width : decoded.height)
      : 1.0;
  final resized = scale < 1
      ? image.copyResize(
          decoded,
          width: (decoded.width * scale).round(),
          height: (decoded.height * scale).round(),
        )
      : decoded;
  return base64Encode(image.encodeJpg(resized, quality: 70));
}
