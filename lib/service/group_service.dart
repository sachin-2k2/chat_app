import 'package:chat_app/models/group_model.dart';
import 'package:chat_app/models/message_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //create group
  Future<GroupModel?> createGroup({
    required String groupName,
    required String createdBy,
    required List<String> members,
    String groupImage = '',
  }) async {
    try {
      final groupId = DateTime.now().microsecondsSinceEpoch.toString();

      GroupModel group = GroupModel(
        groupId: groupId,
        groupName: groupName,
        groupImage: groupImage,
        members: [...members, createdBy],
        createdBy: createdBy,
        lastMessage: '',
        lastMessageTime: null,
      );
      await _firestore.collection('groups').doc(groupId).set(group.toMap());
      return group;
    } catch (e) {
      print('Create group error:$e');
      return null;
    }
  }

  // send group messgage
Future<void> sendGroupMessage({
  required String groupId,
  required String senderId,
  required String message,
  String imageUrl = '',
  String? replyMessage,    // ← add
  String? replyMessageId,  // ← add
  String? replySenderId,   // ← add
}) async {
  try {
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();

    MessageModels newMessage = MessageModels(
      messageId: messageId,
      senderId: senderId,
      receiverId: groupId,
      message: message,
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
      isRead: false,
      replyMessage: replyMessage,      // ← add
      replyMessageId: replyMessageId,  // ← add
      replySenderId: replySenderId,    // ← add
    );

    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(messageId)
        .set(newMessage.toMap());

    await _firestore.collection('groups').doc(groupId).update({
      'lastMessage': message.isNotEmpty ? message : '📷 Image',
      'lastMessageTime': DateTime.now(),
    });
  } catch (e) {
    print('Send group message error: $e');
  }
}
  //get group message stream
  Stream<List<MessageModels>> getGroupMessages(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return MessageModels.fromMap(doc.data());
          }).toList();
        });
  }

  // Get  user Groups  stream
  Stream<List<GroupModel>> getUserGroups(String userId) {
    return _firestore
        .collection('groups')
        .where('members', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return GroupModel.fromMap(doc.data());
          }).toList();
        });
  }

  //get all users for adding to group
  Future<List<DocumentSnapshot>> getAllUsers(String currentUserId) async {
    final snapshot = await _firestore.collection('user').get();
    return snapshot.docs.where((doc) => doc.id != currentUserId).toList();
  }
}
