import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:parkhere_desktop/main.dart';
import 'package:flutter/services.dart';

import 'package:parkhere_desktop/screens/city_list_screen.dart';
import 'package:parkhere_desktop/screens/users_list_screen.dart';
import 'package:parkhere_desktop/screens/review_list_screen.dart';
import 'package:parkhere_desktop/screens/business_report_screen.dart';
import 'package:parkhere_desktop/screens/parking_management_screen.dart';
import 'package:parkhere_desktop/screens/reservation_management_screen.dart';
import 'package:parkhere_desktop/screens/profile_screen.dart';
import 'package:parkhere_desktop/providers/user_provider.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({
    super.key,
    required this.child,
    required this.title,
    this.showBackButton = false,
  });
  final Widget child;
  final String title;
  final bool showBackButton;



  // Persist sidebar state globally across screen rebuilds
  static bool isSidebarExpanded = false; 
  static double sidebarScrollOffset = 0;

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _sidebarController;
  late Animation<double> _widthAnimation;
  late Animation<double> _textOpacityAnimation;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: MasterScreen.sidebarScrollOffset);
    _scrollController.addListener(() {
      MasterScreen.sidebarScrollOffset = _scrollController.offset;
    });

    _sidebarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: MasterScreen.isSidebarExpanded ? 1.0 : 0.0, // Start based on persisted state
    );

    _widthAnimation = Tween<double>(begin: 80, end: 260).animate(
      CurvedAnimation(
        parent: _sidebarController,
        curve: Curves.easeInOut,
      ),
    );

    // Text appears only in the last 30% of the expansion
    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _sidebarController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    if (_sidebarController.status == AnimationStatus.completed) {
      _sidebarController.reverse();
      MasterScreen.isSidebarExpanded = false;
    } else {
      _sidebarController.forward();
      MasterScreen.isSidebarExpanded = true;
    }
  }

  Widget _buildUserAvatar({double radius = 20}) {
    final user = UserProvider.currentUser;
    ImageProvider? imageProvider;
    if (user?.picture != null && (user!.picture!.isNotEmpty)) {
      try {
        final sanitized = user.picture!.replaceAll(
          RegExp(r'^data:image/[^;]+;base64,'),
          '',
        );
        final bytes = base64Decode(sanitized);
        imageProvider = MemoryImage(bytes);
      } catch (_) {
        imageProvider = null;
      }
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF1E3A8A),
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? Text(
              _getUserInitials(user?.firstName, user?.lastName),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  String _getUserInitials(String? firstName, String? lastName) {
    final f = (firstName ?? '').trim();
    final l = (lastName ?? '').trim();
    if (f.isEmpty && l.isEmpty) return 'U';
    final a = f.isNotEmpty ? f[0] : '';
    final b = l.isNotEmpty ? l[0] : '';
    return (a + b).toUpperCase();
  }

  void _showProfileOverlay(BuildContext context) {
    final user = UserProvider.currentUser;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Profile',
      barrierColor: Colors.black54.withOpacity(0.2),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(
                top: kToolbarHeight + 8,
                right: 12,
              ),
              child: FadeTransition(
                opacity: curved,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.9, end: 1.0).animate(curved),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 300,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).maybePop();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const ProfileScreen(),
                                          settings: const RouteSettings(name: 'ProfileScreen'),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 48,
                                          height: 48,
                                          child: _buildUserAvatar(radius: 24),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user != null
                                                  ? '${user.firstName} ${user.lastName}'
                                                  : 'Guest',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF1F2937),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              user?.username ?? '-',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () =>
                                      Navigator.of(context).maybePop(),
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 20,
                                  ),
                                  color: Colors.grey[700],
                                  tooltip: 'Close',
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.email_outlined,
                                  size: 18,
                                  color: Color(0xFF1E3A8A),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    user != null
                                        ? 'Email: ${user.email}'
                                        : 'Email: -',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF374151),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_city_outlined,
                                  size: 18,
                                  color: Color(0xFF1E3A8A),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    user != null
                                        ? 'City: ${user.cityName}'
                                        : 'City: -',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF374151),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Fixed Sidebar
          _buildModernSidebar(),
          
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Modern Glassmorphism AppBar
                _buildGlassmorphismAppBar(),
                
                // Content
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSidebar() {
    return AnimatedBuilder(
      animation: _sidebarController,
      builder: (context, child) {
        return Container(
          width: _widthAnimation.value,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E3A8A),
                const Color(0xFF3B82F6),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E3A8A).withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(4, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // Sidebar Header
              _buildSidebarHeader(),
              
              // Navigation Items
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  // Hide scrollbar when collapsed
                  physics: _widthAnimation.value < 150 
                      ? const NeverScrollableScrollPhysics() 
                      : const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    children: [
                      _buildNavTile(
                        context,
                        icon: Icons.analytics_outlined,
                        activeIcon: Icons.analytics,
                        label: 'Business Report',
                        screen: const BusinessReportScreen(),
                        routeName: 'BusinessReportScreen',
                      ),
                      const SizedBox(height: 4),
                      _buildNavTile(
                        context,
                        icon: Icons.rate_review_outlined,
                        activeIcon: Icons.rate_review,
                        label: 'Reviews',
                        screen: ReviewListScreen(),
                        routeName: 'ReviewListScreen',
                      ),
                      const SizedBox(height: 4),
                      _buildNavTile(
                        context,
                        icon: Icons.people_outlined,
                        activeIcon: Icons.people,
                        label: 'Users',
                        screen: UsersListScreen(),
                        routeName: 'UsersListScreen',
                      ),
                      const SizedBox(height: 4),
                      _buildNavTile(
                        context,
                        icon: Icons.local_parking_outlined,
                        activeIcon: Icons.local_parking,
                        label: 'Parking',
                        screen: const ParkingManagementScreen(),
                        routeName: 'ParkingManagementScreen',
                      ),
                      const SizedBox(height: 4),
                      _buildNavTile(
                        context,
                        icon: Icons.bookmark_added_outlined,
                        activeIcon: Icons.bookmark_added,
                        label: 'Reservations',
                        screen: const ReservationManagementScreen(),
                        routeName: 'ReservationManagementScreen',
                      ),
                      const SizedBox(height: 4),
                      _buildNavTile(
                        context,
                        icon: Icons.location_city_outlined,
                        activeIcon: Icons.location_city_rounded,
                        label: 'Cities',
                        screen: CityListScreen(),
                        routeName: 'CityListScreen',
                      ),
                    ],
                  ),
                ),
              ),
              
              // Logout Button
              _buildLogoutButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Wrap content in Opacity instead of conditional rendering for fluid animation
          if (_textOpacityAnimation.value > 0)
            Opacity(
              opacity: _textOpacityAnimation.value,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        "assets/images/3.png",
                        height: 90,
                        width: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ParkHere',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.clip,
                    softWrap: false,
                    maxLines: 1,
                  ),
                  Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.clip,
                    softWrap: false,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            
          // Collapse Toggle Button
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _toggleSidebar,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _sidebarController.value < 0.5
                      ? Icons.chevron_right
                      : Icons.chevron_left,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required Widget screen,
    required String routeName,
  }) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isSelected = _isRouteSelected(label, currentRoute);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => screen,
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
              settings: RouteSettings(name: routeName),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border(
                    left: BorderSide(
                      color: Colors.white,
                      width: 3,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: Colors.white,
                size: 22,
              ),
              // Use sized box and opacity for fluid transition
              if (_textOpacityAnimation.value > 0 || _sidebarController.value > 0.5) ...[ 
                const SizedBox(width: 16),
                Expanded(
                  child: Opacity(
                    opacity: _textOpacityAnimation.value,
                    child: Text(
                      label,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                      overflow: TextOverflow.clip,
                      softWrap: false,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _isRouteSelected(String label, String? currentRoute) {
    if (label == 'Business Report') {
      return currentRoute == 'BusinessReportScreen';
    } else if (label == 'Cities') {
      return currentRoute == 'CityListScreen' ||
          currentRoute == 'CityDetailsScreen';
    } else if (label == 'Users') {
      return currentRoute == 'UsersListScreen' ||
          currentRoute == 'UsersDetailsScreen' ||
          currentRoute == 'UsersEditScreen';
    } else if (label == 'Reviews') {
      return currentRoute == 'ReviewListScreen' ||
          currentRoute == 'ReviewDetailsScreen';
    } else if (label == 'Reservations') {
      return currentRoute == 'ReservationManagementScreen';
    }
    return false;
  }

  Widget _buildLogoutButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showLogoutDialog(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout_rounded, color: Colors.white, size: 22),
                if (_textOpacityAnimation.value > 0 || _sidebarController.value > 0.5) ...[
                  const SizedBox(width: 16),
                  Opacity(
                    opacity: _textOpacityAnimation.value,
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.clip,
                      softWrap: false,
                      maxLines: 1,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassmorphismAppBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E3A8A),
            const Color(0xFF2563EB),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            if (widget.showBackButton)
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                  color: Colors.white,
                ),
              ),
            // Page Title
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    'ParkHere Admin',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // User Avatar
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _showProfileOverlay(context),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                  ),
                  child: _buildUserAvatar(radius: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.logout_rounded, color: Color(0xFF1E3A8A)),
              SizedBox(width: 12),
              Text('Confirm Logout'),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout from your account?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
