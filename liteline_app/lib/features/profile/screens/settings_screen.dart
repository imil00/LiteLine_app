import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:liteline_app/core/constants/app_colors.dart';
import 'package:liteline_app/core/constants/app_text_styles.dart';
import 'package:liteline_app/shared/theme/theme_provider.dart';
import 'package:liteline_app/core/services/storage_service.dart'; // For SharedPreferences usage

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _saveMediaAutomatically = true;
  bool _darkThemeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await StorageService().init(); // Ensure StorageService is initialized
    setState(() {
      _notificationsEnabled = StorageService().getBool('notifications_enabled') ?? true;
      _saveMediaAutomatically = StorageService().getBool('save_media_automatically') ?? true;
      _darkThemeEnabled = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    });
  }

  Future<void> _updateSetting(String key, bool value) async {
    await StorageService().setBool(key, value);
    _loadSettings(); // Reload to reflect changes
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    _darkThemeEnabled = themeProvider.isDarkMode; // Ensure this is always in sync with ThemeProvider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: AppTextStyles.appBarTitle),
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle('Account'),
          _buildSettingsItem(
            context,
            icon: Icons.person_outline,
            title: 'Profile',
            onTap: () {
              // TODO: Navigate to ProfileScreen for editing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Go to profile to edit details.')),
              );
            },
          ),
          _buildSettingsItem(
            context,
            icon: Icons.lock_outline,
            title: 'Privacy',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy settings coming soon!')),
              );
            },
          ),
          _buildSettingsItem(
            context,
            icon: Icons.security,
            title: 'Security',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Security settings coming soon!')),
              );
            },
          ),
          const Divider(),

          _buildSectionTitle('Chat'),
          _buildSettingsItem(
            context,
            icon: Icons.notifications_none,
            title: 'Notifications',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                _updateSetting('notifications_enabled', value);
              },
              activeColor: AppColors.primaryGreen,
            ),
          ),
          _buildSettingsItem(
            context,
            icon: Icons.image,
            title: 'Save Media Automatically',
            trailing: Switch(
              value: _saveMediaAutomatically,
              onChanged: (value) {
                setState(() {
                  _saveMediaAutomatically = value;
                });
                _updateSetting('save_media_automatically', value);
              },
              activeColor: AppColors.primaryGreen,
            ),
          ),
          _buildSettingsItem(
            context,
            icon: Icons.wallpaper,
            title: 'Chat Wallpaper',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat wallpaper settings coming soon!')),
              );
            },
          ),
          const Divider(),

          _buildSectionTitle('Display'),
          _buildSettingsItem(
            context,
            icon: _darkThemeEnabled ? Icons.dark_mode : Icons.light_mode,
            title: 'Dark Mode',
            trailing: Switch(
              value: _darkThemeEnabled,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
                setState(() {
                  _darkThemeEnabled = value; // Update local state for immediate UI refresh
                });
                _updateSetting('dark_mode_enabled', value); // Save to shared_preferences
              },
              activeColor: AppColors.primaryGreen,
            ),
          ),
          _buildSettingsItem(
            context,
            icon: Icons.font_download_outlined,
            title: 'Font Size',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Font size settings coming soon!')),
              );
            },
          ),
          const Divider(),

          _buildSectionTitle('Other'),
          _buildSettingsItem(
            context,
            icon: Icons.help_outline,
            title: 'Help',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help section coming soon!')),
              );
            },
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
              if (trailing == null && onTap != null)
                Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }
}