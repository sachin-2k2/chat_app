import 'package:chat_app/models/group_model.dart';
import 'package:chat_app/utils/app_colors.dart';
import 'package:chat_app/views/chat/group_chat_screen.dart';
import 'package:flutter/material.dart';

Widget buildGroupTile(BuildContext context, GroupModel group) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GroupChatScreen(group: group)),
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
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.Primary.withOpacity(0.2),
            child: group.groupImage.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      group.groupImage,
                      fit: BoxFit.cover,
                      width: 52,
                      height: 52,
                    ),
                  )
                : const Icon(
                    Icons.group_add_rounded,
                    color: AppColors.Primary,
                    size: 26,
                  ),
          ),
          const SizedBox(width: 12),

          //Group name and last message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.groupName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  group.lastMessage.isEmpty
                      ? '${group.members.length}members'
                      : group.lastMessage,
                  style: const TextStyle(fontSize: 13, color: AppColors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          //Time
          if (group.lastMessageTime != null)
            Text(
              '${group.lastMessageTime!.hour}:${group.lastMessageTime!.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 11, color: AppColors.grey ),
            ),
        ],
      ),
    ),
  );
}
