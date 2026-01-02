import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:parkhere_mobile/model/parking_reservation.dart';
import 'package:parkhere_mobile/providers/parking_reservation_provider.dart';
import 'package:parkhere_mobile/providers/parking_session_provider.dart';
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
  List<ParkingReservation> _dashboardReservations = []; // All active/pending reservations
  Map<int, String> _reservationTimers = {}; // Map of reservation ID to its countdown string
  Map<int, double> _extraCharges = {};
  Map<int, bool> _isOvertime = {};
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isTimerRunning = false;
  
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
  
  Future<void> _loadDashboardData({bool silent = false}) async {
      try {
          if (!silent && mounted) setState(() => _isLoading = true);
          final userId = UserProvider.currentUser?.id;
          if (userId == null) return;
          
          final result = await Provider.of<ParkingReservationProvider>(context, listen: false).get(filter: {
            'userId': userId,
            'excludePassed': false,
            'retrieveAll': true,
          });
          
          final now = DateTime.now();
          final allReservations = result.items ?? [];
          
          // Identify all active or future reservations
          List<ParkingReservation> activeAndPending = allReservations.where((r) {
            bool isArrived = r.actualStartTime != null && r.actualEndTime == null;
            bool isPending = r.actualStartTime == null && r.endTime.isAfter(now);
            return isArrived || isPending;
          }).toList();

          // Sort: Arrived first, then nearest Pending
          activeAndPending.sort((a, b) {
            bool aArrived = a.actualStartTime != null;
            bool bArrived = b.actualStartTime != null;
            if (aArrived && !bArrived) return -1;
            if (!aArrived && bArrived) return 1;
            return a.startTime.compareTo(b.startTime);
          });
          
          if (mounted) {
            setState(() {
                _dashboardReservations = activeAndPending;
            });
            
            if (_dashboardReservations.isNotEmpty && !_isTimerRunning) {
                _startTimer();
            }
          }
      } catch (e) {
          debugPrint("Failed to load dashboard data: $e");
      } finally {
          if (mounted) {
            setState(() => _isLoading = false);
          }
      }
  }
  
  void _startTimer() {
      _isTimerRunning = true;
      int refreshCounter = 0;
      Future.doWhile(() async {
          if (!mounted || _dashboardReservations.isEmpty) {
              _isTimerRunning = false;
              return false;
          }
          
          final now = DateTime.now();
          Map<int, String> newTimers = {};
          Map<int, double> newExtraCharges = {};
          Map<int, bool> newIsOvertime = {};
          
          bool anyExpired = false;

          refreshCounter++;
          if (refreshCounter >= 10) { // Refresh data silently every 10 seconds
              refreshCounter = 0;
              await _loadDashboardData(silent: true);
          }

          for (var res in _dashboardReservations) {
            final start = res.startTime;
            final end = res.endTime;
            final isArrived = res.actualStartTime != null;

            if (isArrived) {
                final diff = end.difference(now);
                if (diff.isNegative) {
                    // Overtime logic
                    final overtime = -diff;
                    newTimers[res.id] = "+ ${_formatDuration(overtime)}";
                    newIsOvertime[res.id] = true;
                    
                    // Calculate extra charge
                    // Formula: (BaseRate * Multiplier / 60) * 1.5 * Minutes
                    // BaseRate = 3.0
                    final multiplier = res.parkingSpot?.priceMultiplier ?? 1.0;
                    final penaltyRatePerMinute = (3.0 * multiplier / 60.0) * 1.5;
                    newExtraCharges[res.id] = overtime.inMinutes * penaltyRatePerMinute;
                    
                } else {
                    newTimers[res.id] = _formatDuration(diff);
                    newIsOvertime[res.id] = false;
                    newExtraCharges[res.id] = 0.0;
                }
            } else {
                final startDiff = start.difference(now);
                if (startDiff.isNegative) {
                    final endDiff = end.difference(now);
                    if (endDiff.isNegative) {
                        anyExpired = true;
                        newTimers[res.id] = "00:00:00";
                    } else {
                        newTimers[res.id] = _formatDuration(endDiff);
                    }
                } else {
                    newTimers[res.id] = _formatCountdown(startDiff);
                }
            }
          }

          if (mounted) {
            setState(() {
              _reservationTimers = newTimers;
              _extraCharges = newExtraCharges;
              _isOvertime = newIsOvertime;
            });
          }

          if (anyExpired) {
            await Future.delayed(const Duration(seconds: 2));
            _loadDashboardData();
            // Don't stop timer if there are other active reservations
             if (_dashboardReservations.isEmpty) {
                _isTimerRunning = false;
                return false;
             }
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
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
      ),
      child: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                              '${UserProvider.currentUser?.firstName ?? "Guest"}!',
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
                    
                    // Status Section with PageView
                    _buildDashboardStatusSection(),
                    
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
                          subtitle: 'Book near you',
                          color: AppColors.primary,
                          onTap: () => widget.onTileTap(1),
                        ),
                        _buildActionCard(
                          icon: Icons.history_rounded,
                          title: 'My Bookings',
                          subtitle: 'View history',
                          color: AppColors.primaryLight,
                          onTap: () => widget.onTileTap(2),
                        ),
                        _buildActionCard(
                          icon: Icons.directions_car_rounded,
                          title: 'Vehicles',
                          subtitle: 'Manage fleet',
                          color: Colors.orange,
                          onTap: () => widget.onTileTap(3),
                        ),
                        _buildActionCard(
                          icon: Icons.person_rounded,
                          title: 'Profile',
                          subtitle: 'Your settings',
                          color: Colors.blueAccent,
                          onTap: () => widget.onTileTap(4),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildDashboardStatusSection() {
    if (_dashboardReservations.isEmpty) {
        return SizedBox(height: 440, child: _buildMainStatusCard(null));
    }

    final currentRes = _dashboardReservations[_currentPage];
    final now = DateTime.now();
    final diff = currentRes.startTime.difference(now).inMinutes;
    // Enabled 30 minutes before start time
    final isTimeForArrival = diff <= 30; 
    final isSignaled = currentRes.arrivalTime != null;
    final isActive = currentRes.actualStartTime != null;

    return Column(
      children: [
        SizedBox(
          height: 440, 
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _dashboardReservations.length,
            itemBuilder: (context, index) => _buildMainStatusCard(_dashboardReservations[index]),
          ),
        ),
        if (!isActive) ...[
          if (!isSignaled) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AppButton(
                text: isTimeForArrival ? "SIGNAL ARRIVAL" : "LOCKED",
                icon: isTimeForArrival ? Icons.campaign_rounded : Icons.lock_outline,
                onPressed: isTimeForArrival ? () async {
                    try {
                        await context.read<ParkingSessionProvider>().registerArrival(currentRes.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Arrival signaled! Please wait for admin to open the ramp."), backgroundColor: AppColors.primary)
                        );
                        _loadDashboardData(silent: true);
                    } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Failed to signal arrival."), backgroundColor: AppColors.error)
                        );
                    }
                } : null,
              ),
            ),
            if (!isTimeForArrival)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "Button unlocks 30 mins before your time",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
          ] else ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text("Arrival Signaled - Waiting for Admin", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ] else ...[
             const SizedBox(height: 16),
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AppButton(
                text: "EXIT PARKING",
                icon: Icons.exit_to_app_rounded,
                backgroundColor: Colors.redAccent,
                onPressed: () async {
                     showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Exit Parking"),
                        content: const Text("Are you sure you want to end your parking session and exit?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                            onPressed: () async {
                              Navigator.pop(context); // Close dialog
                              try {
                                  await context.read<ParkingSessionProvider>().setActualEndTime(currentRes.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("You have exited the parking."), backgroundColor: Colors.green)
                                  );
                                  _loadDashboardData();
                              } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Failed to exit parking."), backgroundColor: AppColors.error)
                                  );
                              }
                            },
                            child: const Text("Yes, Exit", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                },
              ),
            ),
        ],
        if (_dashboardReservations.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_dashboardReservations.length, (index) {
                bool isSelected = _currentPage == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: isSelected ? 24 : 8,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildMainStatusCard(ParkingReservation? res) {
    final hasReservation = res != null;
    final isArrived = hasReservation && res.actualStartTime != null;
    final isPending = hasReservation && res.actualStartTime == null;
    final accentColor = isArrived ? Colors.green : (isPending ? const Color(0xFFFFEE58) : Colors.white);
    final timerText = hasReservation ? (_reservationTimers[res.id] ?? "--:--:--") : "";
    final spot = res?.parkingSpot;
    
    final isOvertime = hasReservation ? (_isOvertime[res.id] ?? false) : false;
    final extraCharge = hasReservation ? (_extraCharges[res.id] ?? 0.0) : 0.0;
    
    // For timer color: Red if overtime, otherwise existing logic
    final timerColor = isOvertime ? Colors.redAccent : Colors.white;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: AppGradients.mainBackground,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withOpacity(0.35),
                blurRadius: 25,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                Positioned(top: -50, right: -50, child: CircleAvatar(radius: 100, backgroundColor: Colors.white.withOpacity(0.05))),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
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
                              if (hasReservation && res.vehicle != null) ...[
                                const SizedBox(width: 12),
                                Text(
                                  res.vehicle!.licensePlate,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isOvertime ? Colors.redAccent.withOpacity(0.2) : Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isOvertime ? Colors.redAccent : Colors.white.withOpacity(0.2)),
                            ),
                            child: Text(
                              isArrived ? (isOvertime ? 'OVERTIME' : 'SESSION ACTIVE') : (isPending ? 'PENDING' : 'READY TO PARK'),
                              style: TextStyle(
                                color: isOvertime ? Colors.redAccent : (hasReservation ? accentColor : Colors.white),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      if (hasReservation) ...[
                          Text(
                            timerText,
                            style: TextStyle(
                              color: timerColor,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isOvertime 
                              ? "Overtime duration"
                              : ((isArrived || DateTime.now().isAfter(res.startTime)) ? "Remaining time" : "Countdown to your booking"),
                            style: TextStyle(color: isOvertime ? Colors.redAccent : Colors.white.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(
                                    "PRICE: ${res.price.toStringAsFixed(2)} BAM",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                                if (isOvertime && extraCharge > 0) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(color: Colors.redAccent),
                                      ),
                                      child: Text(
                                        "+ ${extraCharge.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                ]
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                _buildStatusRow(
                                  Icons.calendar_today_rounded, 
                                  isArrived ? "Actual Entry" : "Booking Date", 
                                  isArrived 
                                    ? DateFormat('HH:mm, MMM d').format(res.actualStartTime!)
                                    : DateFormat('EEEE, MMM d').format(res.startTime)
                                ),
                                const SizedBox(height: 12),
                                _buildStatusRow(Icons.access_time_rounded, "Time Window", 
                                  "${DateFormat('HH:mm').format(isArrived ? res.actualStartTime! : res.startTime)} - ${DateFormat('HH:mm').format(res.endTime)}"),
                                const SizedBox(height: 12),
                                _buildStatusRow(Icons.local_parking_rounded, "Parking Spot", 
                                  spot?.name ?? "Spot #${res.parkingSpotId}"),
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
                          const SizedBox(height: 12),
                          Text(
                            'Find and book your parking spot in seconds.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 15,
                            ),
                          ),
                          const Spacer(),
                          AppButton(
                            text: "Find Nearby Parking",
                            onPressed: () => widget.onTileTap(1),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
