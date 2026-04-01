import 'package:chat_app/models/message_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firebaseStore = FirebaseFirestore.instance;

  //generate uniq chatroom id for two users
  String getChatRoomId(String userId1, String userId2) {
    List<String> Ids = [userId1, userId2];
    Ids.sort();
    return Ids.join('_');
  }

  //Send Message
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String message,
    String? replyMessage,
    String? replyMessageId,
    String? replySenderId,
  }) async {
    try {
      final chatRoomId = getChatRoomId(senderId, receiverId);
      final messageId = DateTime.now().microsecondsSinceEpoch.toString();

      MessageModels newMessage = MessageModels(
        messageId: messageId,
        senderId: senderId,
        receiverId: receiverId,
        message: message,
        imageUrl: '',
        timestamp: DateTime.now(),
        isRead: false,
        replyMessage: replyMessage,
        replyMessageId: replyMessageId,
        replySenderId: replySenderId,
      );

      //Save Message to Firestore
      await _firebaseStore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .set(newMessage.toMap());

      //Update last message in chat room
      await _firebaseStore.collection('chats').doc(chatRoomId).set({
        'lastMessage': message,
        'lastMessageTime': DateTime.now(),
        'members': [senderId, receiverId],
      });
    } catch (e) {
      print('Send Message Error:$e');
    }
  }

  //Get Message stream (real time)
  Stream<List<MessageModels>> getMessages(String userId1, String userId2) {
    final chatRoomId = getChatRoomId(userId1, userId2);
    return _firebaseStore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return MessageModels.fromMap(doc.data());
          }).toList();
        });
  }

  //Get all chats for a user
  Stream<QuerySnapshot> getUserChats(String userId) {
    return _firebaseStore
        .collection('chats')
        .where('members', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  //Get All Users Except Current User
  Stream<QuerySnapshot> getAllUsers(String currentUserId) {
    return _firebaseStore.collection('user').snapshots();
  }

  //Image sending
  Future<void> sendImageMessage({
    required String senderId,
    required String receiverId,
    required String imageUrl,
  }) async {
    try {
      final chatRoomId = getChatRoomId(senderId, receiverId);
      final messageId = DateTime.now().millisecondsSinceEpoch.toString();

      MessageModels newMessage = MessageModels(
        messageId: messageId,
        senderId: senderId,
        receiverId: receiverId,
        message: '',
        imageUrl: imageUrl,
        timestamp: DateTime.now(),
        isRead: false,
      );
      await _firebaseStore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .set(newMessage.toMap());

      await _firebaseStore.collection('chats').doc(chatRoomId).set({
        'lastMessage': '📷 Photo',
        'lastMessageTime': DateTime.now(),
        'members': [senderId, receiverId],
      });
    } catch (e) {
      print('Sender image error:$e');
    }
  }

  //Update Typing Status
  Future<void> updateTypingStatus({
    required String chatRoomId,
    required String userId,
    required bool isTyping,
  }) async {
    await _firebaseStore.collection('chats').doc(chatRoomId).set({
      'typing_$userId': isTyping,
    }, SetOptions(merge: true));
  }

  //Get Typing Status stream
  Stream<bool> getTypingStatus({
    required String chatRoomId,
    required String userId,
  }) {
    return _firebaseStore.collection('chats').doc(chatRoomId).snapshots().map((
      doc,
    ) {
      if (doc.exists && doc.data() != null) {
        return doc.data()!['typing_$userId'] ?? false;
      }
      return false;
    });
  }

  Future<void> markMessageAsRead({
    required String senderId,
    required String receiverId,
  }) async {
    final chatRoomId = getChatRoomId(senderId, receiverId);

    final messages = await _firebaseStore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .where('receiverId', isEqualTo: receiverId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in messages.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  Future<void> deleteMessage({
    required String senderId,
    required String receiverId,
    required String messageId,
  }) async {
    final chatRoomId = getChatRoomId(senderId, receiverId);
    await _firebaseStore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  Stream<int> getUnreadCount(String chatRoomId, String currentUserId) {
    return _firebaseStore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
