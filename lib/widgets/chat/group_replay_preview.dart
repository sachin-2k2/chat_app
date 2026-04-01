import 'package:chat_app/controllers/auth_controller.dart';
import 'package:chat_app/models/message_models.dart';
import 'package:chat_app/utils/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget buildReplyPreview({
  required BuildContext context,
  required MessageModels replyMessage,
  required VoidCallback onClear,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    color: Colors.white,
    child: Row(
      children: [
        Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.Primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('user')
                    .doc(replyMessage.senderId)
                    .snapshots(),
                builder: (context, snapshot) {
                  String senderName = 'User';
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data =
                        snapshot.data!.data() as Map<String, dynamic>;
                    senderName = data['name'] ?? 'User';
                  }
                  return Text(
                    replyMessage.senderId ==
                            context
                                .read<AuthController>()
                                .currentUser!
                                .usid
                        ? 'You'
                        : senderName,
                    style: const TextStyle(
                      color: AppColors.Primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  );
                },
              ),
              Text(
                replyMessage.message.isNotEmpty
                    ? replyMessage.message
                    : '📷 Image',
                style: const TextStyle(
                  color: AppColors.grey,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onClear,
          child: const Icon(
            Icons.close_rounded,
            color: AppColors.grey,
            size: 20,
          ),
        ),
      ],
    ),
  );
}