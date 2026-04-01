import 'dart:io';

import 'package:chat_app/models/message_models.dart';
import 'package:chat_app/service/chat_service.dart';
import 'package:chat_app/service/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatController extends ChangeNotifier {
  final ChatService _chatservice = ChatService();

  List<MessageModels> _messages = [];
  bool _isLoading = false;

  List<MessageModels> get messages => _messages;
  bool get isLoading => _isLoading;

  final StorageService _storageService = StorageService();
  bool _isuploaingImage = false;
  bool get isuploadingImage => _isuploaingImage;

  //Send Message
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String message,
    String? replyMessage,
    String? replyMessageId,
    String? replySenderId,
  }) async {
    await _chatservice.sendMessage(
      senderId: senderId,
      receiverId: receiverId,
      message: message,
      replyMessage: replyMessage,
      replyMessageId: replyMessageId,
      replySenderId: replySenderId,
    );
  }

  //Get Messages stream
  Stream<List<MessageModels>> getMessages(String userId1, String userId2) {
    return _chatservice.getMessages(userId1, userId2);
  }

  //Get All Users
  Stream getAllUsers(String currentUserId) {
    return _chatservice.getAllUsers(currentUserId);
  }

  Stream<Map<String, dynamic>> getLastMessage(String userId1, String userId2) {
    final chatRoomId = _chatservice.getChatRoomId(userId1, userId2);
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomId)
        .snapshots()
        .map((doc) {
          if (doc.exists && doc.data() != null) {
            return doc.data() as Map<String, dynamic>;
          }
          return {};
        });
  }

  //Send Image
  Future<void> sendImageMessage({
    required String senderId,
    required String receiverId,
    required BuildContext context,
  }) async {
    try {
      File? image = await _storageService.pickImage();
      print('Image Picked:$image');
      if (image == null) return;

      _isuploaingImage = true;
      notifyListeners();

      //Upload Image
      String? imageUrl = await _storageService.uploadImage(
        file: image,
        senderId: senderId,
        receiverId: receiverId,
      );

      if (imageUrl != null) {
        await _chatservice.sendImageMessage(
          senderId: senderId,
          receiverId: receiverId,
          imageUrl: imageUrl,
        );
      }
    } catch (e) {
      print('Send image error:$e');
    } finally {
      _isuploaingImage = false;
      notifyListeners();
    }
  }

  //update typing status
  Future<void> updateTypingStatus({
    required String sendrId,
    required String receiverId,
    required bool isTyping,
  }) async {
    final chatRoomId = _chatservice.getChatRoomId(sendrId, receiverId);
    await _chatservice.updateTypingStatus(
      chatRoomId: chatRoomId,
      userId: sendrId,
      isTyping: isTyping,
    );
  }

  //Get Typing Status
  Stream<bool> getTypingStatus({
    required String sendrId,
    required String receiverId,
  }) {
    final chatRoomId = _chatservice.getChatRoomId(sendrId, receiverId);
    return _chatservice.getTypingStatus(
      chatRoomId: chatRoomId,
      userId: receiverId,
    );
  }

  Future<void> markMessageAsRead({
    required String senderId,
    required String receiverId,
  }) async {
    await _chatservice.markMessageAsRead(
      senderId: senderId,
      receiverId: receiverId,
    );
  }

  Future<void> deleteMessage({
    required String senderId,
    required String receiverId,
    required String messageId,
  }) async {
    await _chatservice.deleteMessage(
      senderId: senderId,
      receiverId: receiverId,
      messageId: messageId,
    );
  }

  // Get chat room id
  String getChatRoomId(String userId1, String userId2) {
    return _chatservice.getChatRoomId(userId1, userId2);
  }

  //Get unread count
  Stream<int> getUnreadCount(String chatRoomId, String currentUserId) {
    return _chatservice.getUnreadCount(chatRoomId, currentUserId);
  }
}
