import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:parkhere_mobile/model/parking_reservation.dart';
import 'package:parkhere_mobile/model/parking_spot.dart';
import 'package:parkhere_mobile/model/vehicle.dart';
import 'package:parkhere_mobile/providers/parking_reservation_provider.dart';
import 'package:parkhere_mobile/providers/parking_session_provider.dart';
import 'package:parkhere_mobile/providers/parking_spot_provider.dart';
import 'package:parkhere_mobile/providers/vehicle_provider.dart';
import 'package:parkhere_mobile/utils/base_textfield.dart';
import 'package:parkhere_mobile/providers/user_provider.dart';
import 'package:parkhere_mobile/utils/message_utils.dart';
import 'package:parkhere_mobile/screens/payment_screen.dart';

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
  double _totalDebt = 0;
  
  // Recommender
  ParkingSpot? _recommendedSpot;
  bool _isRecLoading = false;
  List<ParkingReservation> _allSpotReservations = [];
  List<Vehicle> _vehicles = [];
  Vehicle? _selectedVehicle;

  // Modal State
  DateTime _startTime = DateTime.now();
  int _durationHours = 2;
  int _durationMinutes = 0;
  double _debt = 0;
  
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
    _loadRecommendation();
  }
  
  Future<void> _loadRecommendation() async {
    if (!mounted) return;
    setState(() => _isRecLoading = true);
    try {
      final spot = await Provider.of<ParkingSpotProvider>(context, listen: false).recommend();
      if (spot != null) {
        // Fetch reservations for this spot to check conflicts
        final resResult = await Provider.of<ParkingReservationProvider>(context, listen: false).get(filter: {
          'parkingSpotId': spot.id,
          'excludePassed': true,
          'retrieveAll': true,
        });

        // Fetch vehicles for booking
        final userId = UserProvider.currentUser?.id;
        final vehiclesResult = await Provider.of<VehicleProvider>(context, listen: false).get(filter: {'userId': userId});

        if (mounted) {
          setState(() {
            _recommendedSpot = spot;
            _allSpotReservations = resResult.items ?? [];
            _vehicles = vehiclesResult.items ?? [];
            if (_vehicles.isNotEmpty) _selectedVehicle = _vehicles.first;
          });
        }
      }
    } catch (e) {
      debugPrint("Failed to load recommendation: $e");
    } finally {
      if (mounted) setState(() => _isRecLoading = false);
    }
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
                // Clamp active page index if list shrank
                if (_currentPage >= _dashboardReservations.length) {
                  _currentPage = (_dashboardReservations.isNotEmpty) ? _dashboardReservations.length - 1 : 0;
                  // If we specifically removed the item we were looking at, the PageView needs to jump or animate to the new valid index.
                  // However, simply updating the state variable _currentPage might be enough if PageView.builder uses it?
                  // Actually, PageView controller might be out of sync.
                  if (_pageController.hasClients) {
                     _pageController.jumpToPage(_currentPage);
                  }
                }
            });
            
            if (_dashboardReservations.isNotEmpty && !_isTimerRunning) {
                _startTimer();
            }

            // Fetch total debt
            final d = await Provider.of<ParkingReservationProvider>(context, listen: false).getDebt(userId);
            setState(() {
              _totalDebt = d;
            });
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
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
                            if (_totalDebt > 0)
                              _buildDebtIndicator(),
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
                    
                    // Recommended Section
                    if (_recommendedSpot != null) ...[
                      const Text(
                        'Recommended for You',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRecommendedCard(),
                      const SizedBox(height: 32),
                    ],
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildDashboardStatusSection() {
    if (_dashboardReservations.isEmpty) {
        return SizedBox(height: 280, child: _buildMainStatusCard(null));
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
          height: 470, 
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
                        MessageUtils.showSuccess(context, "Arrival signaled! Please wait for admin to open the ramp.");
                        _loadDashboardData(silent: true);
                    } catch (e) {
                        MessageUtils.showError(context, "Failed to signal arrival.");
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
                onPressed: () {
                    final extraCharge = _extraCharges[currentRes.id] ?? 0.0;
                    
                    // Logic: If not paid, charge (Price + Extra). If already paid, charge only Extra.
                    // But in our current flow, users always pay Everything at exit.
                    final double basePrice = currentRes.price;
                    final double totalPrice = basePrice + extraCharge;

                    debugPrint('--- EXIT PARKING DEBUG ---');
                    debugPrint('ResID: ${currentRes.id}');
                    debugPrint('BasePrice: $basePrice');
                    debugPrint('ExtraCharge: $extraCharge');
                    debugPrint('IsPaid: ${currentRes.isPaid}');
                    debugPrint('TOTAL TO PASS: $totalPrice');
                    debugPrint('--------------------------');
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentScreen(
                          reservation: currentRes,
                          totalPrice: totalPrice,
                        ),
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
                                  color: isOvertime ? Colors.redAccent : accentColor,
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
                                    res.includedDebt != null && res.includedDebt! > 0
                                        ? "PRICE: ${(res.price - res.includedDebt!).toStringAsFixed(2)} + ${res.includedDebt!.toStringAsFixed(2)} debt"
                                        : "PRICE: ${res.price.toStringAsFixed(2)} BAM",
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
                                const SizedBox(height: 12),
                                _buildStatusRow(Icons.category_rounded, "Spot Type", 
                                  (spot?.parkingSpotTypeName != null && spot!.parkingSpotTypeName.isNotEmpty) 
                                      ? spot.parkingSpotTypeName 
                                      : "Regular"),
                              ],
                            ),
                          )
                      ] else ...[
                          const SizedBox(height: 10),
                          const Text(
                            'Ready to Park?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Find and book your parking spot in seconds.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 32),
                          AppButton(
                            text: "Find Nearby Parking",
                            icon: Icons.search_rounded,
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

  Widget _buildDebtIndicator() {
    return PopupMenuButton(
      offset: const Offset(0, 50),
      color: Colors.white.withOpacity(0.9),
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), 
        side: BorderSide(color: Colors.orange.withOpacity(0.2))
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false, // Just for display
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("OUTSTANDING DEBT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Text("${_totalDebt.toStringAsFixed(2)} BAM", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
              const SizedBox(height: 4),
              const Text("From missed reservations.", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedCard() {
    final spot = _recommendedSpot!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.star_rounded, color: AppColors.primary, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spot.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                ),
                Text(
                  "${spot.parkingSectorName} • ${spot.parkingWingName}",
                  style: TextStyle(color: AppColors.textLight, fontSize: 13),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _showQuickBookModal(spot),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Quick Book", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right_rounded, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickBookModal(ParkingSpot spot) async {
    final now = DateTime.now();
    setState(() {
      _startTime = DateTime(now.year, now.month, now.day, now.hour, now.minute).add(const Duration(minutes: 15));
      _durationHours = 2;
      _durationMinutes = 0;
    });

    final userId = UserProvider.currentUser?.id;
    if (userId != null) {
      try {
        final resProvider = Provider.of<ParkingReservationProvider>(context, listen: false);
        final debtValue = await resProvider.getDebt(userId);
        setState(() => _debt = debtValue);
      } catch (_) {
        setState(() => _debt = 0);
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final calculatedEndTime = _startTime.add(Duration(hours: _durationHours, minutes: _durationMinutes));
          
          // Collision Detection
          final spotReservations = _allSpotReservations.where((r) => r.parkingSpotId == spot.id && r.endTime.isAfter(now) && r.actualEndTime == null).toList()
            ..sort((a, b) => a.startTime.compareTo(b.startTime));

          ParkingReservation? conflict;
          for (var res in spotReservations) {
            if (_startTime.isBefore(res.endTime) && calculatedEndTime.isAfter(res.startTime)) {
              conflict = res;
              break;
            }
          }

          String? reservationConflictWarning;
          if (conflict != null) {
            reservationConflictWarning = "Conflict! This spot is booked from ${DateFormat('HH:mm').format(conflict.startTime)}";
          } else {
            final nextRes = spotReservations.where((r) => r.startTime.isAfter(_startTime)).toList();
            if (nextRes.isNotEmpty) {
              final next = nextRes.first;
              final maxStayMinutes = next.startTime.difference(_startTime).inMinutes;
              if (maxStayMinutes < (_durationHours * 60 + _durationMinutes)) {
                reservationConflictWarning = "Max stay available: ${maxStayMinutes ~/ 60}h ${maxStayMinutes % 60}m";
              }
            }
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                      child: const Icon(Icons.local_parking_rounded, color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(spot.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text("${spot.parkingSectorName} • ${spot.parkingWingName}", 
                            style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (spotReservations.isNotEmpty) ...[
                  const Text("Upcoming Schedule", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: spotReservations.length,
                      itemBuilder: (context, index) {
                        final res = spotReservations[index];
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey[300]!)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("${DateFormat('HH:mm').format(res.startTime)} - ${DateFormat('HH:mm').format(res.endTime)}", 
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      }
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Select Start Time", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: AppButton(
                              text: DateFormat('HH:mm').format(_startTime),
                              onPressed: () async {
                                final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_startTime));
                                if (time != null) {
                                  setModalState(() => _startTime = DateTime(_startTime.year, _startTime.month, _startTime.day, time.hour, time.minute));
                                }
                              },
                            )),
                            const SizedBox(width: 8),
                            Expanded(child: AppButton(
                              text: DateFormat('MMM d, yyyy').format(_startTime),
                              onPressed: () async {
                                final date = await showDatePicker(context: context, initialDate: _startTime, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 7)));
                                if (date != null) {
                                  setModalState(() => _startTime = DateTime(date.year, date.month, date.day, _startTime.hour, _startTime.minute));
                                }
                              },
                            )),
                          ],
                        ),
                        const SizedBox(height: 20),

                        const Text("Select Duration", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: DropdownButtonFormField<int>(
                              value: _durationHours,
                              decoration: const InputDecoration(labelText: "Hours"),
                              items: List.generate(24, (i) => DropdownMenuItem(value: i, child: Text("$i h"))),
                              onChanged: (v) => setModalState(() => _durationHours = v!),
                            )),
                            const SizedBox(width: 8),
                            Expanded(child: DropdownButtonFormField<int>(
                              value: _durationMinutes,
                              decoration: const InputDecoration(labelText: "Minutes"),
                              items: [0, 15, 30, 45].map((m) => DropdownMenuItem(value: m, child: Text("$m min"))).toList(),
                              onChanged: (v) => setModalState(() => _durationMinutes = v!),
                            )),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text("Ends at: ${DateFormat('HH:mm, MMM d').format(calculatedEndTime)}",
                          style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                        
                        if (reservationConflictWarning != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(reservationConflictWarning!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),

                        const SizedBox(height: 24),
                        const Text("Vehicle", style: TextStyle(fontWeight: FontWeight.bold)),
                        DropdownButtonFormField<Vehicle>(
                          value: _selectedVehicle,
                          items: _vehicles.map((v) => DropdownMenuItem(value: v, child: Text("${v.name} (${v.licensePlate})"))).toList(),
                          onChanged: (v) => setModalState(() => _selectedVehicle = v),
                          decoration: const InputDecoration(hintText: "Select your vehicle"),
                        ),

                        if (_debt > 0) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.orange.withOpacity(0.3))),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                                const SizedBox(width: 12),
                                Expanded(child: Text("You have ${_debt.toStringAsFixed(2)} BAM in unpaid debt from missed reservations. This will be added to your booking price.", style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold))),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                AppButton(
                  text: "BOOK NOW",
                  onPressed: (conflict != null || _selectedVehicle == null) ? null : () => _handleQuickBooking(spot),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Future<void> _handleQuickBooking(ParkingSpot spot) async {
    final endTime = _startTime.add(Duration(hours: _durationHours, minutes: _durationMinutes));
    
    MessageUtils.showConfirmationDialog(
      context, 
      "Confirm Booking", 
      "Are you sure you want to book ${spot.name} from ${DateFormat('HH:mm').format(_startTime)} to ${DateFormat('HH:mm').format(endTime)}?",
      () async {
        showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));

        try {
          final userId = UserProvider.currentUser?.id;
          if (userId == null) {
            Navigator.pop(context);
            return;
          }

          await Provider.of<ParkingReservationProvider>(context, listen: false).insert({
            'userId': userId,
            'vehicleId': _selectedVehicle!.id,
            'parkingSpotId': spot.id,
            'startTime': _startTime.toIso8601String(),
            'endTime': endTime.toIso8601String(),
            'isPaid': false,
          });

          if (mounted) {
            Navigator.pop(context); // Pop loading
            Navigator.pop(context); // Pop modal
            
            MessageUtils.showSuccessDialog(
              context, 
              'Parking spot sucsessufly booked',
              () {
                _loadDashboardData();
                _loadRecommendation();
              }
            );
          }
        } catch (e) {
          if (mounted) {
            Navigator.pop(context);
            MessageUtils.showError(context, 'Booking failed. Please try again.');
          }
        }
      }
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
