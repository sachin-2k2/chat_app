import 'package:chat_app/controllers/auth_controller.dart';
import 'package:chat_app/controllers/chat_controller.dart';
import 'package:chat_app/models/user_models.dart';
import 'package:chat_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatInputBar extends StatefulWidget {
  final UserModel receiver;
  final VoidCallback onMessageSent;
  final TextEditingController messageController;

  const ChatInputBar({
    super.key,
    required this.receiver,
    required this.onMessageSent,
    required this.messageController,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  bool _isTyping = false;

  void _onTypingChanged(String value) {
    final authController = context.read<AuthController>();
    final chatController = context.read<ChatController>();

    if (value.isNotEmpty && !_isTyping) {
      _isTyping = true;
      chatController.updateTypingStatus(
        sendrId: authController.currentUser!.usid,
        receiverId: widget.receiver.usid,
        isTyping: true,
      );
    } else if (value.isEmpty && _isTyping) {
      _isTyping = false;
      chatController.updateTypingStatus(
        sendrId: authController.currentUser!.usid,
        receiverId: widget.receiver.usid,
        isTyping: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Attachment button
            GestureDetector(
              onTap: () async {
                final chatController = context.read<ChatController>();
                final authController = context.read<AuthController>();
                await chatController.sendImageMessage(
                  senderId: authController.currentUser!.usid,
                  receiverId: widget.receiver.usid,
                  context: context,
                );
              },
              child: Consumer<ChatController>(
                builder: (context, chatController, child) {
                  return Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: chatController.isuploadingImage
                        ? const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: CircularProgressIndicator(
                              color: AppColors.Primary,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.attach_file_rounded,
                            color: AppColors.Primary,
                            size: 20,
                          ),
                  );
                },
              ),
            ),

            const SizedBox(width: 10),

            // Text input
            Expanded(
              child: TextField(
                controller: widget.messageController,
                style: const TextStyle(fontSize: 14),
                onChanged: _onTypingChanged,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle:
                      TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  prefixIcon: const Icon(
                    Icons.mic_outlined,
                    color: AppColors.grey,
                    size: 20,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 5),

            // Send button
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: GestureDetector(
                onTap: widget.onMessageSent,
                child: Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.Primary, AppColors.primaryLight],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.Primary.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}