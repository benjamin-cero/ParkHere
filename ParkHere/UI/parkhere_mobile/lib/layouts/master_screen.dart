import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parkhere_mobile/providers/user_provider.dart';
import 'package:parkhere_mobile/screens/profile_screen.dart';
import 'package:parkhere_mobile/screens/home_screen.dart';
import 'package:parkhere_mobile/screens/review_list_screen.dart';
import 'package:parkhere_mobile/screens/parking_explorer_screen.dart';
import 'package:parkhere_mobile/screens/my_reservations_screen.dart';
import 'package:parkhere_mobile/utils/base_textfield.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({super.key, required this.child, required this.title});
  final Widget child;
  final String title;

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  int _selectedIndex = 0;
  int _previousIndex = 0;

  final List<String> _pageTitles = [
    'Dashboard',
    'Find Parking',
    'My Reservations',
    'Reviews',
    'Profile',
  ];

  final List<IconData> _pageIcons = [
    Icons.dashboard_rounded,
    Icons.local_parking_rounded,
    Icons.event_note_rounded,
    Icons.rate_review_rounded,
    Icons.person_rounded,
  ];

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0: return HomeScreen(onTileTap: _onItemTapped);
      case 1: return const ParkingExplorerScreen();
      case 2: return const MyReservationsScreen();
      case 3: return const ReviewListScreen();
      case 4: return const ProfileScreen();
      default: return HomeScreen(onTileTap: _onItemTapped);
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    
    setState(() {
      _previousIndex = _selectedIndex;
      _selectedIndex = index;
    });
  }

  void _handleLogout() {
    UserProvider.currentUser = null;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.primary),
            SizedBox(width: 12),
            Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel", style: TextStyle(color: AppColors.textLight)),
          ),
          AppButton(
            text: "Logout",
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              // Premium Header
              Container(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                decoration: BoxDecoration(
                  gradient: AppGradients.mainBackground,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      _buildHeaderIcon(),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _pageTitles[_selectedIndex],
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              "ParkHere Premium",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _selectedIndex == 4 
                      ? GestureDetector(
                          onTap: _handleLogout,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Image.asset(
                              "assets/images/3.png",
                              width: 42,
                              height: 42,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Content with Seamless Slide Transitions
              Expanded(
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity == null) return;
                    
                    // Swipe Left (Next Page)
                    if (details.primaryVelocity! < -500) {
                      if (_selectedIndex < _pageIcons.length - 1) {
                        _onItemTapped(_selectedIndex + 1);
                      }
                    }
                    // Swipe Right (Previous Page)
                    else if (details.primaryVelocity! > 500) {
                      if (_selectedIndex > 0) {
                        _onItemTapped(_selectedIndex - 1);
                      }
                    }
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      final bool isForward = _selectedIndex > _previousIndex;
                      final slideIn = Tween<Offset>(
                        begin: Offset(isForward ? 1.0 : -1.0, 0.0),
                        end: Offset.zero,
                      ).animate(animation);
                      
                      final slideOut = Tween<Offset>(
                        begin: Offset(isForward ? -1.0 : 1.0, 0.0),
                        end: Offset.zero,
                      ).animate(animation);

                      if (child.key == ValueKey(_selectedIndex)) {
                        return SlideTransition(position: slideIn, child: child);
                      } else {
                        return SlideTransition(position: slideOut, child: child);
                      }
                    },
                    child: KeyedSubtree(
                      key: ValueKey(_selectedIndex),
                      child: _getPage(_selectedIndex),
                    ),
                  ),
                ),
              ),

              // Premium Bottom Nav
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.only(bottom: 25, top: 12, left: 12, right: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_pageIcons.length, (index) {
                    return _buildNavigationItem(
                      index: index,
                      icon: _pageIcons[index],
                      label: _pageTitles[index],
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderIcon() {
    final user = UserProvider.currentUser;
    final isProfilePage = _selectedIndex == 4;

    if (isProfilePage && user?.picture != null && user!.picture!.isNotEmpty) {
      ImageProvider? imageProvider = ProfileScreen.getUserImageProvider(user.picture);
      return Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
        ),
        child: CircleAvatar(
          radius: 18,
          backgroundImage: imageProvider,
          backgroundColor: Colors.white24,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(_pageIcons[_selectedIndex], color: Colors.white, size: 24),
    );
  }

  Widget _buildNavigationItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? AppColors.primary : AppColors.textLight;
    final user = UserProvider.currentUser;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            index == 4 && user?.picture != null && user!.picture!.isNotEmpty
            ? Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 12,
                  backgroundImage: ProfileScreen.getUserImageProvider(user.picture),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                ),
              )
            : Icon(
                icon,
                color: color,
                size: 24,
              ),
            const SizedBox(height: 4),
            Text(
              isSelected ? label : "",
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
