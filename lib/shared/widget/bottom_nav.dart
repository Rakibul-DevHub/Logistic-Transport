// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:woke_movie_rating/features/utils/app_text_styles.dart';
// import 'package:woke_movie_rating/features/views/home/home_screen.dart';
//
// import '../../utils/app_colors.dart';
// import '../community/community_screen.dart';
// import '../leaderboard/leaderboard_screen.dart';
// import '../user/user_screen.dart';
//
// class MainBottomNav extends StatefulWidget {
//   const MainBottomNav({super.key});
//
//   @override
//   State<MainBottomNav> createState() => _MainBottomNavState();
// }
//
// class _MainBottomNavState extends State<MainBottomNav> {
//   int _selectedIndex = 0;
//
//   // Screens list
//   final List<Widget> _screens = [
//     const HomeScreen(),
//     const LeaderboardScreen(),
//     const CommunityScreen(),
//     const UserProfileScreen(),
//   ];
//
//   // Custom navigation items data
//   final List<Map<String, dynamic>> _navItems = [
//     {
//       'icon': 'assets/icons/home.svg',
//       'activeIcon': 'assets/icons/home_fill.svg',
//       'label': 'Home',
//     },
//     {
//       'icon': 'assets/icons/leaderboard_Light.svg',
//       'activeIcon': 'assets/icons/leaderboard_Light_fill.svg',
//       'label': 'Leaderboard',
//     },
//     {
//       'icon': 'assets/icons/community_light.svg',
//       'activeIcon': 'assets/icons/community_light_fill.svg',
//       'label': 'Community',
//     },
//     {
//       'icon': 'assets/icons/User_alt_light.svg',
//       'activeIcon': 'assets/icons/User_alt_light_fill.svg',
//       'label': 'UserProfile',
//     },
//
//   ];
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.primaryColor,
//       body: IndexedStack( // 👈 THIS IS THE KEY CHANGE
//         index: _selectedIndex,
//         children: _screens,
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
//         child: Container(
//           height: 100.0,
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
//           decoration: BoxDecoration(
//             color: AppColors.primaryColor,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Row(
//             children: List.generate(_navItems.length, (index) {
//               final item = _navItems[index];
//               final isSelected = _selectedIndex == index;
//
//               return Expanded(
//                 child: GestureDetector(
//                   onTap: () => _onItemTapped(index),
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 2),
//                     decoration: BoxDecoration(
//                       color: isSelected ? AppColors.redColor : Colors.transparent,
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           SvgPicture.asset(
//                             isSelected ? item['activeIcon'] : item['icon'],
//                             width: 23,
//                             height: 23,
//                             colorFilter: ColorFilter.mode(
//                               isSelected ? AppColors.whiteColor : AppColors.whiteColor,
//                               BlendMode.srcIn,
//                             ),
//                           ),
//                           SizedBox(
//                             height: 8,
//                           ),
//
//                           Text(
//                             item['label'],
//                             style: AppTextStyle.smallText.copyWith(
//                                 color: isSelected ? AppColors.whiteColor : AppColors.whiteColor,
//                                 fontSize: 13
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             }),
//           ),
//         ),
//       ),
//     );
//   }
//
// }
//
