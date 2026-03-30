import 'package:chat_app/utils/app_colors.dart';
import 'package:flutter/material.dart';

Widget buildEmptyState(String message, IconData icon) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 64, color: AppColors.grey.withOpacity(0.4)),
        const SizedBox(height: 16),
        Text(
          message,
          style: const TextStyle(
            color: AppColors.grey,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}