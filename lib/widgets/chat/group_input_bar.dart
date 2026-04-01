import 'package:chat_app/utils/app_colors.dart';
import 'package:flutter/material.dart';

Widget buildGroupInputBar({
  required TextEditingController messageController,
  required VoidCallback onSend,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
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
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: messageController,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle:
                    TextStyle(color: Colors.grey.shade400, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onSend,
          child: Container(
            width: 46,
            height: 46,
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
      ],
    ),
  );
}