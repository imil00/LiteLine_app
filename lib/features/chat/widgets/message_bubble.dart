import 'package:flutter/material.dart';
import 'package:liteline_app/core/constants/app_colors.dart';
import 'package:liteline_app/core/constants/app_text_styles.dart';
import 'package:liteline_app/core/database/models/message_model.dart';
import 'package:liteline_app/core/utils/date_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Maps_flutter/Maps_flutter.dart';
import 'package:liteline_app/features/media/screens/media_viewer_screen.dart'; // For media preview

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool isSelected; // For multi-select mode

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.isSelected = false,
  });

  Widget _buildMessageContent(BuildContext context) {
    switch (message.messageType) {
      case 'text':
        return Text(
          message.content,
          style: AppTextStyles.chatMessage.copyWith(
            color: isMe ? AppColors.textWhite : AppColors.textPrimary,
          ),
        );
      case 'image':
      case 'video':
        return GestureDetector(
          onTap: () {
            if (message.filePath != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MediaViewerScreen(
                    filePath: message.filePath!,
                    mediaType: message.messageType,
                  ),
                ),
              );
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: message.filePath != null
                    ? Image.file(
                        File(message.filePath!),
                        width: 200,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.error, size: 50),
                      )
                    : CachedNetworkImage( // For network images if any
                        imageUrl: message.content, // Assuming content is URL for network images
                        width: 200,
                        height: 150,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error, size: 50),
                      ),
              ),
              if (message.messageType == 'video')
                const Positioned.fill(
                  child: Center(
                    child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 48),
                  ),
                ),
              if (message.content.isNotEmpty && message.messageType != 'image')
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    message.content,
                    style: AppTextStyles.chatMessage.copyWith(
                      color: isMe ? AppColors.textWhite : AppColors.textPrimary,
                    ),
                  ),
                ),
            ],
          ),
        );
      case 'file':
        return GestureDetector(
          onTap: () {
            // TODO: Implement file opening
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Opening file: ${message.fileName ?? message.content}')),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.insert_drive_file,
                  color: isMe ? AppColors.textWhite : AppColors.primaryGreen),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.fileName ?? 'File',
                      style: AppTextStyles.chatMessage.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isMe ? AppColors.textWhite : AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${(message.fileSize ?? 0) / 1024 / 1024} MB', // Convert bytes to MB
                      style: AppTextStyles.caption.copyWith(
                        color: isMe ? AppColors.textWhite.withOpacity(0.7) : AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case 'location':
        return GestureDetector(
          onTap: () {
            if (message.latitude != null && message.longitude != null) {
              // TODO: Open external map application
              // Example: `launchUrl(Uri.parse('google.navigation:q=${message.latitude},${message.longitude}'));`
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening map for: ${message.content}')),
              );
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 200,
                  height: 150,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(message.latitude!, message.longitude!),
                      zoom: 14,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('location'),
                        position: LatLng(message.latitude!, message.longitude!),
                      ),
                    },
                    zoomControlsEnabled: false,
                    scrollGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    rotateGesturesEnabled: false,
                    myLocationButtonEnabled: false,
                    myLocationEnabled: false,
                    mapToolbarEnabled: false,
                    onMapCreated: (controller) {
                      // Do nothing, just display
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  message.content.isNotEmpty ? message.content : 'Shared Location',
                  style: AppTextStyles.chatMessage.copyWith(
                    color: isMe ? AppColors.textWhite : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
      case 'sticker':
        return SizedBox(
          width: 100, // Adjust size as needed
          height: 100,
          child: Image.asset(
            message.content, // Assuming content is local asset path for sticker
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.sentiment_very_dissatisfied, size: 50, color: AppColors.textLight),
          ),
        );
      default:
        return Text(
          'Unsupported message type: ${message.messageType}',
          style: AppTextStyles.chatMessage.copyWith(
            color: isMe ? AppColors.textWhite : AppColors.textPrimary,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: isMe
              ? (isSelected ? AppColors.primaryGreen.withOpacity(0.7) : AppColors.bubbleSent)
              : (isSelected ? AppColors.bubbleReceived.withOpacity(0.7) : AppColors.bubbleReceived),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
          ),
          border: isSelected
              ? Border.all(
                  color: isMe ? AppColors.textWhite : AppColors.primaryGreen,
                  width: 2,
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe) // Show sender name for others in group chat (or 1-on-1 if preferred)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  'Sender Name Placeholder', // TODO: Fetch actual sender name
                  style: AppTextStyles.chatSenderName.copyWith(color: AppColors.primaryGreen),
                ),
              ),
            _buildMessageContent(context),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppDateUtils.formatTime(message.timestamp),
                  style: AppTextStyles.chatTimestamp.copyWith(
                    color: isMe ? AppColors.textWhite.withOpacity(0.8) : AppColors.textLight,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : (message.isDelivered ? Icons.done_all : Icons.done),
                    size: 16,
                    color: message.isRead ? Colors.blue : (message.isDelivered ? AppColors.textWhite.withOpacity(0.8) : AppColors.textWhite.withOpacity(0.6)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}