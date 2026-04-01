import 'package:chat_app/models/group_model.dart';
import 'package:chat_app/models/message_models.dart';
import 'package:chat_app/service/group_service.dart';
import 'package:flutter/material.dart';

class GroupController extends ChangeNotifier {
  final GroupService _groupService = GroupService();

  List<GroupModel> _groups = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<GroupModel> get groups => _groups;
  bool get isLoading => isLoading;
  String get errorMessage => _errorMessage;

  //create group
  Future<bool> createGroup({
    required String groupName,
    required String createdBy,
    required List<String> members,
    String groupImage = '',
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    GroupModel? group = await _groupService.createGroup(
      groupName: groupName,
      createdBy: createdBy,
      members: members,
      groupImage: groupImage,
    );

    if (group != null) {
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _isLoading = false;
      _errorMessage = 'Failed to create group';
      notifyListeners();
      return false;
    }
  }

  //Send Group Message
Future<void> sendGroupMessage({
  required String groupId,
  required String senderId,
  required String message,
  String imageUrl = '',
  String? replyMessage,
  String? replyMessageId,
  String? replySenderId,
}) async {
  await _groupService.sendGroupMessage(
    groupId: groupId,
    senderId: senderId,
    message: message,
    imageUrl: imageUrl,
    replyMessage: replyMessage,
    replyMessageId: replyMessageId,
    replySenderId: replySenderId,
  );
}
  //get group message
  Stream<List<MessageModels>> getGroupMessages(String groupId) {
    return _groupService.getGroupMessages(groupId);
  }

  //Get user groups
  Stream<List<GroupModel>> getUserGroups(String userId) {
    return _groupService.getUserGroups(userId);
  }

  //Get all users
  Future<List> getAllUsers(String currentUserId) async {
    return await _groupService.getAllUsers(currentUserId);
  }
}
