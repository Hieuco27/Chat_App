import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRemoteDatasource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Tạo phòng chat mới và lưu thông tin profile người dùng để hiển thị nhanh
  Future<DocumentReference> createRoom(List<String> participants) async {
    Map<String, dynamic> userProfiles = {};

    // Lấy thông tin của từng người tham gia để lưu vào phòng
    for (String uid in participants) {
      final userDoc = await _db.collection('users').doc(uid).get();
      if (userDoc.exists) {
        userProfiles[uid] = userDoc.data();
      }
    }

    return await _db.collection('rooms').add({
      'participants': participants,
      'lastMessageContent': '',
      'lastMessageSenderId': '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'userProfiles': userProfiles,
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
    String type,
    String status,
  ) async {
    await _db.collection('rooms').doc(roomId).collection('messages').add({
      'senderId': senderId,
      'content': content,
      'roomId': roomId,
      'isRead': false,
      'type': type,
      'status': status,
      'createAt': FieldValue.serverTimestamp(),
    });

    // Cập nhật thời gian cập nhật phòng chat
    await _db.collection('rooms').doc(roomId).update({
      'updatedAt': FieldValue.serverTimestamp(),
      'lastMessageContent': type == 'text' ? content : '[Media]',
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

  // Tìm kiếm user
  Future<QuerySnapshot> searchUsers(String query) async {
    return await _db
        .collection('users')
        .where('displayName', isGreaterThanOrEqualTo: query)
        .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
  }

  // ========================
  // FILE STORAGE
  // ========================

  /// Upload file to Firebase Storage
  Future<String> uploadFile(File file, String folder) async {
    try {
      final fileName =
          "${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}";
      final ref = FirebaseStorage.instance.ref().child('$folder/$fileName');
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception("Lỗi khi tải file lên Storage: $e");
    }
  }
}
