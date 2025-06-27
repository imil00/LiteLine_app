// lib/features/home/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import 'chat_list_screen.dart';
import 'timeline_screen.dart';
import 'calls_screen.dart';
import 'more_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> 
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;
  
  final List<Widget> _screens = [
    const ChatListScreen(),
    const TimelineScreen(),
    const CallsScreen(),
    const MoreScreen(),
  ];

  final List<String> _titles = [
    'Chats',
    'Timeline',
    'Calls',
    'More',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // App Logo
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Title
                  Expanded(
                    child: Text(
                      _titles[_currentIndex],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  // Action buttons based on current tab
                  if (_currentIndex == 0) ...[
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {
                        // TODO: Implement search
                        _showSearchDialog();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () {
                        // TODO: Implement new chat
                        _showNewChatOptions();
                      },
                    ),
                  ] else if (_currentIndex == 1) ...[
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: () {
                        // TODO: Implement camera for timeline
                        _openCamera();
                      },
                    ),
                  ] else if (_currentIndex == 2) ...[
                    IconButton(
                      icon: const Icon(Icons.call, color: Colors.white),
                      onPressed: () {
                        // TODO: Implement new call
                        _showCallOptions();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      
bottomNavigationBar: Container(
  decoration: BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, -2),
      ),
    ],
  ),
  child: TabBar(
    controller: _tabController,
    labelColor: AppColors.primaryGreen,
    unselectedLabelColor: AppColors.textLight,
    indicatorColor: Colors.transparent,
    labelStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
    ),
    tabs: [
      _buildTab(Icons.chat_bubble_outline, Icons.chat_bubble, 'Chats', 0),
      _buildTab(Icons.timeline_outlined, Icons.timeline, 'Timeline', 1),
      _buildTab(Icons.call_outlined, Icons.call, 'Calls', 2),
      _buildTab(Icons.more_horiz_outlined, Icons.more_horiz, 'More', 3),
    ],
  ),
),

    );
  }

  Widget _buildTab(IconData outlinedIcon, IconData filledIcon, String label, int index) {
    final isSelected = _currentIndex == index;
    return Tab(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          isSelected ? filledIcon : outlinedIcon,
          key: ValueKey(isSelected),
          size: 24,
        ),
      ),
      text: label,
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Search Chats',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search messages...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Implement search logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                      ),
                      child: const Text('Search'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNewChatOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person_add, color: AppColors.primaryGreen),
              title: const Text('New Chat'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to contact list
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_add, color: AppColors.primaryGreen),
              title: const Text('New Group'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to create group
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner, color: AppColors.primaryGreen),
              title: const Text('Scan QR Code'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Open QR scanner
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _openCamera() {
    // TODO: Implement camera functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Camera feature coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCallOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.call, color: AppColors.primaryGreen),
              title: const Text('Voice Call'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement voice call
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: AppColors.primaryGreen),
              title: const Text('Video Call'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement video call
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}