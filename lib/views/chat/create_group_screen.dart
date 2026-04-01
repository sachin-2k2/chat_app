import 'package:chat_app/controllers/auth_controller.dart';
import 'package:chat_app/controllers/group_controller.dart';
import 'package:chat_app/models/user_models.dart';
import 'package:chat_app/utils/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  List<UserModel> _selectedMembers = [];
  List<UserModel> _allUsers = [];
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _groupNameController;
    // TODO: implement dispose
    super.dispose();
  }

  void _loadUsers() async {
    final authcontroller = context.read<AuthController>();
    final groupController = context.read<GroupController>();
    final currentUserId = authcontroller.currentUser!.usid;

    final users = await groupController.getAllUsers(currentUserId);
    setState(() {
      _allUsers = users
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  void _toggleMember(UserModel user) {
    setState(() {
      if (_selectedMembers.contains(user)) {
        _selectedMembers.remove(user);
      } else {
        _selectedMembers.add(user);
      }
    });
  }

  void _createGroup() async {
    if (_groupNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter group name'),
          backgroundColor: AppColors.Primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(12),
          ),
        ),
      );
      return;
    }
    if (_selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one member!'),
          backgroundColor: AppColors.Primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(12),
          ),
        ),
      );
      return;
    }
    final authcontroller = context.read<AuthController>();
    final groupController = context.read<GroupController>();

    setState(() {
      _isLoading = true;
    });

    bool success = await groupController.createGroup(
      groupName: _groupNameController.text,
      createdBy: authcontroller.currentUser!.usid,
      members: _selectedMembers.map((e) => e.usid).toList(),
    );
    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Group created successfully! 🎉'),
          backgroundColor: AppColors.Primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(12),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
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
        title: const Text(
          'Create Group',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: _isLoading ? null : _createGroup,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Create',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          //Group name input
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _groupNameController,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Enter group name...',
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.grade_rounded,
                  color: AppColors.Primary,
                  size: 20,
                ),
              ),
            ),
          ),

          //Selected members chips
          if (_selectedMembers.isNotEmpty)
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedMembers.length,
                itemBuilder: (context, index) {
                  final member = _selectedMembers[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(
                        member.name,
                        style: const TextStyle(
                          color: AppColors.Primary,
                          fontSize: 12,
                        ),
                      ),
                      deleteIcon: const Icon(
                        Icons.close,
                        size: 16,
                        color: AppColors.Primary,
                      ),
                      onDeleted: () => _toggleMember(member),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),

          //Members label
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text(
                  'Selected members',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.Primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_selectedMembers.length} selected',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          //Users list
          Expanded(
            child: _allUsers.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.Primary),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _allUsers.length,
                    itemBuilder: (context, index) {
                      final user = _allUsers[index];
                      final isSelected = _selectedMembers.contains(user);
                      return GestureDetector(
                        onTap: () => _toggleMember(user),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.Primary.withOpacity(0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: isSelected
                                ? Border.all(
                                    color: AppColors.Primary,
                                    width: 1.5,
                                  )
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: AppColors.Primary.withOpacity(
                                  0.2,
                                ),
                                child: Text(
                                  user.name.substring(0, 1),
                                  style: TextStyle(
                                    color: AppColors.Primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              //Name and Email
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.dark,
                                      ),
                                    ),
                                    Text(
                                      user.email,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              //CheckBox
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.Primary
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.Primary
                                        : Colors.grey,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
