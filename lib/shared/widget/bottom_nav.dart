import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_routes.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  final List<NavItem> _navItems = [
    const NavItem(
      label: 'Home',
      iconOutline: 'assets/icons/home.svg',
      iconFilled: 'assets/icons/home_select.svg',
    ),
    const NavItem(
      label: 'Load',
      iconOutline: 'assets/icons/load.svg',
      iconFilled: 'assets/icons/load_select.svg',
    ),
    const NavItem(
      label: 'Report',
      iconOutline: 'assets/icons/report.svg',
      iconFilled: 'assets/icons/report_select.svg',
    ),
    const NavItem(
      label: 'Profile',
      iconOutline: 'assets/icons/profile.svg',
      iconFilled: 'assets/icons/profile_select.svg',
    ),
  ];

  // ✅ Method to get screens dynamically (lazy initialization)
  List<Widget> _getScreens() {
    return [
      AppRoutes.routes[AppRoutes.home]!(context),
      AppRoutes.routes[AppRoutes.load]!(context),
      AppRoutes.routes[AppRoutes.report]!(context),
      AppRoutes.routes[AppRoutes.profile]!(context),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screens = _getScreens(); // Get fresh screens each time (optional)

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_navItems.length, (index) {
          return _buildNavItem(index, _navItems[index]);
        }),
      ),
    );
  }

  Widget _buildNavItem(int index, NavItem item) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A5F) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              isSelected ? item.iconFilled : item.iconOutline,
              width: 24,
              height: 24,
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF1E3A5F),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Added const constructor
class NavItem {
  final String label;
  final String iconOutline;
  final String iconFilled;

  const NavItem({
    required this.label,
    required this.iconOutline,
    required this.iconFilled,
  });
}