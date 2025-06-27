import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:liteline_app/core/constants/app_colors.dart';
import 'package:liteline_app/core/constants/app_text_styles.dart';
import 'package:liteline_app/core/services/auth_service.dart';
import 'package:liteline_app/features/auth/screens/login_screen.dart';
import 'package:liteline_app/features/profile/screens/profile_screen.dart';
import 'package:liteline_app/features/profile/screens/settings_screen.dart';
import 'package:liteline_app/shared/theme/theme_provider.dart';
import '../../../features/auth/widgets/auth_button.dart';


class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  String _displayName = 'LiteLine User';
  String _username = '@litelineuser';
  String _avatarUrl = 'https://via.placeholder.com/150/00B900/FFFFFF?text=LL'; // Default avatar

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = await AuthService().getCurrentUser();
    if (user != null) {
      setState(() {
        _displayName = user['display_name'] ?? 'LiteLine User';
        _username = '@${user['username']}';
        // _avatarUrl = user['avatar_url'] ?? _avatarUrl; // Uncomment if user model includes avatar_url
      });
    }
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    ).then((_) => _loadUserProfile()); // Refresh profile on return
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void _logout() async {
    await AuthService().logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('More', style: AppTextStyles.appBarTitle),
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Section
          GestureDetector(
            onTap: _navigateToProfile,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: NetworkImage(_avatarUrl),
                    backgroundColor: AppColors.lightGreen,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayName,
                          style: AppTextStyles.displaySmall.copyWith(
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _username,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.textLight),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // General Settings
          _buildSectionTitle('General'),
          _buildSettingsItem(
            context,
            icon: Icons.qr_code_scanner,
            title: 'Scan QR Code',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Scan QR Code functionality coming soon!')),
              );
            },
          ),
          _buildSettingsItem(
            context,
            icon: Icons.settings,
            title: 'Settings',
            onTap: _navigateToSettings,
          ),
          _buildSettingsItem(
            context,
            icon: Icons.info_outline,
            title: 'About LiteLine',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'LiteLine',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2023 LiteLine. All rights reserved.',
                children: [
                  const Text('This is a LINE clone application built with Flutter.'),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Theme Toggle
          _buildSectionTitle('Display'),
          _buildSettingsItem(
            context,
            icon: themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            title: 'Dark Mode',
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
              activeColor: AppColors.primaryGreen,
            ),
            onTap: () {
              themeProvider.toggleTheme(!themeProvider.isDarkMode);
            }
          ),
          const SizedBox(height: 24),

          // Logout Button
          AuthButton(
            text: 'Logout',
            onPressed: _logout,
            color: AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(
        title,
        style: AppTextStyles.bodySmall.copyWith(
          color: Theme.of(context).textTheme.bodyMedium!.color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, {
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
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
              Icon(icon, color: Theme.of(context).iconTheme.color),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
              ),
              if (trailing != null) trailing,
              if (trailing == null)
                Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }
}