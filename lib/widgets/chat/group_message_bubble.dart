import 'package:chat_app/controllers/chat_controller.dart';
import 'package:chat_app/models/message_models.dart';
import 'package:chat_app/utils/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget buildGroupMessageBubble({
  required BuildContext context,
  required MessageModels message,
  required bool isSent,
  required String groupId,
  required Function(MessageModels) onReply,
}) {
  return GestureDetector(
    onLongPress: () {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Message Options',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Reply option
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

                // Delete option
                if (isSent)
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
                      await FirebaseFirestore.instance
                          .collection('groups')
                          .doc(groupId)
                          .collection('messages')
                          .doc(message.messageId)
                          .delete();
                    },
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          );
        },
      );
    },
    child: Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSent) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.Primary.withOpacity(0.2),
              child: Text(
                message.senderId.substring(0, 1).toUpperCase(),
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
              // Reply preview inside bubble
              if (message.replyMessage != null &&
                  message.replyMessage!.isNotEmpty)
                Container(
                  constraints: BoxConstraints(
                    maxWidth:
                        MediaQuery.of(context).size.width * 0.65,
                  ),
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSent
                        ? AppColors.Primary.withOpacity(0.4)
                        : AppColors.Primary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border(
                      left: BorderSide(
                        color:
                            isSent ? Colors.white : AppColors.Primary,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Text(
                    message.replyMessage!,
                    style: TextStyle(
                      color:
                          isSent ? Colors.white70 : AppColors.dark,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Text message
              if (message.message.isNotEmpty)
                Container(
                  constraints: BoxConstraints(
                    maxWidth:
                        MediaQuery.of(context).size.width * 0.65,
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
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
              Text(
                '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                    color: AppColors.grey, fontSize: 11),
              ),
            ],
          ),

          if (isSent) const SizedBox(width: 8),
        ],
      ),
    ),
  );
}