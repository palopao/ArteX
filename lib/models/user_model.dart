class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.profilePicBase64,
    required this.description,
    required this.language,
    this.friendsList = const [],
    this.friendRequests = const [],
    this.recentlyViewed = const [],
    this.likedPieceIds = const [],
  });

  final String id;
  final String email;
  final String username;
  final String? profilePicBase64;
  final String description;
  final String language;
  final List<String> friendsList;
  final List<String> friendRequests;
  final List<String> recentlyViewed;
  final List<String> likedPieceIds;

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      email: map['email'] as String? ?? '',
      username: map['username'] as String? ?? '',
      profilePicBase64: map['profilePicBase64'] as String?,
      description: map['description'] as String? ?? '',
      language: map['language'] as String? ?? '',
      friendsList: _stringList(map['friendsList']),
      friendRequests: _stringList(map['friendRequests']),
      recentlyViewed: _stringList(map['recentlyViewed']),
      likedPieceIds: _stringList(map['likedPieceIds']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'profilePicBase64': profilePicBase64,
      'description': description,
      'language': language,
      'friendsList': List<String>.from(friendsList),
      'friendRequests': List<String>.from(friendRequests),
      'recentlyViewed': List<String>.from(recentlyViewed),
      'likedPieceIds': List<String>.from(likedPieceIds),
    };
  }

  UserModel copyWith({
    String? email,
    String? username,
    String? profilePicBase64,
    String? description,
    String? language,
    List<String>? friendsList,
    List<String>? friendRequests,
    List<String>? recentlyViewed,
    List<String>? likedPieceIds,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      username: username ?? this.username,
      profilePicBase64: profilePicBase64 ?? this.profilePicBase64,
      description: description ?? this.description,
      language: language ?? this.language,
      friendsList: friendsList ?? this.friendsList,
      friendRequests: friendRequests ?? this.friendRequests,
      recentlyViewed: recentlyViewed ?? this.recentlyViewed,
      likedPieceIds: likedPieceIds ?? this.likedPieceIds,
    );
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) return const [];
    return value.whereType<String>().toList(growable: false);
  }
}
