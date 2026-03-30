import 'package:chat_app/models/user_models.dart';
import 'package:chat_app/utils/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget buildChatAppBar(
    BuildContext context, UserModel receiver) {
  return AppBar(
    backgroundColor: AppColors.Primary,
    elevation: 0,
    leading: GestureDetector(
      onTap: () => Navigator.pop(context),
      child: const Icon(
        Icons.arrow_back_ios_new_rounded,
        color: Colors.white,
        size: 20,
      ),
    ),
    title: Row(
      children: [
        // Avatar with online dot
        Stack(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white.withOpacity(0.3),
              child: Text(
                receiver.name.substring(0, 1),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('user')
                    .doc(receiver.usid)
                    .snapshots(),
                builder: (context, snapshot) {
                  bool isOnline = false;
                  if (snapshot.hasData && snapshot.data!.exists) {
                    isOnline = snapshot.data!['isOnline'] ?? false;
                  }
                  return Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: isOnline ? Colors.greenAccent : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.Primary,
                        width: 1.5,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(width: 10),

        // Name and online status
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              receiver.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('user')
                  .doc(receiver.usid)
                  .snapshots(),
              builder: (context, snapshot) {
                bool isOnline = false;
                String lastSeen = '';
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data =
                      snapshot.data!.data() as Map<String, dynamic>;
                  isOnline = data['isOnline'] ?? false;
                  if (!isOnline && data['lastSeen'] != null) {
                    final dt = (data['lastSeen'] as Timestamp).toDate();
                    lastSeen =
                        'Last seen ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
                  }
                }
                return Text(
                  isOnline
                      ? 'Online'
                      : lastSeen.isEmpty
                          ? 'Offline'
                          : lastSeen,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    ),
    actions: [
      Container(
        margin: const EdgeInsets.only(right: 8),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.videocam_outlined,
          color: Colors.white,
          size: 20,
        ),
      ),
      Container(
        margin: const EdgeInsets.only(right: 16),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.call_outlined,
          color: Colors.white,
          size: 20,
        ),
      ),
    ],
  );
}