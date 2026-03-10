class ChatUserEntity {
  final String uid;
  final String displayName;
  final String photoUrl;
  final String email;
  final bool isOnline;
  final DateTime createAt;
  final DateTime lastSeen;

  ChatUserEntity({
    required this.uid,
    required this.displayName,
    required this.photoUrl,
    required this.email,
    required this.isOnline,
    required this.createAt,
    required this.lastSeen,
  });
}
