import 'package:flutter/material.dart';
import 'package:liteline_app/core/constants/app_colors.dart';
import 'package:liteline_app/core/constants/app_text_styles.dart';
import 'package:liteline_app/core/database/models/chat_model.dart';
import 'package:liteline_app/core/database/models/user_model.dart';
import 'package:liteline_app/core/database/database_helper.dart';
import 'package:liteline_app/core/database/models/user_model.dart';
import '../screens/chat_room_screen.dart';
import '../screens/chat_settings.screen.dart';

class ChatSettingsScreen extends StatefulWidget {
  final ChatModel chat;

  const ChatSettingsScreen({super.key, required this.chat});

  @override
  State<ChatSettingsScreen> createState() => _ChatSettingsScreenState();
}

class _ChatSettingsScreenState extends State<ChatSettingsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<UserModel> _participants = [];
  bool _isLoadingParticipants = false;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    setState(() {
      _isLoadingParticipants = true;
    });
    List<UserModel> participants = [];
    for (int userId in widget.chat.participants) {
      final userMap = await _dbHelper.getUserById(userId); // Anda perlu menambahkan getUserById di DatabaseHelper
      if (userMap != null) {
        participants.add(UserModel.fromMap(userMap));
      }
    }
    setState(() {
      _participants = participants;
      _isLoadingParticipants = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Settings', style: AppTextStyles.appBarTitle),
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Chat Name / Info
          ListTile(
            title: Text(
              widget.chat.chatName ?? (widget.chat.chatType == 'individual' ? 'Individual Chat' : 'Group Chat'),
              style: AppTextStyles.displayMedium,
            ),
            subtitle: Text(
              widget.chat.chatType == 'group' ? '${_participants.length} Participants' : 'Private Chat',
              style: AppTextStyles.bodyMedium,
            ),
            trailing: widget.chat.chatType == 'group'
                ? IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.primaryGreen),
                    onPressed: () {
                      // TODO: Implement edit group name/avatar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit group settings coming soon!')),
                      );
                    },
                  )
                : null,
          ),
          const Divider(),

          // Participants (for group chats)
          if (widget.chat.chatType == 'group') ...[
            _buildSectionTitle('Participants'),
            _isLoadingParticipants
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.7, // Adjust as needed
                    ),
                    itemCount: _participants.length + 1, // +1 for Add Participant button
                    itemBuilder: (context, index) {
                      if (index == _participants.length) {
                        return _buildAddParticipantButton();
                      }
                      final participant = _participants[index];
                      return _buildParticipantItem(participant);
                    },
                  ),
            const Divider(),
          ],

          // Media, Files & Links
          _buildSectionTitle('Media, Files & Links'),
          _buildSettingsOption(
            icon: Icons.photo_library_outlined,
            title: 'Photos & Videos',
            onTap: () {
              // TODO: Navigate to media gallery for this chat
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Media gallery coming soon!')),
              );
            },
          ),
          _buildSettingsOption(
            icon: Icons.insert_drive_file_outlined,
            title: 'Files',
            onTap: () {
              // TODO: Navigate to files list for this chat
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Files list coming soon!')),
              );
            },
          ),
          _buildSettingsOption(
            icon: Icons.link,
            title: 'Links',
            onTap: () {
              // TODO: Navigate to links list for this chat
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Links list coming soon!')),
              );
            },
          ),
          const Divider(),

          // Other Settings
          _buildSectionTitle('Other Settings'),
          _buildSettingsOption(
            icon: Icons.notifications_none,
            title: 'Notifications',
            trailing: Switch(
              value: true, // TODO: Get actual notification setting
              onChanged: (value) {
                // TODO: Update notification setting
                 ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Notifications ${value ? 'on' : 'off'}')),
                );
              },
              activeColor: AppColors.primaryGreen,
            ),
          ),
          _buildSettingsOption(
            icon: Icons.volume_mute,
            title: 'Mute Chat',
            trailing: Switch(
              value: false, // TODO: Get actual mute setting
              onChanged: (value) {
                // TODO: Update mute setting
                 ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Chat muted ${value ? 'on' : 'off'}')),
                );
              },
              activeColor: AppColors.primaryGreen,
            ),
          ),
          _buildSettingsOption(
            icon: Icons.delete_outline,
            title: 'Clear Chat History',
            onTap: () {
              _showClearChatHistoryDialog();
            },
            color: AppColors.error,
          ),
          _buildSettingsOption(
            icon: Icons.exit_to_app,
            title: widget.chat.chatType == 'group' ? 'Leave Group' : 'Block User',
            onTap: () {
              _showLeaveOrBlockDialog(widget.chat.chatType == 'group');
            },
            color: AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
    Color? color,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(icon, color: color ?? Theme.of(context).iconTheme.color),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(color: color ?? Theme.of(context).textTheme.bodyLarge!.color),
                ),
              ),
              if (trailing != null) trailing,
              if (trailing == null && onTap != null)
                Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantItem(UserModel participant) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(participant.avatarUrl ?? 'https://via.placeholder.com/150/00B900/FFFFFF?text=P'),
          backgroundColor: AppColors.lightGreen,
        ),
        const SizedBox(height: 4),
        Text(
          participant.displayName,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _buildAddParticipantButton() {
    return Column(
      children: [
        InkWell(
          onTap: () {
            // TODO: Implement add participant
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add participant coming soon!')),
            );
          },
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).cardColor,
              border: Border.all(color: AppColors.textLight.withOpacity(0.5)),
            ),
            child: Icon(Icons.person_add, color: AppColors.textLight),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Add',
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  void _showClearChatHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat History'),
        content: const Text('Are you sure you want to clear all messages from this chat? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // TODO: Implement actual clear chat history logic
              // This might involve deleting all messages for this chatId from the database
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat history cleared (simulated).')),
              );
            },
            child: const Text('Clear', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showLeaveOrBlockDialog(bool isGroup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isGroup ? 'Leave Group' : 'Block User'),
        content: Text(
          isGroup
              ? 'Are you sure you want to leave this group? You will no longer receive messages from this group.'
              : 'Are you sure you want to block this user? You will no longer receive messages or calls from this user.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // TODO: Implement leave group / block user logic
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isGroup ? 'Left group (simulated).' : 'User blocked (simulated).')),
              );
              Navigator.of(context).pop(); // Go back to chat list
            },
            child: Text(isGroup ? 'Leave' : 'Block', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// NOTE: You need to add a getUserById method to your DatabaseHelper.
// Example:
// Future<Map<String, dynamic>?> getUserById(int id) async {
//   final db = await database;
//   final results = await db.query(
//     'users',
//     where: 'id = ?',
//     whereArgs: [id],
//     limit: 1,
//   );
//   return results.isNotEmpty ? results.first : null;
// }