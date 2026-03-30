import 'package:chat_app/utils/app_colors.dart';
import 'package:flutter/material.dart';

Widget buildTabItem(
    String label, int index, int selectedTab, TabController tabController) {
  bool isSelected = selectedTab == index;
  return Expanded(
    child: GestureDetector(
      onTap: () => tabController.animateTo(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.Primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.white : AppColors.grey,
            ),
          ),
        ),
      ),
    ),
  );
}