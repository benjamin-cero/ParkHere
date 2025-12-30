import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parkhere_mobile/model/parking_reservation.dart';
import 'package:parkhere_mobile/providers/parking_reservation_provider.dart';
import 'package:parkhere_mobile/providers/user_provider.dart';
import 'package:parkhere_mobile/utils/base_textfield.dart';
import 'package:intl/intl.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  List<ParkingReservation> _reservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    final userId = UserProvider.currentUser?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<ParkingReservationProvider>(context, listen: false);
      final result = await provider.get(filter: {'userId': userId});
      if (mounted) {
        setState(() {
          _reservations = result.items ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getStatus(ParkingReservation res) {
    if (res.actualEndTime != null) return "Completed";
    if (res.actualStartTime != null) return "Active";
    if (DateTime.now().isAfter(res.endTime)) return "Expired";
    return "Upcoming";
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Active": return AppColors.primary;
      case "Completed": return Colors.grey;
      case "Expired": return AppColors.error;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Bookings',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                      ),
                      Text('Manage your parking sessions', style: TextStyle(color: AppColors.textLight)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _loadReservations,
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _reservations.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadReservations,
                        color: AppColors.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: _reservations.length,
                          itemBuilder: (context, index) => _buildReservationCard(_reservations[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_rounded, size: 80, color: AppColors.primary.withOpacity(0.1)),
          const SizedBox(height: 24),
          const Text("No bookings yet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
          const SizedBox(height: 8),
          const Text("Explore spots to make your first reservation!", style: TextStyle(color: AppColors.textLight)),
        ],
      ),
    );
  }

  Widget _buildReservationCard(ParkingReservation res) {
    final status = _getStatus(res);
    final statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                  child: Icon(Icons.local_parking_rounded, color: statusColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        res.parkingSpot?.name ?? "Spot #${res.parkingSpotId}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.primaryDark),
                      ),
                      Text(
                        "${res.vehicle?.name ?? 'Vehicle'} • ${res.vehicle?.licensePlate ?? ''}",
                        style: const TextStyle(fontSize: 13, color: AppColors.textLight),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn("Date", DateFormat('MMM dd, y').format(res.startTime)),
                _buildInfoColumn("Time", "${DateFormat('HH:mm').format(res.startTime)} - ${DateFormat('HH:mm').format(res.endTime)}"),
                _buildInfoColumn("Price", "${res.price.toStringAsFixed(2)} BAM"),
              ],
            ),
            if (status == "Active" || status == "Upcoming") ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {}, // TODO: Implement Change Vehicle (if not active)
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                      ),
                      child: const Text("Manage", style: TextStyle(color: AppColors.primary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {}, // TODO: Implement Extend
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text("Extend"),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textLight, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
      ],
    );
  }
}
