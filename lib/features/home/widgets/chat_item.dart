// lib/features/home/widgets/chat_item.dart

import 'package:flutter/material.dart';

class ChatItem extends StatelessWidget {
  final Map<String, dynamic> chat;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ChatItem({
    super.key,
    required this.chat,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isSelected ? Colors.green : Colors.grey[300],
        child: Text(chat['chat_name']?[0] ?? '?'),
      ),
      title: Text(chat['chat_name'] ?? 'Unknown'),
      subtitle: Text(chat['last_message'] ?? 'No message yet'),
      onTap: onTap,
      onLongPress: onLongPress,
      selected: isSelected,
    );
  }
}
