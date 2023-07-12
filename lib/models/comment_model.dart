

class Comment {

  final String id;
  final String body;
  final DateTime createdAt;
  final String postId;
  final String username;
  final String profilePic;
  Comment({
    required this.id,
    required this.body,
    required this.createdAt,
    required this.postId,
    required this.username,
    required this.profilePic,
  });

  

  Comment copyWith({
    String? id,
    String? body,
    DateTime? createdAt,
    String? postId,
    String? username,
    String? profilePic,
  }) {
    return Comment(
      id: id ?? this.id,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      postId: postId ?? this.postId,
      username: username ?? this.username,
      profilePic: profilePic ?? this.profilePic,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'body': body,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'postId': postId,
      'username': username,
      'profilePic': profilePic,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] as String,
      body: map['body'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      postId: map['postId'] as String,
      username: map['username'] as String,
      profilePic: map['profilePic'] as String,
    );
  }


  @override
  String toString() {
    return 'Comment(id: $id, body: $body, createdAt: $createdAt, postId: $postId, username: $username, profilePic: $profilePic)';
  }

  @override
  bool operator ==(covariant Comment other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.body == body &&
      other.createdAt == createdAt &&
      other.postId == postId &&
      other.username == username &&
      other.profilePic == profilePic;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      body.hashCode ^
      createdAt.hashCode ^
      postId.hashCode ^
      username.hashCode ^
      profilePic.hashCode;
  }
}
