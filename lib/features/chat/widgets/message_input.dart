import 'package:flutter/material.dart';
import 'package:liteline_app/core/constants/app_colors.dart';
import 'package:liteline_app/core/constants/app_text_styles.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSendMessage;
  final Function(String) onPickAttachment; // 'camera', 'gallery', 'file'
  final VoidCallback onShareLocation;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSendMessage,
    required this.onPickAttachment,
    required this.onShareLocation,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateTypingStatus);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateTypingStatus);
    super.dispose();
  }

  void _updateTypingStatus() {
    setState(() {
      _isTyping = widget.controller.text.isNotEmpty;
    });
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primaryGreen),
                title: const Text('Camera', style: AppTextStyles.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  widget.onPickAttachment('camera');
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primaryGreen),
                title: const Text('Gallery', style: AppTextStyles.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  widget.onPickAttachment('gallery');
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file, color: AppColors.primaryGreen),
                title: const Text('File', style: AppTextStyles.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  widget.onPickAttachment('file');
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_on, color: AppColors.primaryGreen),
                title: const Text('Location', style: AppTextStyles.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  widget.onShareLocation();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      color: AppColors.backgroundColor,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryGreen, size: 28),
            onPressed: () => _showAttachmentOptions(context),
          ),
          Expanded(
            child: TextField(
              controller: widget.controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              ),
              style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color),
              maxLines: null, // Allows multiline input
              keyboardType: TextInputType.multiline,
            ),
          ),
          const SizedBox(width: 8.0),
          _isTyping
              ? FloatingActionButton(
                  onPressed: () => widget.onSendMessage(widget.controller.text),
                  backgroundColor: AppColors.primaryGreen,
                  elevation: 0,
                  mini: true,
                  child: const Icon(Icons.send, color: AppColors.textWhite),
                )
              : IconButton(
                  icon: const Icon(Icons.mic, color: AppColors.primaryGreen, size: 28),
                  onPressed: () {
                    // TODO: Implement voice message recording
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Voice message coming soon!')),
                    );
                  },
                ),
        ],
      ),
    );
  }
}