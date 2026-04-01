import 'package:chat_app/controllers/chat_controller.dart';
import 'package:chat_app/models/user_models.dart';
import 'package:chat_app/utils/app_colors.dart';
import 'package:chat_app/views/chat/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Widget buildChatTile(
  BuildContext context,
  UserModel user,
  String currentUserId,
  ChatController chatController,
) {
  final chatRoomId = chatController.getChatRoomId(currentUserId, user.usid);

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PersonalChatScreen_(receiver: user),
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with online indicator
          Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.Primary.withOpacity(0.2),
                child: Text(
                  user.name.substring(0, 1),
                  style: const TextStyle(
                    color: AppColors.Primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('user')
                      .doc(user.usid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    bool isOnline = false;
                    if (snapshot.hasData && snapshot.data!.exists) {
                      isOnline = snapshot.data!['isOnline'] ?? false;
                    }
                    return Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(width: 10),

          // Name, last message and unread count
          Expanded(
            child: StreamBuilder<Map<String, dynamic>>(
              stream: chatController.getLastMessage(
                  currentUserId, user.usid),
              builder: (context, lastMsgSnapshot) {
                String lastMessage = 'Tap to start chatting';
                String time = '';

                if (lastMsgSnapshot.hasData &&
                    lastMsgSnapshot.data!.isNotEmpty) {
                  lastMessage =
                      lastMsgSnapshot.data!['lastMessage'] ?? '';
                  final timestamp =
                      lastMsgSnapshot.data!['lastMessageTime'];
                  if (timestamp != null) {
                    final dt = (timestamp).toDate();
                    time =
                        '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
                  }
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Name and last message
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.dark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lastMessage,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Time and unread count
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Time
                        if (time.isNotEmpty)
                          Text(
                            time,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.grey,
                            ),
                          ),

                        const SizedBox(height: 4),

                        // Unread count ✅
                        StreamBuilder<int>(
                          stream: chatController.getUnreadCount(
                              chatRoomId, currentUserId),
                          builder: (context, unreadSnapshot) {
                            final unreadCount =
                                unreadSnapshot.data ?? 0;
                            if (unreadCount == 0) {
                              return const SizedBox();
                            }
                            return Container(
                               width: 20,
                              height: 20,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4),
                              decoration: const BoxDecoration(
                                color: AppColors.Primary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  unreadCount > 99
                                      ? '99+'
                                      : unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),
    ),
  );
}