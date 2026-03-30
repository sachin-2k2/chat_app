import 'package:chat_app/utils/app_colors.dart';
import 'package:flutter/material.dart';

Widget buildbutton(IconData icon, VoidCallback ontap) {
  return GestureDetector(
    onTap: ontap,
    child: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, size: 20, color: AppColors.dark),
    ),
  );
}
