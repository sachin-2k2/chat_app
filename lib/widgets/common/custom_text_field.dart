import 'package:flutter/material.dart';

Widget customfield({
  required String hint,
  required TextEditingController controller,
  required IconData icon,
  bool ispassword = false,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(4, 4),
        ),
      ],
    ),
    child: TextFormField(
      controller: controller,
      obscureText: ispassword,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    ),
  );
}
