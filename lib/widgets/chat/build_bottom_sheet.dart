import 'package:chat_app/controllers/auth_controller.dart';
import 'package:chat_app/views/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget buildbottomsheet(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(24.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 24),
        ListTile(
          leading: const Icon(Icons.logout_rounded, color: Colors.red),
          title: const Text(
            'Logout',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
          ),
          onTap: () async {
            Navigator.pop(context);
            await context.read<AuthController>().Logout();
            // Navigate to login screen after logout ✅
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => LoginPage()),
              (route) => false,
            );
          },
        ),
      ],
    ),
  );
}
