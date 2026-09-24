import 'package:cloud_firestore/cloud_firestore.dart';

class ArtPieceModel {
  const ArtPieceModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorPicBase64,
    required this.title,
    required this.description,
    required this.type,
    required this.contentData,
    this.likesCount = 0,
    this.watchCount = 0,
    this.viewsCount = 0,
    required this.isDraft,
    this.readTimeMinutes,
    this.audioDurationSeconds,
    required this.createdAt,
  }) : assert(type == 'picture' || type == 'audio' || type == 'text');

  final String id;
  final String authorId;
  final String authorName;
  final String? authorPicBase64;
  final String title;
  final String description;
  final String type;
  final String contentData;
  final int likesCount;
  final int watchCount;
  final int viewsCount;
  final bool isDraft;
  final int? readTimeMinutes;
  final int? audioDurationSeconds;
  final DateTime createdAt;

  factory ArtPieceModel.fromMap(String id, Map<String, dynamic> map) {
    final createdAt = map['createdAt'];
    return ArtPieceModel(
      id: id,
      authorId: map['authorId'] as String? ?? '',
      authorName: map['authorName'] as String? ?? '',
      authorPicBase64: map['authorPicBase64'] as String?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      type: map['type'] as String? ?? 'text',
      contentData: map['contentData'] as String? ?? '',
      likesCount: (map['likesCount'] as num?)?.toInt() ?? 0,
      watchCount: (map['watchCount'] as num?)?.toInt() ?? 0,
      viewsCount: (map['viewsCount'] as num?)?.toInt() ?? 0,
      isDraft: map['isDraft'] as bool? ?? false,
      readTimeMinutes: (map['readTimeMinutes'] as num?)?.toInt(),
      audioDurationSeconds: (map['audioDurationSeconds'] as num?)?.toInt(),
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : createdAt is DateTime
              ? createdAt
              : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'title': title,
      'description': description,
      'type': type,
      'contentData': contentData,
      'likesCount': likesCount,
      'watchCount': watchCount,
      'viewsCount': viewsCount,
      'isDraft': isDraft,
      'readTimeMinutes': readTimeMinutes,
      'audioDurationSeconds': audioDurationSeconds,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
