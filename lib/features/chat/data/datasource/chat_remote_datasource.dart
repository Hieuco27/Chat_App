import 'package:cloud_firestore/cloud_firestore.dart';

/// Remote Data Source cho Chat — giao tiếp trực tiếp với Firestore
/// Xử lý: rooms, messages, users (dữ liệu bền vững)
class ChatRemoteDatasource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ========================
  // ROOM
  // ========================

  /// Tạo phòng chat mới
  Future<DocumentReference> createRoom(List<String> participants) async {
    return await _db.collection('rooms').add({
      'participants': participants,
      'lastMessageContent': '',
      'lastMessageSenderId': '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'userProfiles': {},
    });
  }

  /// Lấy danh sách phòng chat của user
  Stream<QuerySnapshot> getRooms(String userId) {
    return _db
        .collection('rooms')
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  // ========================
  // MESSAGE
  // ========================

  /// Lấy tin nhắn trong phòng chat
  Stream<QuerySnapshot> getMessages(String roomId) {
    return _db
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('createAt', descending: false)
        .snapshots();
  }

  /// Gửi tin nhắn + cập nhật room
  Future<void> sendMessage(
    String roomId,
    String senderId,
    String content,
  ) async {
    await _db.collection('rooms').doc(roomId).collection('messages').add({
      'senderId': senderId,
      'content': content,
      'roomId': roomId,
      'isRead': false,
      'createAt': FieldValue.serverTimestamp(),
    });

    // Cập nhật thời gian cập nhật phòng chat
    await _db.collection('rooms').doc(roomId).update({
      'updatedAt': FieldValue.serverTimestamp(),
      'lastMessageContent': content,
      'lastMessageSenderId': senderId,
    });
  }

  // ========================
  // USER
  // ========================

  /// Lấy thông tin user
  Future<DocumentSnapshot> getUser(String userId) {
    return _db.collection('users').doc(userId).get();
  }

  /// Tìm kiếm user
  Future<QuerySnapshot> searchUsers(String query) async {
    return await _db
        .collection('users')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
  }
}
