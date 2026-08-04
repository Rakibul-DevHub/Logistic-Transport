/**
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
  late final List<Widget> _screens;

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

  @override
  void initState() {
    super.initState();
    _screens = [
      AppRoutes.routes[AppRoutes.home]!(context),
      AppRoutes.routes[AppRoutes.load]!(context),
      AppRoutes.routes[AppRoutes.report]!(context),
      AppRoutes.routes[AppRoutes.profile]!(context),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
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
      onTap: () => setState(() => _selectedIndex = index),
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

class NavItem {
  final String label;
  final String iconOutline;
  final String iconFilled;

  const NavItem({
    required this.label,
    required this.iconOutline,
    required this.iconFilled,
  });
}*/
















import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tag/feature/home/view/home_screen.dart';
import '../../core/constants/app_routes.dart';
import 'immersive_safe_area.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => BottomNavState();
}

class BottomNavState extends State<BottomNav> {
  /// Allows pushed routes (e.g. Load Details after create) to refresh Home.
  static BottomNavState? instance;

  int _selectedIndex = 0;
  late final List<Widget> _screens;
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();

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

  @override
  void initState() {
    super.initState();
    instance = this;
    _screens = [
      HomeScreen(key: _homeKey),
      AppRoutes.routes[AppRoutes.load]!(context),
      AppRoutes.routes[AppRoutes.report]!(context),
      AppRoutes.routes[AppRoutes.profile]!(context),
    ];
  }

  @override
  void dispose() {
    if (identical(instance, this)) instance = null;
    super.dispose();
  }

  /// Switch tab programmatically from any child screen:
  /// context.findAncestorStateOfType<BottomNavState>()?.switchTab(1);
  void switchTab(int index) {
    if (index < 0 || index >= _screens.length) return;
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
    }
    // Silent home refresh on Home tab tap (no visible spinner).
    if (index == 0) {
      _homeKey.currentState?.reloadSilently();
    }
  }

  /// Silent home refresh from outside the tab tree (e.g. after creating a load).
  /// Does not touch profile header (avatar/name).
  void refreshHomeSilently() {
    _homeKey.currentState?.reloadSilently();
  }

  /// Sync home header from Account Settings cache after profile update.
  void refreshHomeProfileFromAccountCache() {
    _homeKey.currentState?.reloadProfileFromAccountCache();
  }

  @override
  Widget build(BuildContext context) {
    // Restore notch/camera insets for tab screens (immersiveSticky zeroes padding).
    return MediaQuery(
      data: withImmersiveSafePadding(context),
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
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
      onTap: () => switchTab(index),
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