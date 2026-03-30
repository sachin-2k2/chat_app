import 'package:chat_app/controllers/chat_controller.dart';
import 'package:chat_app/models/message_models.dart';
import 'package:chat_app/models/user_models.dart';
import 'package:chat_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget buildMessageBubble(
  BuildContext context,
  MessageModels message,
  bool isSent,
  UserModel receiver,
  String currentUserId,
  Function(MessageModels) onReply,
) {
  return GestureDetector(
    onLongPress: () {
      _showDeleteDialog(context, message, currentUserId, receiver, onReply);
    },
    child: Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: isSent
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSent) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.Primary.withOpacity(0.2),
              child: Text(
                receiver.name.substring(0, 1),
                style: const TextStyle(
                  color: AppColors.Primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          Column(
            crossAxisAlignment: isSent
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              // Reply preview inside bubble ✅
              if (message.replyMessage != null &&
                  message.replyMessage!.isNotEmpty)
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.65,
                  ),
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSent
                        ? const Color.fromARGB(
                            255,
                            173,
                            158,
                            158,
                          ).withOpacity(0.2)
                        : AppColors.Primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border(
                      left: BorderSide(
                        color: isSent ? Colors.white : AppColors.Primary,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Text(
                    message.replyMessage!,
                    style: TextStyle(
                      color: isSent ? Colors.black : AppColors.dark,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Image message
              if (message.imageUrl.isNotEmpty)
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.65,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      message.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 200,
                          height: 150,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.Primary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // Text message
              if (message.message.isNotEmpty)
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.65,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSent ? AppColors.Primary : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isSent ? 18 : 4),
                      bottomRight: Radius.circular(isSent ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.message,
                    style: TextStyle(
                      color: isSent ? Colors.white : AppColors.dark,
                      fontSize: 14,
                    ),
                  ),
                ),

              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: AppColors.grey, fontSize: 11),
                  ),
                  if (isSent) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.isRead
                          ? Icons.done_all_rounded
                          : Icons.done_rounded,
                      size: 14,
                      color: message.isRead ? Colors.blue : AppColors.grey,
                    ),
                  ],
                ],
              ),
            ],
          ),

          if (isSent) const SizedBox(width: 8),
        ],
      ),
    ),
  );
}

void _showDeleteDialog(
  BuildContext context,
  MessageModels message,
  String currentUserId,
  UserModel receiver,
  Function(MessageModels) onReply,
) {
  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Message Options',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reply option ✅
            ListTile(
              leading: const Icon(
                Icons.reply_rounded,
                color: AppColors.Primary,
              ),
              title: const Text(
                'Reply',
                style: TextStyle(
                  color: AppColors.Primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onReply(message);
              },
            ),

            // Delete option (only for sent messages)
            if (message.senderId == currentUserId)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                ),
                title: const Text(
                  'Delete for me',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await context.read<ChatController>().deleteMessage(
                    senderId: currentUserId,
                    receiverId: receiver.usid,
                    messageId: message.messageId,
                  );
                },
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
        ],
      );
    },
  );
}
