import 'package:chat_app/controllers/auth_controller.dart';
import 'package:chat_app/controllers/chat_controller.dart';
import 'package:chat_app/models/message_models.dart';
import 'package:chat_app/models/user_models.dart';
import 'package:chat_app/utils/app_colors.dart';
import 'package:chat_app/widgets/chat/chat_app_bar.dart';
import 'package:chat_app/widgets/chat/chat_input_bar.dart';
import 'package:chat_app/widgets/chat/message_bubble.dart';
import 'package:chat_app/widgets/chat/typing_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PersonalChatScreen_ extends StatefulWidget {
  final UserModel receiver;
  const PersonalChatScreen_({super.key, required this.receiver});

  @override
  State<PersonalChatScreen_> createState() => _PersonalChatScreen_State();
}

MessageModels? _replyMessage;

class _PersonalChatScreen_State extends State<PersonalChatScreen_> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  bool _isTyping = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
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

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final authController = context.read<AuthController>();
    final chatController = context.read<ChatController>();

    _isTyping = false;
    await chatController.updateTypingStatus(
      sendrId: authController.currentUser!.usid,
      receiverId: widget.receiver.usid,
      isTyping: false,
    );

    await chatController.sendMessage(
      senderId: authController.currentUser!.usid,
      receiverId: widget.receiver.usid,
      message: _messageController.text.trim(),
      replyMessage: _replyMessage?.message,
      replyMessageId: _replyMessage?.messageId,
      replySenderId: _replyMessage?.senderId,
    );

    _messageController.clear();
    _clearReplyMessage();
    _scrollToBottom();
  }

  void _sendReplyMessage(MessageModels message) {
    setState(() {
      _replyMessage = message;
    });
  }

  void _clearReplyMessage() {
    setState(() {
      _replyMessage = null;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authcontroller = context.read<AuthController>();
      final chatcontroller = context.read<ChatController>();
      chatcontroller.markMessageAsRead(
        senderId: widget.receiver.usid,
        receiverId: authcontroller.currentUser!.usid,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final chatController = context.watch<ChatController>();
    final currentUserId = authController.currentUser!.usid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildChatAppBar(context, widget.receiver),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: StreamBuilder<List<MessageModels>>(
              stream: chatController.getMessages(
                currentUserId,
                widget.receiver.usid,
              ),
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
                          'No Messages yet!\nSay Hello 👋',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.grey, fontSize: 15),
                        ),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data!;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final chatcontroller = context.read<ChatController>();
                  chatcontroller.markMessageAsRead(
                    senderId: widget.receiver.usid,
                    receiverId: currentUserId,
                  );
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
                    return buildMessageBubble(
                      context,
                      message,
                      isSent,
                      widget.receiver,
                      currentUserId,
                      _sendReplyMessage,
                    );
                  },
                );
              },
            ),
          ),

          // Typing indicator
          StreamBuilder<bool>(
            stream: chatController.getTypingStatus(
              sendrId: currentUserId,
              receiverId: widget.receiver.usid,
            ),
            builder: (context, snapshot) {
              return buildTypingIndicator(
                widget.receiver,
                snapshot.data ?? false,
              );
            },
          ),

          if (_replyMessage != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.Primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _replyMessage!.senderId ==
                                  authController.currentUser!.usid
                              ? 'You'
                              : widget.receiver.name,
                          style: const TextStyle(
                            color: AppColors.Primary,
                            fontWeight: .w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          _replyMessage!.message.isNotEmpty
                              ? _replyMessage!.message
                              : '📷 Image',
                          style: TextStyle(color: AppColors.grey, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _clearReplyMessage,
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppColors.grey,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

          // Input bar
          ChatInputBar(
            receiver: widget.receiver,
            messageController: _messageController,
            onMessageSent: _sendMessage,
          ),
        ],
      ),
    );
  }
}
