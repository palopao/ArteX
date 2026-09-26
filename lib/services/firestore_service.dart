import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/art_piece_model.dart';
import '../models/user_model.dart';
import 'error_logging_service.dart';

class Base64Utils {
  const Base64Utils._();

  static String fromBytes(Uint8List bytes) => base64Encode(bytes);

  static Uint8List toBytes(String value) {
    try {
      return Uint8List.fromList(base64Decode(normalize(value)));
    } on FormatException catch (error, stack) {
      unawaited(ErrorLoggingService.recordBase64DecodeFailure(
        error,
        stack,
        source: 'firestore_service',
      ));
      rethrow;
    }
  }

  static String normalize(String value) {
    final normalized = value.replaceAll(RegExp(r'\s+'), '');
    if (normalized.isEmpty) {
      throw const FormatException('Base64 value cannot be empty.');
    }
    try {
      base64Decode(normalized);
    } on FormatException catch (error, stack) {
      unawaited(ErrorLoggingService.recordBase64DecodeFailure(
        error,
        stack,
        source: 'firestore_service',
      ));
      throw const FormatException('Invalid Base64 value.');
    }
    return normalized;
  }

  static String? serializeNullable(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return normalize(value);
  }
}

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const usersCollection = 'users';
  static const artPiecesCollection = 'art_pieces';

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(usersCollection);
  CollectionReference<Map<String, dynamic>> get _artPieces =>
      _firestore.collection(artPiecesCollection);

  Future<UserModel?> getUser(String id) async {
    final snapshot = await _users.doc(id).get();
    return snapshot.exists && snapshot.data() != null
        ? UserModel.fromMap(snapshot.id, snapshot.data()!)
        : null;
  }

  Future<void> createUser(UserModel user) async {
    final data = _userData(user);
    await _setChecked(_users.doc(user.id), data, usersCollection, user.id);
  }

  Future<bool> userExists(String id) async {
    final snapshot = await _users.doc(id).get();
    return snapshot.exists;
  }

  Future<void> updateUser(UserModel user) async {
    final data = _userData(user);
    await _updateChecked(_users.doc(user.id), data, usersCollection, user.id);
  }

  Future<void> sendFriendRequest({
    required String targetUserId,
    required String requesterUserId,
  }) async {
    if (targetUserId == requesterUserId) {
      throw StateError('You cannot send a friend request to yourself.');
    }
    await _users.doc(targetUserId).update({
      'friendRequests': FieldValue.arrayUnion([requesterUserId]),
    });
  }

  Future<void> acceptFriendRequest({
      required String currentUserId,
      required String senderUserId,
    }) async {
      final batch = _firestore.batch();
      batch.update(_users.doc(currentUserId), {
        'friendsList': FieldValue.arrayUnion([senderUserId]),
        'friendRequests': FieldValue.arrayRemove([senderUserId]),
      });
      batch.update(_users.doc(senderUserId), {
        'friendsList': FieldValue.arrayUnion([currentUserId]),
      });
      await batch.commit();
    }

  Future<void> rejectFriendRequest({
      required String currentUserId,
      required String senderUserId,
    }) {
      return _users.doc(currentUserId).update({
        'friendRequests': FieldValue.arrayRemove([senderUserId]),
      });
  }

  Future<void> removeFriend({
    required String currentUserId,
    required String friendId,
  }) async {
    final batch = _firestore.batch();
    batch.update(_users.doc(currentUserId), {
      'friendsList': FieldValue.arrayRemove([friendId]),
    });
    batch.update(_users.doc(friendId), {
      'friendsList': FieldValue.arrayRemove([currentUserId]),
    });
    await batch.commit();
  }

  static String chatIdFor(String firstUserId, String secondUserId) {
    final ids = [firstUserId, secondUserId]..sort();
    return ids.join('_');
  }

  CollectionReference<Map<String, dynamic>> _messages(String chatId) =>
      _firestore.collection('chats').doc(chatId).collection('messages');

  Stream<QuerySnapshot<Map<String, dynamic>>> watchChatMessages({
    required String currentUserId,
    required String recipientId,
  }) {
    final chatId = chatIdFor(currentUserId, recipientId);
    return _messages(chatId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> sendChatMessage({
    required String currentUserId,
    required String recipientId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final chatId = chatIdFor(currentUserId, recipientId);
    final chat = _firestore.collection('chats').doc(chatId);
    await chat.set({
      'participants': [currentUserId, recipientId]..sort(),
    }, SetOptions(merge: true));
    await _messages(chatId).add({
      'senderId': currentUserId,
      'text': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  Future<List<UserModel>> getUsersByIds(Iterable<String> ids) async {
    final uniqueIds = ids.toSet().toList(growable: false);
    if (uniqueIds.isEmpty) return const [];
    final users = await Future.wait(uniqueIds.map(getUser));
    return users.whereType<UserModel>().toList(growable: false);
  }

  Future<void> deleteUser(String id) => _users.doc(id).delete();

  Stream<UserModel?> watchUser(String id) {
    return _users.doc(id).snapshots().map(
          (snapshot) => snapshot.exists && snapshot.data() != null
              ? UserModel.fromMap(snapshot.id, snapshot.data()!)
              : null,
        );
  }

  Stream<List<UserModel>> watchUsers() {
    return _users.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.id, doc.data()))
              .toList(growable: false),
        );
  }

  Future<ArtPieceModel?> getArtPiece(String id) async {
    final snapshot = await _artPieces.doc(id).get();
    return snapshot.exists && snapshot.data() != null
        ? ArtPieceModel.fromMap(snapshot.id, snapshot.data()!)
        : null;
  }

  Future<void> recordArtPieceView({
    required String userId,
    required String pieceId,
  }) {
    return _users.doc(userId).update({
      'recentlyViewed': FieldValue.arrayUnion([pieceId]),
    });
  }

  Future<bool> recordUniqueArtPieceView({
    required String pieceId,
    required String userId,
  }) async {
    final pieceRef = _artPieces.doc(pieceId);
    final viewRef = pieceRef.collection('views').doc(userId);
    final pieceSnapshot = await pieceRef.get();
    if (!pieceSnapshot.exists ||
        pieceSnapshot.data()?['authorId'] == userId) {
      return false;
    }
    final viewSnapshot = await viewRef.get();
    if (viewSnapshot.exists) return false;

    final batch = _firestore.batch();
    batch.set(viewRef, {
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    batch.update(pieceRef, {
      'viewsCount': FieldValue.increment(1),
    });
    await batch.commit();
    return true;
  }

  Stream<List<ArtPieceModel>> watchRecentlyViewedPieces(String userId) async* {
    await for (final snapshot in _users.doc(userId).snapshots()) {
      final ids = (snapshot.data()?['recentlyViewed'] as List?)
              ?.whereType<String>()
              .toList()
              .reversed
              .take(20)
              .toList() ??
          const <String>[];
      final pieces = await Future.wait(
        ids.map(getArtPiece),
      );
      yield pieces.whereType<ArtPieceModel>().toList(growable: false);
    }
  }

  Future<void> incrementArtPieceViews(String pieceId) {
      return _artPieces.doc(pieceId).update({
        'viewsCount': FieldValue.increment(1),
      });
    }

  Future<bool> toggleArtPieceLike({
      required String artPieceId,
      required String userId,
    }) async {
      final pieceRef = _artPieces.doc(artPieceId);
      final likeRef = pieceRef.collection('likes').doc(userId);
      final userRef = _users.doc(userId);
      return _firestore.runTransaction((transaction) async {
        final pieceSnapshot = await transaction.get(pieceRef);
        final likeSnapshot = await transaction.get(likeRef);
        final userSnapshot = await transaction.get(userRef);
        if (pieceSnapshot.data()?['authorId'] == userId) {
          throw StateError('Users cannot like their own art pieces.');
        }
        final isLiked = likeSnapshot.exists;
        transaction.update(pieceRef, {
          'likesCount': FieldValue.increment(isLiked ? -1 : 1),
        });
        if (isLiked) {
          transaction.delete(likeRef);
        } else {
          transaction.set(likeRef, {
            'userId': userId,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        if (userSnapshot.exists) {
          transaction.update(userRef, {
            'likedPieceIds': isLiked
                ? FieldValue.arrayRemove([artPieceId])
                : FieldValue.arrayUnion([artPieceId]),
          });
        }
        return !isLiked;
      });
    }

  Future<bool> isArtPieceLiked({
      required String artPieceId,
      required String userId,
    }) async {
      final snapshot =
          await _artPieces.doc(artPieceId).collection('likes').doc(userId).get();
      return snapshot.exists;
    }
  Future<void> createArtPiece(ArtPieceModel artPiece) async {
    final data = _artPieceData(artPiece);
    await _setChecked(
      _artPieces.doc(artPiece.id),
      data,
      artPiecesCollection,
      artPiece.id,
    );
  }

  Future<void> updateArtPiece(ArtPieceModel artPiece) async {
    final data = _artPieceData(artPiece);
    await _updateChecked(
      _artPieces.doc(artPiece.id),
      data,
      artPiecesCollection,
      artPiece.id,
    );
  }

  Future<void> publishArtPiece(String pieceId) {
    return _artPieces.doc(pieceId).update({
      'isDraft': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> incrementArtPieceLikes(
    String artPieceId, {
    required String requesterId,
  }) async {
    final piece = await getArtPiece(artPieceId);
    if (piece == null) throw StateError('Art piece not found.');
    if (piece.authorId == requesterId) {
      throw StateError('Users cannot like their own art pieces.');
    }
    await toggleArtPieceLike(artPieceId: artPieceId, userId: requesterId);
  }

  Stream<List<ArtPieceModel>> watchLikedPieces(String userId) async* {
    await for (final snapshot in _users.doc(userId).snapshots()) {
      final ids = (snapshot.data()?['likedPieceIds'] as List?)
              ?.whereType<String>()
              .toList() ??
          const <String>[];
      final pieces = await Future.wait(ids.map(getArtPiece));
      yield pieces.whereType<ArtPieceModel>().toList(growable: false);
    }
  }

  Stream<List<Map<String, dynamic>>> watchComments(String artPieceId) {
    return _artPieces
        .doc(artPieceId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((document) => {'id': document.id, ...document.data()})
            .toList(growable: false));
  }

  Future<void> addComment({
    required String artPieceId,
    required String authorId,
    required String authorName,
    required String text,
  }) {
    return _artPieces.doc(artPieceId).collection('comments').add({
      'authorId': authorId,
      'authorName': authorName,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _setChecked(
    DocumentReference<Map<String, dynamic>> reference,
    Map<String, dynamic> data,
    String collection,
    String documentId,
  ) async {
    await _checkDocumentSize(data, collection, documentId);
    await reference.set(data);
  }

  Future<void> _updateChecked(
    DocumentReference<Map<String, dynamic>> reference,
    Map<String, dynamic> data,
    String collection,
    String documentId,
  ) async {
    await _checkDocumentSize(data, collection, documentId);
    await reference.update(data);
  }

  Future<void> _checkDocumentSize(
    Map<String, dynamic> data,
    String collection,
    String documentId,
  ) async {
    const maxBytes = 1024 * 1024;
    final byteSize = firestoreDocumentByteSize(data);
    if (byteSize <= maxBytes) return;
    await ErrorLoggingService.recordFirestoreSizeExceeded(
      StackTrace.current,
      collection: collection,
      documentId: documentId,
      byteSize: byteSize,
    );
    throw StateError('Firestore document exceeds the 1 MB limit.');
  }

  Future<void> deleteArtPiece(String id) async {
    try {
      await _firestore.collection(artPiecesCollection).doc(id).delete();
    } on FirebaseException catch (error, stack) {
      unawaited(
        ErrorLoggingService.record(
          error,
          stack,
          reason: 'Art piece deletion failed',
          information: {
            'operation': 'deleteArtPiece',
            'collection': artPiecesCollection,
            'documentId': id,
            'firebaseCode': error.code,
          },
        ),
      );
      rethrow;
    }
  }

  Stream<List<ArtPieceModel>> watchArtPieces({bool includeDrafts = false}) {
    return _artPieces.orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => ArtPieceModel.fromMap(doc.id, doc.data()))
              .where((piece) => includeDrafts || !piece.isDraft)
              .toList(growable: false),
        );
  }

  Stream<List<ArtPieceModel>> watchPublishedArtPieces() {
    return _artPieces
        .where('isDraft', isEqualTo: false)
        .snapshots()
        .map(
          (snapshot) {
            final pieces = snapshot.docs
                .map((doc) => ArtPieceModel.fromMap(doc.id, doc.data()))
                .toList();
            pieces.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return pieces;
          },
        );
  }

  Stream<List<ArtPieceModel>> watchTopLikedPieces() {
    return watchArtPieces().map(
          (pieces) => [...pieces]
            ..sort((a, b) => b.likesCount.compareTo(a.likesCount)),
        );
  }

  Stream<List<ArtPieceModel>> watchTopLikedPiecesAfter(int count) {
    return watchTopLikedPieces()
        .map((pieces) => pieces.skip(count).toList(growable: false));
  }

  Stream<List<ArtPieceModel>> watchUserArtPieces({
    required String authorId,
    required bool draftsOnly,
  }) async* {
    try {
      await for (final snapshot in _artPieces
        .where('authorId', isEqualTo: authorId)
        .where('isDraft', isEqualTo: draftsOnly)
        .orderBy('createdAt', descending: true)
        .snapshots()) {
        yield _artPiecesFromSnapshot(snapshot);
      }
    } on FirebaseException catch (error) {
      if (error.code != 'failed-precondition') rethrow;

      // A composite index may be missing or still building. The author-only
      // query avoids that index; draft filtering and ordering happen locally.
      await for (final snapshot in _artPieces
          .where('authorId', isEqualTo: authorId)
          .snapshots()) {
        final pieces = _artPiecesFromSnapshot(snapshot)
          ..removeWhere((piece) => piece.isDraft != draftsOnly)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        yield pieces;
      }
    }
  }

  List<ArtPieceModel> _artPiecesFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs
        .map((doc) => ArtPieceModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  Stream<ArtPieceModel?> watchArtPiece(String id) {
    return _artPieces.doc(id).snapshots().map(
          (snapshot) => snapshot.exists && snapshot.data() != null
              ? ArtPieceModel.fromMap(snapshot.id, snapshot.data()!)
              : null,
        );
  }

  Map<String, dynamic> _userData(UserModel user) {
    return {
      ...user.toMap(),
      'profilePicBase64':
          Base64Utils.serializeNullable(user.profilePicBase64),
    };
  }

  Map<String, dynamic> _artPieceData(ArtPieceModel artPiece) {
    final data = artPiece.toMap();
    if (artPiece.type != 'text') {
      data['contentData'] = Base64Utils.normalize(artPiece.contentData);
    }
    return data;
  }
  Future<void> saveSuggestion({required String text, String? userId}) {
    final data = <String, dynamic>{
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (userId != null) {
      data['userId'] = userId;
    }
    return _firestore.collection('suggestions').add(data);
  }
}
