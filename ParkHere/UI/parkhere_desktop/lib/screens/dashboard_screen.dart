import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parkhere_desktop/layouts/master_screen.dart';
import 'package:parkhere_desktop/model/parking_reservation.dart';
import 'package:parkhere_desktop/model/search_result.dart';
import 'package:parkhere_desktop/providers/parking_reservation_provider.dart';
import 'package:parkhere_desktop/providers/parking_session_provider.dart';
import 'package:parkhere_desktop/utils/base_dialog.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late ParkingReservationProvider _reservationProvider;
  late ParkingSessionProvider _sessionProvider;
  bool _isLoading = true;
  SearchResult<ParkingReservation>? _arrivals;
  Timer? _refreshTimer;

  int _activeCount = 0;
  int _pendingCount = 0;
  double _todayRevenue = 0;

  @override
  void initState() {
    super.initState();
    _reservationProvider = context.read<ParkingReservationProvider>();
    _sessionProvider = context.read<ParkingSessionProvider>();
    _loadDashboardData();
    // Refresh every 10 seconds for "live" feel
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _loadDashboardData(silent: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDashboardData({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    try {
      // 1. Fetch pending arrivals (arrivalTime != null, actualStartTime == null)
      // Note: We might need a custom search object if the backend doesn't support this filter directly,
      // but for now we'll fetch all and filter client-side for the demo, or use existing filters.
      final result = await _reservationProvider.get(filter: {
        "includeUser": true,
        "includeVehicle": true,
        "includeParkingSpot": true,
        "includeParkingSession": true,
        "excludePassed": true,
      });

      if (mounted) {
        setState(() {
          // Filter all upcoming reservations (actualStartTime == null) and SORT BY startTime (earliest first)
          final filteredItems = result.items?.where((r) => r.actualStartTime == null).toList() ?? [];
          
          filteredItems.sort((a, b) => a.startTime.compareTo(b.startTime));

          _arrivals = SearchResult<ParkingReservation>()
            ..items = filteredItems
            ..totalCount = filteredItems.length;

          // Calculate stats
          _activeCount = result.items?.where((r) => r.actualStartTime != null && r.actualEndTime == null).length ?? 0;
          _pendingCount = _arrivals?.items?.length ?? 0;
          
          // Revenue today (simplified calculation based on paid reservations created today)
          final today = DateTime.now();
          _todayRevenue = result.items?.where((r) => 
            r.isPaid && 
            r.createdAt.year == today.year && 
            r.createdAt.month == today.month && 
            r.createdAt.day == today.day
          ).fold(0.0, (sum, r) => sum! + r.price) ?? 0;

          _isLoading = false;
        });
      }
    } catch (e) {
      print("Dashboard Error: $e");
      if (mounted && !silent) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading dashboard: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _approveEntry(ParkingReservation res) async {
    bool? confirm = await BaseDialog.show(
      context: context,
      title: "Approve Entry",
      message: "Are you sure you want to approve entry for ${res.user?.firstName} ${res.user?.lastName} (${res.vehicle?.licensePlate})?",
      type: BaseDialogType.confirmation,
      confirmLabel: "Approve",
    );

    if (confirm == true) {
      try {
        await _sessionProvider.approveEntry(res.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Entry approved successfully"), backgroundColor: Colors.green));
          _loadDashboardData();
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Dashboard",
      child: _isLoading && _arrivals == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderInfo(),
                  const SizedBox(height: 32),
                  _buildStatsRow(),
                  const SizedBox(height: 48),
                  _buildArrivalsHeader(),
                  const SizedBox(height: 16),
                  _buildArrivalsFeed(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome back, Admin!",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          "Here is what's happening at ParkHere today.",
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard(
          "Active Sessions",
          _activeCount.toString(),
          Icons.local_parking_rounded,
          const Color(0xFF3B82F6),
        ),
        const SizedBox(width: 24),
        _buildStatCard(
          "Pending Approvals",
          _pendingCount.toString(),
          Icons.pending_actions_rounded,
          const Color(0xFFF59E0B),
        ),
        const SizedBox(width: 24),
        _buildStatCard(
          "Today's Revenue",
          "${_todayRevenue.toStringAsFixed(2)} KM",
          Icons.payments_rounded,
          const Color(0xFF10B981),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrivalsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.sensors_rounded, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            const Text(
              "Live Arrival Feed",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(width: 12),
            if (_pendingCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$_pendingCount NEW",
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        TextButton.icon(
          onPressed: () => _loadDashboardData(),
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text("Refresh Feed"),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF3B82F6)),
        ),
      ],
    );
  }

  Widget _buildArrivalsFeed() {
    if (_arrivals == null || _arrivals!.items == null || _arrivals!.items!.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(60),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "No pending arrival requests",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[400]),
            ),
            const SizedBox(height: 8),
            Text(
              "All clear! The ramp is closed and waiting for the next guest.",
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _arrivals!.items!.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final res = _arrivals!.items![index];
        return _buildArrivalCard(res);
      },
    );
  }

  Widget _buildArrivalCard(ParkingReservation res) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // User Avatar
          _buildUserAvatar(res),
          const SizedBox(width: 20),
          
          // User & Vehicle Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${res.user?.firstName} ${res.user?.lastName}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.directions_car_rounded, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Text(
                      res.vehicle?.licensePlate ?? "Unknown Vehicle",
                      style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.local_parking_rounded, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Text(
                      "Spot ${res.parkingSpot?.spotCode}",
                      style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Price: ${res.price.toStringAsFixed(2)} BAM",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981), fontSize: 13),
                ),
              ],
            ),
          ),
          
          // Arrival / Expected Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                res.arrivalTime != null ? "Arrived at" : "Expected at",
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                res.arrivalTime != null 
                    ? DateFormat('HH:mm').format(res.arrivalTime!)
                    : DateFormat('MMM dd, HH:mm').format(res.startTime),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3B82F6)),
              ),
            ],
          ),
          
          const SizedBox(width: 32),
          
          // Action Buttons
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: res.arrivalTime != null ? () => _approveEntry(res) : null,
                icon: Icon(res.arrivalTime != null ? Icons.login_rounded : Icons.lock_rounded, size: 18),
                label: Text(
                  res.arrivalTime != null ? "APPROVE ENTRY" : "WAITING FOR USER", 
                  style: const TextStyle(fontWeight: FontWeight.bold)
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: res.arrivalTime != null ? const Color(0xFF10B981) : Colors.red[400], // Green vs Red
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.red[300]?.withOpacity(0.6),
                  disabledForegroundColor: Colors.white.withOpacity(0.8),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(ParkingReservation res) {
    // Basic initials if no image
    return CircleAvatar(
      radius: 28,
      backgroundColor: const Color(0xFFE5E7EB),
      child: Text(
        "${res.user?.firstName?[0]}${res.user?.lastName?[0]}",
        style: const TextStyle(color: Color(0xFF4B5563), fontWeight: FontWeight.bold),
      ),
    );
  }
}
