import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  const CommentModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.text,
    this.createdAt,
  });

  final String id;
  final String authorId;
  final String authorName;
  final String text;
  final DateTime? createdAt;

  factory CommentModel.fromMap(String id, Map<String, dynamic> map) {
    final value = map['createdAt'];
    return CommentModel(
      id: id,
      authorId: map['authorId'] as String? ?? '',
      authorName: map['authorName'] as String? ?? '',
      text: map['text'] as String? ?? '',
      createdAt: value is Timestamp
          ? value.toDate()
          : value is DateTime
              ? value
              : null,
    );
  }
}
