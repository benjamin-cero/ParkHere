import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:parkhere_mobile/model/parking_reservation.dart';
import 'package:parkhere_mobile/providers/parking_reservation_provider.dart';
import 'package:parkhere_mobile/utils/base_textfield.dart';
import 'package:parkhere_mobile/providers/user_provider.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onTileTap;

  const HomeScreen({
    super.key,
    required this.onTileTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // Animation
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // State
  bool _isLoading = true;
  ParkingReservation? _upcomingReservation; // The nearest active reservation
  
  // Timer
  String _timeRemaining = "";
  
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutQuart),
    ));

    _animController.forward();
    _loadDashboardData();
  }
  
  Future<void> _loadDashboardData() async {
      try {
          final userId = UserProvider.currentUser?.id;
          if (userId == null) return;
          
          final result = await Provider.of<ParkingReservationProvider>(context, listen: false).get(filter: {
            'userId': userId,
            'excludePassed': false,
            'retrieveAll': true,
          });
          
          final now = DateTime.now();
          final reservations = result.items ?? [];
          
          // Find the "most urgent" reservation:
          // 1. If someone is currently arrived (Arrived)
          // 2. Otherwise, the nearest future one (Pending)
          ParkingReservation? bestMatch;
          
          // Look for "Arrived" (Active session)
          try {
            bestMatch = reservations.firstWhere((r) => r.actualStartTime != null && r.actualEndTime == null);
          } catch (_) {
            // Look for nearest "Pending" (Future)
            final futureOnes = reservations.where((r) => r.actualStartTime == null && r.endTime.isAfter(now)).toList()
              ..sort((a,b) => a.startTime.compareTo(b.startTime));
            
            if (futureOnes.isNotEmpty) {
              bestMatch = futureOnes.first;
            }
          }
          
          if (bestMatch != null) {
              setState(() {
                  _upcomingReservation = bestMatch;
              });
              _startTimer();
          }
      } catch (e) {
          debugPrint("Failed to load dashboard data: $e");
      } finally {
          setState(() => _isLoading = false);
      }
  }
  
  void _startTimer() {
      Future.doWhile(() async {
          if (!mounted || _upcomingReservation == null) return false;
          
          final now = DateTime.now();
          final start = _upcomingReservation!.startTime;
          final end = _upcomingReservation!.endTime;
          final isArrived = _upcomingReservation!.actualStartTime != null;

          if (isArrived) {
              // Active session: Show time left until forced end
              final diff = end.difference(now);
              if (diff.isNegative) {
                  setState(() => _upcomingReservation = null);
                  return false;
              }
              setState(() => _timeRemaining = _formatDuration(diff));
          } else {
              // Pending: Show time until start
              final diff = start.difference(now);
              if (diff.isNegative) {
                  // If we reached start time, maybe refresh to see if user "Arrived"
                  _loadDashboardData();
                  return false;
              }
              setState(() => _timeRemaining = _formatCountdown(diff));
          }
          
          await Future.delayed(const Duration(seconds: 1));
          return true;
      });
  }
  
  String _formatDuration(Duration d) {
      String twoDigits(int n) => n.toString().padLeft(2, "0");
      final hours = twoDigits(d.inHours);
      final minutes = twoDigits(d.inMinutes.remainder(60));
      final seconds = twoDigits(d.inSeconds.remainder(60));
      return "$hours:$minutes:$seconds";
  }

  String _formatCountdown(Duration d) {
    if (d.inDays > 0) {
      return "${d.inDays}d ${d.inHours.remainder(24)}h ${d.inMinutes.remainder(60)}m";
    }
    return "${d.inHours}h ${d.inMinutes.remainder(60)}m ${d.inSeconds.remainder(60)}s";
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = UserProvider.currentUser;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${user?.firstName ?? "Guest"}!',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Status Card (Main Action)
              _buildMainStatusCard(),
              
              const SizedBox(height: 40),
              
              // Quick Actions Grid
              const Text(
                'Explore ParkHere',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 20),
              
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildActionCard(
                    icon: Icons.local_parking_rounded,
                    title: 'Find Spot',
                    subtitle: 'Book parking now',
                    onTap: () => widget.onTileTap(1),
                    color: AppColors.primary,
                  ),
                  _buildActionCard(
                    icon: Icons.history_rounded,
                    title: 'Reservations',
                    subtitle: 'Manage bookings',
                    onTap: () => widget.onTileTap(2),
                    color: const Color(0xFF4C51BF),
                  ),
                  _buildActionCard(
                    icon: Icons.rate_review_rounded,
                    title: 'Reviews',
                    subtitle: 'Community feedback',
                    onTap: () => widget.onTileTap(3),
                    color: const Color(0xFF2D3748),
                  ),
                  _buildActionCard(
                    icon: Icons.manage_accounts_rounded,
                    title: 'Profile',
                    subtitle: 'Account settings',
                    onTap: () => widget.onTileTap(4),
                    color: AppColors.primaryDark,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainStatusCard() {
    if (_isLoading) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
        child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final hasReservation = _upcomingReservation != null;
    final isArrived = hasReservation && _upcomingReservation!.actualStartTime != null;
    final isPending = hasReservation && !isArrived;
    
    // Status color (for icons/badges) - Yellow for Pending as requested
    final accentColor = isPending ? AppColors.reserved : Colors.white;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: AppGradients.mainBackground, // Keep it blue as requested
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withOpacity(0.3),
                blurRadius: 25,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      Icons.directions_car_rounded,
                      color: accentColor,
                      size: 28,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Text(
                      isArrived ? 'SESSION ACTIVE' : (isPending ? 'PENDING' : 'READY TO PARK'),
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              
              if (hasReservation) ...[
                  Text(
                    _timeRemaining,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isArrived ? "Remaning time" : "Countdown to your booking",
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),
                  
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                         _buildStatusRow(Icons.calendar_today_rounded, isArrived ? "Active Since" : "Booking Date", 
                          DateFormat('EEEE, MMM d').format(_upcomingReservation!.startTime)),
                        const SizedBox(height: 12),
                        _buildStatusRow(Icons.access_time_rounded, "Time Window", 
                          "${DateFormat('HH:mm').format(_upcomingReservation!.startTime)} - ${DateFormat('HH:mm').format(_upcomingReservation!.endTime)}"),
                        const SizedBox(height: 12),
                        if (_upcomingReservation!.parkingSpot != null) ...[
                          _buildStatusRow(Icons.map_rounded, "Location", 
                            "${_upcomingReservation!.parkingSpot!.parkingSectorName} • ${_upcomingReservation!.parkingSpot!.parkingWingName}"),
                          const SizedBox(height: 12),
                        ],
                        _buildStatusRow(Icons.local_parking_rounded, "Parking Spot", 
                          _upcomingReservation!.parkingSpot?.name ?? "Spot #${_upcomingReservation!.parkingSpotId}"),
                      ],
                    ),
                  )
              ] else ...[
                  const Text(
                    'Ready to Park?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find and book your parking spot in seconds.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => widget.onTileTap(1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryDark,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Book Parking Now',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
