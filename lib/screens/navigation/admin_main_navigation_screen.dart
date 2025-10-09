import 'package:flutter/material.dart';
import '../dashboard/admin_dashboard_screen.dart';
import '../history/history_screen.dart';
import '../reports/user_reports_screen.dart';
import '../profile/profile_screen.dart';

class AdminMainNavigationScreen extends StatefulWidget {
  @override
  _AdminMainNavigationScreenState createState() => _AdminMainNavigationScreenState();
}

class _AdminMainNavigationScreenState extends State<AdminMainNavigationScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Force mobile layout to ensure bottom navigation always shows on mobile devices
    final isMobile = true; // Changed from: screenWidth < 800;

    // List of screens for admin
    final screens = [
      AdminDashboardScreen(),
      HistoryScreen(),
      UserReportsScreen(),
      ProfileScreen(),
    ];

    if (isMobile) {
      // Mobile layout with bottom navigation
      return Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard,
                    label: 'Dashboard',
                    index: 0,
                    isMobile: true,
                  ),
                  _buildNavItem(
                    icon: Icons.history_outlined,
                    activeIcon: Icons.history,
                    label: 'History',
                    index: 1,
                    isMobile: true,
                  ),
                  _buildNavItem(
                    icon: Icons.people_outline,
                    activeIcon: Icons.people,
                    label: 'Users',
                    index: 2,
                    isMobile: true,
                  ),
                  _buildNavItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'Profile',
                    index: 3,
                    isMobile: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      // Desktop layout with sidebar navigation
      return Scaffold(
        body: Row(
          children: [
            // Sidebar navigation
            Container(
              width: 250,
              color: Colors.white,
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(Icons.water_drop, color: const Color.fromARGB(255, 57, 73, 171), size: 32),
                        SizedBox(width: 12),
                        Text(
                          'Admin Panel',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 57, 73, 171),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  // Navigation items
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      children: [
                        _buildNavItem(
                          icon: Icons.dashboard_outlined,
                          activeIcon: Icons.dashboard,
                          label: 'Dashboard',
                          index: 0,
                          isMobile: false,
                        ),
                        _buildNavItem(
                          icon: Icons.history_outlined,
                          activeIcon: Icons.history,
                          label: 'History',
                          index: 1,
                          isMobile: false,
                        ),
                        _buildNavItem(
                          icon: Icons.people_outline,
                          activeIcon: Icons.people,
                          label: 'User Reports',
                          index: 2,
                          isMobile: false,
                        ),
                        _buildNavItem(
                          icon: Icons.person_outline,
                          activeIcon: Icons.person,
                          label: 'Profile',
                          index: 3,
                          isMobile: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Vertical divider
            Container(
              width: 1,
              color: Colors.grey[300],
            ),
            // Main content
            Expanded(
              child: screens[_currentIndex],
            ),
          ],
        ),
      );
    }
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isMobile,
  }) {
    final isActive = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Container(
        margin: isMobile ? EdgeInsets.zero : EdgeInsets.symmetric(vertical: 2),
        padding: isMobile 
            ? EdgeInsets.symmetric(horizontal: 16, vertical: 8)
            : EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color.fromARGB(255, 57, 73, 171) : Colors.transparent,
          borderRadius: BorderRadius.circular(isMobile ? 20 : 8),
        ),
        child: Row(
          mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? Colors.white : Colors.grey[600],
              size: 24,
            ),
            if (isActive && isMobile) ...[
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
            if (!isMobile) ...[
              SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[700],
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}