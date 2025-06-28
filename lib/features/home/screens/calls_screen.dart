import 'package:flutter/material.dart';
import 'package:liteline_app/core/constants/app_text_styles.dart';
import '../../../shared/widgets/empaty_state.dart';
import 'package:liteline_app/core/constants/app_colors.dart';
import 'package:liteline_app/core/utils/date_utils.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  // Dummy data for call history
  final List<Map<String, dynamic>> _callHistory = [
    {
      'id': 'call1',
      'contact_name': 'John Doe',
      'call_type': 'incoming', // 'incoming', 'outgoing', 'missed'
      'timestamp': DateTime.now().subtract(const Duration(minutes: 30)).millisecondsSinceEpoch,
      'duration_seconds': 120,
      'avatar_url': 'https://via.placeholder.com/150/00BFFF/FFFFFF?text=JD',
    },
    {
      'id': 'call2',
      'contact_name': 'Jane Smith',
      'call_type': 'outgoing',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)).millisecondsSinceEpoch,
      'duration_seconds': 300,
      'avatar_url': 'https://via.placeholder.com/150/FF6347/FFFFFF?text=JS',
    },
    {
      'id': 'call3',
      'contact_name': 'Mom',
      'call_type': 'missed',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch,
      'duration_seconds': 0,
      'avatar_url': 'https://via.placeholder.com/150/9932CC/FFFFFF?text=Mom',
    },
     {
      'id': 'call4',
      'contact_name': 'Brother',
      'call_type': 'incoming',
      'timestamp': DateTime.now().subtract(const Duration(days: 2)).millisecondsSinceEpoch,
      'duration_seconds': 60,
      'avatar_url': 'https://via.placeholder.com/150/3CB371/FFFFFF?text=Bro',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calls', style: AppTextStyles.appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.dialpad),
            onPressed: () {
              // TODO: Implement dialpad
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dialpad coming soon!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              // TODO: Implement start new call (maybe to a contact)
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Start new call coming soon!')),
              );
            },
          ),
        ],
      ),
      body: _callHistory.isEmpty
          ? const EmptyState(
              icon: Icons.call,
              message: 'No call history yet.',
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: _callHistory.length,
              itemBuilder: (context, index) {
                final call = _callHistory[index];
                IconData icon;
                Color iconColor;

                switch (call['call_type']) {
                  case 'incoming':
                    icon = Icons.call_received;
                    iconColor = AppColors.primaryGreen;
                    break;
                  case 'outgoing':
                    icon = Icons.call_made;
                    iconColor = Colors.blue;
                    break;
                  case 'missed':
                    icon = Icons.call_missed;
                    iconColor = AppColors.error;
                    break;
                  default:
                    icon = Icons.call;
                    iconColor = AppColors.textSecondary;
                }

                String durationText = '';
                if (call['call_type'] != 'missed') {
                  int totalSeconds = call['duration_seconds'];
                  int minutes = totalSeconds ~/ 60;
                  int seconds = totalSeconds % 60;
                  durationText = ' (${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')})';
                }

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(call['avatar_url']),
                    radius: 24,
                  ),
                  title: Text(
                    call['contact_name'],
                    style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Row(
                    children: [
                      Icon(icon, size: 16, color: iconColor),
                      const SizedBox(width: 4),
                      Text(
                        '${AppDateUtils.formatLastSeen(call['timestamp'])}$durationText',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.info_outline, color: AppColors.textLight),
                    onPressed: () {
                      // TODO: Navigate to call details or contact profile
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Call details for ${call['contact_name']}')),
                      );
                    },
                  ),
                  onTap: () {
                    // TODO: Implement redial or open chat
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Calling ${call['contact_name']}... (Simulated)')),
                      );
                  },
                );
              },
            ),
    );
  }
}