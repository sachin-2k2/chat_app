import 'package:chat_app/controllers/auth_controller.dart';
import 'package:chat_app/controllers/group_controller.dart';
import 'package:chat_app/models/group_model.dart';
import 'package:chat_app/models/message_models.dart';
import 'package:chat_app/utils/app_colors.dart';
import 'package:chat_app/widgets/chat/group_input_bar.dart';
import 'package:chat_app/widgets/chat/group_message_bubble.dart';
import 'package:chat_app/widgets/chat/group_replay_preview.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupChatScreen extends StatefulWidget {
  final GroupModel group;
  const GroupChatScreen({super.key, required this.group});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  MessageModels? _replyMessage;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _setReplyMessage(MessageModels message) {
    setState(() => _replyMessage = message);
  }

  void _clearReplyMessage() {
    setState(() => _replyMessage = null);
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final authController = context.read<AuthController>();
    final groupController = context.read<GroupController>();

    await groupController.sendGroupMessage(
      groupId: widget.group.groupId,
      senderId: authController.currentUser!.usid,
      message: _messageController.text.trim(),
      replyMessage: _replyMessage?.message,
      replyMessageId: _replyMessage?.messageId,
      replySenderId: _replyMessage?.senderId,
    );

    _messageController.clear();
    _clearReplyMessage();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final groupController = context.watch<GroupController>();
    final currentUserId = authController.currentUser!.usid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.Primary,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white.withOpacity(0.3),
              child: widget.group.groupImage.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        widget.group.groupImage,
                        fit: BoxFit.cover,
                        width: 40,
                        height: 40,
                      ),
                    )
                  : const Icon(
                      Icons.group_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.group.groupName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.group.members.length} members',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: StreamBuilder<List<MessageModels>>(
              stream: groupController.getGroupMessages(widget.group.groupId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.Primary),
                  );
                }
                if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 64,
                          color: AppColors.grey.withOpacity(0.4),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No messages yet!\nSay Hello 👋',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.grey, fontSize: 15),
                        ),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data!;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isSent = message.senderId == currentUserId;
                    return buildGroupMessageBubble(
                      context: context,
                      message: message,
                      isSent: isSent,
                      groupId: widget.group.groupId,
                      onReply: _setReplyMessage,
                    );
                  },
                );
              },
            ),
          ),

          // Reply preview
          if (_replyMessage != null)
            buildReplyPreview(
              context: context,
              replyMessage: _replyMessage!,
              onClear: _clearReplyMessage,
            ),

          // Input bar
          buildGroupInputBar(
            messageController: _messageController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}
