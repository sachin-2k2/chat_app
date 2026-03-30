import 'package:cloud_firestore/cloud_firestore.dart';
class MessageModels {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String message;
  final String imageUrl;
  final DateTime timestamp;
  final bool isRead;
  final String? replyMessage;
  final String? replyMessageId;
  final String? replySenderId;

  MessageModels({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.imageUrl,
    required this.timestamp,
    required this.isRead,
     this.replyMessage,
     this.replyMessageId,
     this.replySenderId,

  });

  //convert firestore data to message model
  factory MessageModels.fromMap(Map<String, dynamic> map) {
    return MessageModels(
      messageId: map['messageId'],
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      message: map['message'],
      imageUrl: map['imageUrl'],
      timestamp: map['timestamp'].toDate(),
      isRead: map['isRead']??false,
      replyMessage: map['replyMessage'],
      replyMessageId: map['replyMessageId'],
      replySenderId: map['replySenderId'],
    );
  }
  // Convert MessageModel to Firestore data
  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
      'isRead': isRead,
      'replyMessage':replyMessage,
      'replyMessageId':replyMessageId,
      'replySenderId':replySenderId,
    };
  }
}
