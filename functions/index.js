const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Khởi tạo Firebase Admin SDK để có quyền chọc vào Database và gửi FCM
admin.initializeApp();

/**
 * Hàm này lắng nghe sự kiện: 
 * Mỗi khi có 1 Document mới được tạo (onCreate) bên trong collection "messages"
 * (Giả sử cấu trúc lưu tin nhắn của bạn là: chat_rooms/{roomId}/messages/{messageId})
 */
exports.sendNotificationOnNewMessage = functions.firestore
    // Sửa lại đường dẫn này cho ĐÚNG VỚI CẤU TRÚC FIRESTORE THỰC TẾ của bạn
    // Ví dụ nếu bạn lưu thẳng tin nhắn ở gốc: .document("messages/{messageId}")
    .document("chat_rooms/{roomId}/messages/{messageId}")
    .onCreate(async (snap, context) => {
        try {
            // 1. Lấy dữ liệu tin nhắn vừa được gửi lên
            const messageData = snap.data();

            const senderId = messageData.senderId;
            const receiverId = messageData.receiverId;
            const content = messageData.content; // text nội dung
            const roomId = context.params.roomId; // lấy ID phòng chat từ URL trên

            // Nếu không có ID người nhận, thì không biết gửi cho ai -> Thoát
            if (!receiverId) {
                console.log("Không tìm thấy receiverId trong tin nhắn mới.");
                return null;
            }

            // 2. Tra cứu xem người gửi (sender) tên là gì (để hiện: "Hieu đã nhắn tin...")
            const senderDoc = await admin.firestore().collection("users").doc(senderId).get();
            const senderName = senderDoc.exists ? senderDoc.data().name : "Ai đó";

            // 3. Tra cứu cục FCM Token của người nhận (receiver)
            const receiverDoc = await admin.firestore().collection("users").doc(receiverId).get();
            if (!receiverDoc.exists) {
                console.log("Không tìm thấy thông tin user nhận trong collection users.");
                return null; // Người nhận ko tồn tại
            }

            const fcmToken = receiverDoc.data().fcmToken;

            if (!fcmToken) {
                console.log(`User ${receiverId} chưa cấp FCM Token. (Có thể họ chưa đăng nhập hoặc tắt thông báo)`);
                return null; // Không có token báo lỗi
            }

            // 4. Tạo "Bưu kiện" đóng gói Thông báo để gửi đi
            const payload = {
                notification: {
                    title: `${senderName} đã gửi tin nhắn`,
                    body: content,
                    // (Tuỳ chọn) icon, sound: "default"...
                },
                data: {
                    // Gửi data ngầm này về con điện thoại, 
                    // để lúc bấm vô thông báo, cái hàm của Flutter biết mà nhảy thẳng vô màn hình phòng chat!
                    type: "chat",
                    roomId: roomId,
                    senderId: senderId,
                }
            };

            // 5. Ra lệnh cho Google đem giao thông báo này
            const response = await admin.messaging().sendToDevice(fcmToken, payload);
            console.log("Đã gửi thông báo thành công! Response:", response);

            return null;

        } catch (error) {
            console.error("Phát sinh lỗi khi rình gửi thông báo:", error);
            return null;
        }
    });

