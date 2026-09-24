import 'dart:async';
import 'dart:convert';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'error_logging_service.dart';
const _maxCacheBytes = 24 * 1024 * 1024;
final LinkedHashMap<String, Uint8List> _decodedImageCache =
    LinkedHashMap<String, Uint8List>();
int _cachedBytes = 0;

Future<Uint8List?> decodeBase64InIsolate(String value) async {
  final key = value.replaceAll(RegExp(r'\s+'), '');
  if (key.isEmpty) return null;
  final cached = _decodedImageCache.remove(key);
  if (cached != null) {
    _decodedImageCache[key] = cached;
    return cached;
  }
  final decoded = await compute(_decodeBase64, key);
  if (decoded == null) {
    await ErrorLoggingService.recordBase64DecodeFailure(
      const FormatException('Invalid Base64 value.'),
      StackTrace.current,
      source: 'media_decode_service',
    );
    return null;
  }
  _decodedImageCache[key] = decoded;
  _cachedBytes += decoded.lengthInBytes;
  _evictCache();
  return decoded;
}

void clearDecodedMediaCache() {
  _decodedImageCache.clear();
  _cachedBytes = 0;
}

Uint8List? _decodeBase64(String value) {
  try {
    return Uint8List.fromList(base64Decode(value));
  } on FormatException {
    return null;
  }
}

void _evictCache() {
  while (_cachedBytes > _maxCacheBytes && _decodedImageCache.isNotEmpty) {
    final firstKey = _decodedImageCache.keys.first;
    final removed = _decodedImageCache.remove(firstKey);
    if (removed != null) _cachedBytes -= removed.lengthInBytes;
  }
}
