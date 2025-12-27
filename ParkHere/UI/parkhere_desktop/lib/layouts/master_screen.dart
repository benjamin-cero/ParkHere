import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:parkhere_desktop/main.dart';
import 'package:flutter/services.dart';
import 'package:parkhere_desktop/screens/city_list_screen.dart';
import 'package:parkhere_desktop/screens/country_list_screen.dart';
import 'package:parkhere_desktop/screens/category_list_screen.dart';
import 'package:parkhere_desktop/screens/organizer_list_screen.dart';
import 'package:parkhere_desktop/screens/subcategory_list_screen.dart';
import 'package:parkhere_desktop/screens/ticket_type_list_screen.dart';
import 'package:parkhere_desktop/screens/users_list_screen.dart';
import 'package:parkhere_desktop/screens/festival_list_screen.dart';
import 'package:parkhere_desktop/screens/festival_upsert_screen.dart';
import 'package:parkhere_desktop/screens/review_list_screen.dart';
import 'package:parkhere_desktop/screens/ticket_list_screen.dart';
import 'package:parkhere_desktop/screens/business_report_screen.dart';
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

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Widget _buildUserAvatar() {
    final user = UserProvider.currentUser;
    final double radius = 20;
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
      backgroundColor: const Color(0xFF6A1B9A),
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
                                SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: _buildUserAvatar(),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
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
                                ),
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
                                  color: Color(0xFF6A1B9A),
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
                                  color: Color(0xFF6A1B9A),
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.grey.withOpacity(0.1),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6A1B9A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.menu_rounded,
                color: Color(0xFF6A1B9A),
                size: 20,
              ),
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
              _animationController?.forward();
            },
          ),
        ),
        title: Row(
          children: [
            if (widget.showBackButton) ...[
              Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF374151),
                    size: 18,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'parkhere Admin Panel',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _showProfileOverlay(context),
                child: _buildUserAvatar(),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        width: 280,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: _slideAnimation != null
            ? AnimatedBuilder(
                animation: _slideAnimation!,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_slideAnimation!.value * 280, 0),
                    child: _buildDrawerContent(),
                  );
                },
              )
            : _buildDrawerContent(),
      ),
      body: Container(margin: const EdgeInsets.all(16), child: widget.child),
    );
  }

  Widget _buildDrawerContent() {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 16, right: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A1B9A).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Image.asset(
                    "assets/images/logo_large.png",
                    height: 50,
                    width: 50,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'parkhere',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Navigation section - Scrollable
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _modernDrawerTile(
                      context,
                      icon: Icons.analytics_outlined,
                      activeIcon: Icons.analytics,
                      label: 'Business Report',
                      screen: const BusinessReportScreen(),
                    ),
                    const SizedBox(height: 8),
                    _modernDrawerTile(
                      context,
                      icon: Icons.festival,
                      activeIcon: Icons.festival,
                      label: 'Festivals',
                      screen: FestivalListScreen(),
                    ),
                    const SizedBox(height: 8),
                    _modernDrawerTile(
                      context,
                      icon: Icons.confirmation_number_outlined,
                      activeIcon: Icons.confirmation_number,
                      label: 'Tickets',
                      screen: TicketListScreen(),
                    ),
                    const SizedBox(height: 8),
                    _modernDrawerTile(
                      context,
                      icon: Icons.confirmation_number_outlined,
                      activeIcon: Icons.confirmation_number,
                      label: 'Ticket Types',
                      screen: TicketTypeListScreen(),
                    ),
                    const SizedBox(height: 8),
                    _modernDrawerTile(
                      context,
                      icon: Icons.rate_review_outlined,
                      activeIcon: Icons.rate_review,
                      label: 'Reviews',
                      screen: ReviewListScreen(),
                    ),
                    const SizedBox(height: 8),
                    _modernDrawerTile(
                      context,
                      icon: Icons.people_outlined,
                      activeIcon: Icons.people,
                      label: 'Users',
                      screen: UsersListScreen(),
                    ),
                    const SizedBox(height: 8),
                    _modernDrawerTile(
                      context,
                      icon: Icons.business, // Business/company style icon
                      activeIcon: Icons.apartment, // Active state icon
                      label: 'Organizers',
                      screen: OrganizerListScreen(),
                    ),
                    const SizedBox(height: 8),
                    _modernDrawerTile(
                      context,
                      icon: Icons.category_outlined,
                      activeIcon: Icons.category,
                      label: 'Categories',
                      screen: CategoryListScreen(),
                    ),
                    const SizedBox(height: 8),
                    _modernDrawerTile(
                      context,
                      icon: Icons.view_list_outlined,
                      activeIcon: Icons.view_list,
                      label: 'Subcategories',
                      screen: SubcategoryListScreen(),
                    ),
                    const SizedBox(height: 8),
                    _modernDrawerTile(
                      context,
                      icon: Icons.flag_outlined,
                      activeIcon: Icons.flag,
                      label: 'Countries',
                      screen: CountryListScreen(),
                    ),
                    const SizedBox(height: 8),
                    _modernDrawerTile(
                      context,
                      icon: Icons.location_city_outlined,
                      activeIcon: Icons.location_city_rounded,
                      label: 'Cities',
                      screen: CityListScreen(),
                    ),

                    // Add more tiles here in the future
                  ],
                ),
              ),
            ),
          ),

          // Bottom section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Divider(color: Colors.white.withOpacity(0.2), thickness: 1),
                const SizedBox(height: 8),
                _modernLogoutTile(context),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _modernDrawerTile(
  BuildContext context, {
  required IconData icon,
  required IconData activeIcon,
  required String label,
  required Widget screen,
}) {
  final currentRoute = ModalRoute.of(context)?.settings.name;
  final screenRoute = screen.runtimeType.toString();

  // Get the current screen type from the route
  bool isSelected = false;

  if (label == 'Business Report') {
    isSelected = currentRoute == 'BusinessReportScreen';
  } else if (label == 'Categories') {
    isSelected =
        currentRoute == 'CategoryListScreen' ||
        currentRoute == 'CategoryDetailsScreen';
  } else if (label == 'Cities') {
    isSelected =
        currentRoute == 'CityListScreen' || currentRoute == 'CityDetailsScreen';
  } else if (label == 'Countries') {
    isSelected =
        currentRoute == 'CountryListScreen' ||
        currentRoute == 'CountryDetailsScreen';
  } else if (label == 'Subcategories') {
    isSelected =
        currentRoute == 'SubcategoryListScreen' ||
        currentRoute == 'SubcategoryDetailsScreen';
  } else if (label == 'Organizers') {
    isSelected =
        currentRoute == 'OrganizerListScreen' ||
        currentRoute == 'OrganizerDetailsScreen';
  } else if (label == 'Ticket Types') {
    isSelected =
        currentRoute == 'TicketTypeListScreen' ||
        currentRoute == 'TicketTypeDetailsScreen';
  } else if (label == 'Users') {
    isSelected =
        currentRoute == 'UsersListScreen' ||
        currentRoute == 'UsersDetailsScreen' ||
        currentRoute == 'UsersEditScreen';
  } else if (label == 'Festivals') {
    isSelected =
        currentRoute == 'FestivalListScreen' ||
        currentRoute == 'FestivalDetailsScreen' ||
        currentRoute == 'FestivalUpsertScreen';
  } else if (label == 'Reviews') {
    isSelected =
        currentRoute == 'ReviewListScreen' ||
        currentRoute == 'ReviewDetailsScreen';
  } else if (label == 'Tickets') {
    isSelected =
        currentRoute == 'TicketListScreen' ||
        currentRoute == 'TicketDetailsScreen';
  }

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 2),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => screen,
              settings: RouteSettings(name: screenRoute),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
                : null,
          ),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey(isSelected),
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _modernLogoutTile(BuildContext context) {
  return Container(
    width: double.infinity,
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _showLogoutDialog(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: const Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.white, size: 22),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Icon(Icons.exit_to_app_rounded, color: Colors.white, size: 18),
            ],
          ),
        ),
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
            Icon(Icons.logout_rounded, color: Color(0xFF6A1B9A)),
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
              Navigator.of(context).pop(); // Close dialog
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A1B9A),
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
