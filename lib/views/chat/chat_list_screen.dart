import 'package:chat_app/controllers/auth_controller.dart';
import 'package:chat_app/controllers/chat_controller.dart';
import 'package:chat_app/controllers/group_controller.dart';
import 'package:chat_app/models/group_model.dart';
import 'package:chat_app/models/user_models.dart';
import 'package:chat_app/utils/app_colors.dart';
import 'package:chat_app/views/chat/create_group_screen.dart';
import 'package:chat_app/widgets/chat/build_bottom_sheet.dart';
import 'package:chat_app/widgets/chat_list/group_tile.dart';
import 'package:chat_app/widgets/common/buildbutton.dart';
import 'package:chat_app/widgets/chat_list/chat_tile.dart';
import 'package:chat_app/widgets/common/empty_state.dart';
import 'package:chat_app/widgets/chat_list/tab_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });
    WidgetsBinding.instance.addObserver(this);
    _setOnline();
  }

  void _setOnline() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      await context.read<AuthController>().setOnline();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final authController = context.read<AuthController>();
    if (authController.currentUser == null) return;
    if (state == AppLifecycleState.resumed) {
      authController.setOnline();
    } else if (state == AppLifecycleState.paused) {
      authController.setOffline();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final userName = authController.currentUser?.name ?? 'User';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello,',
                        style: TextStyle(fontSize: 14, color: AppColors.grey),
                      ),
                      Text(
                        userName,
                        style: const TextStyle(
                          color: AppColors.dark,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      buildbutton(Icons.search, () {}),
                      const SizedBox(width: 10),
                      buildbutton(Icons.more_vert_outlined, () {
                        showModalBottomSheet(
                          context: context,
                          builder: (_) => buildbottomsheet(context),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),

            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Container(
                height: 44,
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
                child: Row(
                  children: [
                    buildTabItem('All Chats', 0, _selectedTab, _tabController),
                    buildTabItem('Groups', 1, _selectedTab, _tabController),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Tab views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildChatList(),
                  _buildGroupList()
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
          );
        },
        backgroundColor: AppColors.Primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(16),
        ),
        child: const Icon(Icons.edit_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildChatList() {
    final authController = context.watch<AuthController>();
    final chatController = context.watch<ChatController>();
    final currentUserId = authController.currentUser?.usid ?? '';

    return StreamBuilder(
      stream: chatController.getAllUsers(currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.Primary),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return buildEmptyState('No Users Found', Icons.people_outline);
        }

        final users = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userData = users[index].data() as Map<String, dynamic>;
            final user = UserModel.fromMap(userData);
            if (user.usid == currentUserId) return const SizedBox();
            return buildChatTile(context, user, currentUserId, chatController);
          },
        );
      },
    );
  }

  Widget _buildGroupList() {
    final authController = context.watch<AuthController>();
    final groupController = context.watch<GroupController>();
    final currentUserId = authController.currentUser?.usid ?? '';

    return StreamBuilder<List<GroupModel>>(
      stream: groupController.getUserGroups(currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.Primary),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return buildEmptyState('No Groups Yet', Icons.group_outlined);
        }
        final groups = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            return buildGroupTile(context, group);
          },
        );
      },
    );
  }
}
