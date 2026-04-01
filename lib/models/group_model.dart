class GroupModel {
  final String groupId;
  final String groupName;
  final String groupImage;
  final List<String> members;
  final String createdBy;
  final String lastMessage;
  final DateTime? lastMessageTime;

  GroupModel({
    required this.groupId,
    required this.groupName,
    required this.groupImage,
    required this.members,
    required this.createdBy,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      groupId: map['groupId'] ?? '',
      groupName: map['groupName'] ?? '',
      groupImage: map['groupImage'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      createdBy: map['createdBy'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: map['lastMessageTime'] != null
          ? (map['lastMessageTime']).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'groupImage': groupImage,
      'members': members,
      'createdBy': createdBy,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
    };
  }
}
