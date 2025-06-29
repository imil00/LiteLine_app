import 'package:flutter/material.dart';
import 'dart:io'; 
import 'package:path/path.dart' as p; 
import 'package:google_maps_flutter/google_maps_flutter.dart'; 
import 'package:liteline_app/core/constants/app_colors.dart';
import 'package:liteline_app/core/constants/app_text_styles.dart';
import 'package:liteline_app/core/database/models/chat_model.dart';
import 'package:liteline_app/core/database/models/message_model.dart';
import 'package:liteline_app/core/database/database_helper.dart';
import 'package:liteline_app/core/services/auth_service.dart';
import 'package:liteline_app/core/services/location_service.dart'; 
import '../../../core/utils/date_utils.dart';
import 'package:liteline_app/features/chat/widgets/message_bubble.dart';
import 'package:liteline_app/features/chat/widgets/message_input.dart';
import 'package:liteline_app/features/chat/widgets/attachment_picker.dart';
import 'package:liteline_app/features/chat/widgets/location_picker.dart';
import 'package:flutter/material.dart' show DateUtils;
import 'package:geolocator/geolocator.dart';
import 'package:liteline_app/core/services/location_service.dart';

import '../../../features/media/screens/camera_screen.dart';
import '../../../core/services/file_service.dart';
import '../../../core/constants/app_constants.dart';
import '../screens/chat_settings.screen.dart';
import 'package:uuid/uuid.dart';

class ChatRoomScreen extends StatefulWidget {
  final ChatModel chat;

  const ChatRoomScreen({super.key, required this.chat});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final AuthService _authService = AuthService();
  List<MessageModel> _messages = [];
  int? _currentUserId;
  bool _isMultiSelectMode = false;
  final Set<String> _selectedMessageIds =
      {}; // Set to store selected message IDs

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      setState(() {
        _currentUserId = user['id'];
      });
    }
  }

  Future<void> _loadMessages() async {
    if (widget.chat.chatId.isEmpty) return; // Ensure chatId is not empty

    final List<Map<String, dynamic>> messageMaps =
        await _dbHelper.getMessages(widget.chat.id!);
    setState(() {
      _messages = messageMaps.map((map) => MessageModel.fromMap(map)).toList();
    });
  }

  Future<void> _sendMessage({
    required String content,
    String messageType = 'text',
    String? filePath,
    String? fileName,
    int? fileSize,
    String? thumbnailPath,
    double? latitude,
    double? longitude,
  }) async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not logged in')),
      );
      return;
    }
    if (content.trim().isEmpty && messageType == 'text') {
      return; // Don't send empty text messages
    }

    final newMessage = MessageModel(
      messageId: const Uuid().v4(),
      chatId: widget.chat.chatId,
      senderId: _currentUserId!,
      messageType: messageType,
      content: content,
      filePath: filePath,
      fileName: fileName,
      fileSize: fileSize,
      thumbnailPath: thumbnailPath,
      latitude: latitude,
      longitude: longitude,
      isSent: true, // Assuming local sending is always successful
      isDelivered: true, // Assuming local delivery is always successful
      timestamp: DateTime.now(),
    );

    await _dbHelper.insertMessage(newMessage.toMap());
    _messageController.clear();
    _loadMessages(); // Reload messages to update UI
  }

  void _toggleMultiSelect(String messageId) {
    setState(() {
      if (_selectedMessageIds.contains(messageId)) {
        _selectedMessageIds.remove(messageId);
      } else {
        _selectedMessageIds.add(messageId);
      }
      _isMultiSelectMode = _selectedMessageIds.isNotEmpty;
    });
  }

  void _deleteSelectedMessages() async {
    if (_selectedMessageIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Messages'),
        content: Text(
            'Are you sure you want to delete ${_selectedMessageIds.length} selected messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
await _dbHelper.deleteMessagesByIds(_selectedMessageIds.map(int.parse).toList());
      setState(() {
        _selectedMessageIds.clear();
        _isMultiSelectMode = false;
      });
      _loadMessages(); // Reload messages to update UI
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('${_selectedMessageIds.length} messages deleted.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chat.chatName ?? 'Unknown Chat',
            style: AppTextStyles.appBarTitle),
        centerTitle: false,
        actions: _isMultiSelectMode
            ? [
                IconButton(
                  icon:
                      const Icon(Icons.delete_forever, color: AppColors.error),
                  onPressed: _deleteSelectedMessages,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _selectedMessageIds.clear();
                      _isMultiSelectMode = false;
                    });
                  },
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // TODO: Implement search in chat
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Search coming soon!')));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // TODO: Navigate to chat settings
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ChatSettingsScreen(chat: widget.chat)),
                    );
                  },
                ),
              ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgrounds/chat_background.png'),
            fit: BoxFit.cover,
            opacity: 0.2, // Make it subtle
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true, // Show latest messages at the bottom
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[
                      _messages.length - 1 - index]; // Display in correct order
                  final bool isMe = message.senderId == _currentUserId;
                  final bool isSelected =
                      _selectedMessageIds.contains(message.messageId);

                  // Group messages by date
                  final bool showDateHeader;
                  if (index == _messages.length - 1) {
                    showDateHeader = true;
                  } else {
                    final messageDate = _messages[_messages.length - 1 - index].timestamp;
                    final prevMessageDate = _messages[_messages.length - index].timestamp;
                    showDateHeader = !AppDateUtils.isSameDay(messageDate, prevMessageDate);
                  }

                  return Column(
                    children: [
                      if (showDateHeader)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Chip(
                            label: Text(
                              AppDateUtils.formatMessageTime(
                                  message.timestamp),
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.textWhite),
                            ),
                            backgroundColor:
                                AppColors.textLight.withOpacity(0.7),
                          ),
                        ),
                      GestureDetector(
                        onLongPress: () =>
                            _toggleMultiSelect(message.messageId),
                        onTap: _isMultiSelectMode
                            ? () => _toggleMultiSelect(message.messageId)
                            : null,
                        child: MessageBubble(
                          message: message,
                          isMe: isMe,
                          isSelected: isSelected,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            MessageInput(
              controller: _messageController,
              onSendMessage: (text) => _sendMessage(content: text),
              onPickAttachment: (type) async {
                if (type == 'camera') {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CameraScreen()),
                  );
                  if (result != null && result is String) {
                    // result is a file path of the captured image/video
                    final File file = File(result);
                    final String fileName = p.basename(file.path);
                    final int fileSize = await file.length();
                    final String messageType =
                        result.toLowerCase().endsWith('.mp4')
                            ? 'video'
                            : 'image';
                    final String? savedPath = await FileService().saveFile(
                        file,
                        messageType == 'image'
                            ? AppConstants.imagesPath
                            : AppConstants.videosPath);
                    if (savedPath != null) {
                      final String? thumbnailPath = await FileService()
                          .createThumbnail(savedPath, messageType);
                      _sendMessage(
                        content: '', 
                        messageType: messageType,
                        filePath: savedPath,
                        fileName: fileName,
                        fileSize: fileSize,
                        thumbnailPath: thumbnailPath,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to save file.')),
                      );
                    }
                  }
                } else if (type == 'gallery' || type == 'file') {
                  final result = await AttachmentPicker.pickFile(type);
                  if (result != null) {
                    final File file = File(result.files.single.path!);
                    final String fileName = result.files.single.name;
                    final int fileSize = result.files.single.size;
                    String messageType;
                    String subDirectory;

                    if (type == 'gallery') {
                      messageType = result.files.single.extension!
                              .toLowerCase()
                              .contains('mp4')
                          ? 'video'
                          : 'image';
                      subDirectory = messageType == 'image'
                          ? AppConstants.imagesPath
                          : AppConstants.videosPath;
                    } else {
                      // type == 'file'
                      messageType = 'file';
                      subDirectory = AppConstants.documentsPath;
                    }

                    final String? savedPath =
                        await FileService().saveFile(file, subDirectory);
                    if (savedPath != null) {
                      final String? thumbnailPath = await FileService()
                          .createThumbnail(savedPath, messageType);
                      _sendMessage(
                        content:
                            fileName, 
                        messageType: messageType,
                        filePath: savedPath,
                        fileName: fileName,
                        fileSize: fileSize,
                        thumbnailPath: thumbnailPath,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to save file.')),
                      );
                    }
                  }
                }
              },
              onShareLocation: () async {
                final LatLng? selectedLocation = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LocationPickerScreen()),
                );
                if (selectedLocation != null) {
                  final String address = await LocationService()
                      .getLocationAddress(selectedLocation);
                  _sendMessage(
                    content: address,
                    messageType: 'location',
                    latitude: selectedLocation.latitude,
                    longitude: selectedLocation.longitude,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}