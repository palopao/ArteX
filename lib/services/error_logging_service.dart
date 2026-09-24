import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ErrorLoggingService {
  const ErrorLoggingService._();

  static Future<void> record(
    Object error,
    StackTrace stack, {
    String? reason,
    bool fatal = false,
    Map<String, Object>? information,
  }) async {
    if (kIsWeb) return;

    final crashlytics = FirebaseCrashlytics.instance;
    if (information != null) {
      for (final entry in information.entries) {
        await crashlytics.setCustomKey(entry.key, entry.value);
      }
    }
    await crashlytics.recordError(
      error,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }

  static Future<void> recordBase64DecodeFailure(
    Object error,
    StackTrace stack, {
    required String source,
  }) {
    return record(
      error,
      stack,
      reason: 'Base64 decode failed',
      information: {'source': source},
    );
  }

  static Future<void> recordUnsupportedAudio(
    StackTrace stack, {
    required String source,
  }) {
    return record(
      StateError('Unsupported audio format'),
      stack,
      reason: 'Unsupported audio format',
      information: {'source': source},
    );
  }

  static Future<void> recordFirestoreSizeExceeded(
    StackTrace stack, {
    required String collection,
    required String documentId,
    required int byteSize,
  }) {
    return record(
      StateError('Firestore document exceeds the 1 MB limit'),
      stack,
      reason: 'Firestore document exceeds the 1 MB limit',
      information: {
        'collection': collection,
        'documentId': documentId,
        'byteSize': byteSize,
      },
    );
  }
}

class ArtexErrorScreen extends StatelessWidget {
  const ArtexErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 56),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Please try again. Your data is still safe.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

int firestoreDocumentByteSize(Map<String, dynamic> data) {
  return utf8.encode(jsonEncode(_jsonSafeValue(data))).length;
}

Object? _jsonSafeValue(Object? value) {
  if (value is Timestamp) return value.toDate().toIso8601String();
  if (value is DateTime) return value.toIso8601String();
  if (value is Map) {
    return value.map(
      (key, entry) => MapEntry(key.toString(), _jsonSafeValue(entry)),
    );
  }
  if (value is Iterable) {
    return value.map(_jsonSafeValue).toList(growable: false);
  }
  return value;
}
