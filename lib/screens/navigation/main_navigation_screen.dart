import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../dashboard/mobile_dashboard_screen.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
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
        duration: const Duration(milliseconds: 300),
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
    final isMobile = screenWidth < 800;

    // Hanya 3 halaman sekarang: Dashboard, History, Profile
    final List<Map<String, Object>> navItems = [
      {
        'screen': MobileDashboardScreen(),
        'icon': Icons.home_outlined,
        'activeIcon': Icons.home,
        'label': isMobile ? 'Home' : 'Dashboard',
      },
      {
        'screen': HistoryScreen(),
        'icon': Icons.history_outlined,
        'activeIcon': Icons.history,
        'label': 'History',
      },
      {
        'screen': ProfileScreen(),
        'icon': Icons.person_outline,
        'activeIcon': Icons.person,
        'label': 'Profile',
      },
    ];

    final screens = navItems.map<Widget>((it) => it['screen'] as Widget).toList();

    if (isMobile) {
      // Layout Mobile: bottom navigation bar
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
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(navItems.length, (i) {
                  final item = navItems[i];
                  return _buildNavItem(
                    icon: item['icon'] as IconData,
                    activeIcon: item['activeIcon'] as IconData,
                    label: item['label'] as String,
                    index: i,
                    isMobile: true,
                  );
                }),
              ),
            ),
          ),
        ),
      );
    } else {
      // Layout Desktop: sidebar navigation
      return Scaffold(
        body: Row(
          children: [
            Container(
              width: 250,
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.water_drop,
                          color: Color.fromARGB(255, 57, 73, 171),
                          size: 32,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Kolam Ikan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 57, 73, 171),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      children: List.generate(navItems.length, (i) {
                        final item = navItems[i];
                        return _buildNavItem(
                          icon: item['icon'] as IconData,
                          activeIcon: item['activeIcon'] as IconData,
                          label: item['label'] as String,
                          index: i,
                          isMobile: false,
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            Container(width: 1, color: Colors.grey[300]),
            Expanded(child: screens[_currentIndex]),
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
        margin: isMobile ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 2),
        padding: isMobile
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? const Color.fromARGB(255, 57, 73, 171)
              : Colors.transparent,
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
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
            if (!isMobile) ...[
              const SizedBox(width: 12),
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
