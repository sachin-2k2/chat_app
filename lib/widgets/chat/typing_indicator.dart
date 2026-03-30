import 'package:chat_app/models/user_models.dart';
import 'package:chat_app/utils/app_colors.dart';
import 'package:flutter/material.dart';

Widget buildTypingIndicator(UserModel receiver, bool isTyping) {
  if (!isTyping) return const SizedBox();

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    alignment: Alignment.centerLeft,
    child: Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: const Color.fromARGB(255, 128, 192, 222).withOpacity(0.3),
          child: Text(
            receiver.name.substring(0, 1),
            style: const TextStyle(
              color: Color.fromARGB(255, 64, 114, 207),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDot(0),
              const SizedBox(width: 4),
              _buildDot(1),
              const SizedBox(width: 4),
              _buildDot(2),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildDot(int index) {
  return TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: 0.3, end: 1.0),
    duration: Duration(milliseconds: 400 + (index * 200)),
    builder: (context, value, child) {
      return Opacity(
        opacity: value,
        child: Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: AppColors.Primary,
            shape: BoxShape.circle,
          ),
        ),
      );
    },
  );
}
