import 'package:flutter/material.dart';
import 'package:liteline_app/core/constants/app_colors.dart';
import 'package:liteline_app/core/constants/app_text_styles.dart';
import 'package:liteline_app/core/services/auth_service.dart';
import 'package:liteline_app/features/profile/widgets/profile_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _displayName = 'LiteLine User';
  String _username = '@litelineuser';
  String _statusMessage = 'Hey there! I am using LiteLine.';
  String _avatarUrl = 'https://via.placeholder.com/150/00B900/FFFFFF?text=LL'; // Default avatar

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = await AuthService().getCurrentUser();
    if (user != null) {
      // For a real app, you'd fetch the full user details from the database
      // using the user['id'] and update the state.
      // Example: final fullUser = await DatabaseHelper().getUserById(user['id']);
      setState(() {
        _displayName = user['display_name'] ?? 'LiteLine User';
        _username = '@${user['username']}';
        // If your User model from DB includes these:
        // _statusMessage = fullUser?.statusMessage ?? _statusMessage;
        // _avatarUrl = fullUser?.avatarUrl ?? _avatarUrl;
      });
    }
  }

  void _editProfile() {
    // TODO: Implement navigation to an edit profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit profile coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: AppTextStyles.appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileHeader(
              avatarUrl: _avatarUrl,
              displayName: _displayName,
              username: _username,
              statusMessage: _statusMessage,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileInfoTile(
                    context,
                    icon: Icons.person_outline,
                    title: 'Display Name',
                    subtitle: _displayName,
                  ),
                  _buildProfileInfoTile(
                    context,
                    icon: Icons.alternate_email,
                    title: 'Username',
                    subtitle: _username,
                  ),
                  _buildProfileInfoTile(
                    context,
                    icon: Icons.info_outline,
                    title: 'Status Message',
                    subtitle: _statusMessage,
                    onTap: () {
                      // TODO: Allow editing status message
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit status message coming soon!')),
                      );
                    },
                  ),
                  _buildProfileInfoTile(
                    context,
                    icon: Icons.phone,
                    title: 'Phone Number',
                    subtitle: 'Not set', // TODO: Fetch actual phone number
                  ),
                  _buildProfileInfoTile(
                    context,
                    icon: Icons.email_outlined,
                    title: 'Email',
                    subtitle: 'user@example.com', // TODO: Fetch actual email
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Add more profile sections if needed
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoTile(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }
}