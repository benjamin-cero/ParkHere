import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parkhere_desktop/layouts/master_screen.dart';
import 'package:parkhere_desktop/model/parking_reservation.dart';

class ReservationDetailsScreen extends StatelessWidget {
  final ParkingReservation reservation;

  const ReservationDetailsScreen({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    final duration = reservation.endTime.difference(reservation.startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final durationStr = "${hours}h ${minutes}m";

    return MasterScreen(
      title: 'Reservation Details',
      showBackButton: true,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // Hero Header
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 20,
                        right: 20,
                        child: Icon(
                          Icons.circle,
                          size: 180,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      const Center(
                        child: Icon(
                          Icons.event_available_rounded,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Reservation Summary: User and Vehicle
            Text(
              "${reservation.user?.firstName} ${reservation.user?.lastName}",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 1),
            Text(
              "${reservation.user?.email}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Text(
                reservation.vehicle?.licensePlate ?? "N/A License Plate",
                style: const TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Content Area
            Container(
              constraints: const BoxConstraints(maxWidth: 800),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Quick Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickStat(
                        icon: Icons.timer_outlined,
                        label: durationStr,
                        value: "Duration",
                        color: Colors.blue,
                      ),
                      _buildQuickStat(
                        icon: Icons.payments_outlined,
                        label: "${reservation.price.toStringAsFixed(2)} BAM",
                        value: "Price",
                        color: Colors.green,
                      ),
                      _buildQuickStat(
                        icon: Icons.info_outline,
                        label: reservation.isPaid ? "Paid" : "Unpaid",
                        value: "Status",
                        color: reservation.isPaid ? Colors.green : Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Information Sections: Planned Timing
                  _buildSectionHeader("Planned Timing"),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoTile(
                          icon: Icons.login_rounded,
                          label: "Start Time",
                          value: DateFormat('dd.MM.yyyy HH:mm').format(reservation.startTime),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoTile(
                          icon: Icons.logout_rounded,
                          label: "End Time",
                          value: DateFormat('dd.MM.yyyy HH:mm').format(reservation.endTime),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Information Sections: Actual Timing
                  _buildSectionHeader("Actual Timing"),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoTile(
                          icon: Icons.access_time_filled_rounded,
                          label: "Actual Start",
                          value: reservation.actualStartTime != null 
                              ? DateFormat('dd.MM.yyyy HH:mm').format(reservation.actualStartTime!) 
                              : "Not set",
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoTile(
                          icon: Icons.history_rounded,
                          label: "Actual End",
                          value: reservation.actualEndTime != null 
                              ? DateFormat('dd.MM.yyyy HH:mm').format(reservation.actualEndTime!) 
                              : "Not set",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  _buildSectionHeader("Parking Location Detail"),
                  const SizedBox(height: 16),
                  _buildInfoTile(
                    icon: Icons.map_outlined,
                    label: "Sector",
                    value: reservation.parkingSpot?.parkingWing?.parkingSectorName ?? "N/A",
                  ),
                  _buildInfoTile(
                    icon: Icons.grid_view_rounded,
                    label: "Wing",
                    value: reservation.parkingSpot?.parkingWing?.name ?? "N/A",
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoTile(
                          icon: Icons.pin_drop_outlined,
                          label: "Spot",
                          value: reservation.parkingSpot?.spotCode ?? "N/A",
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoTile(
                          icon: Icons.category_outlined,
                          label: "Spot Type",
                          value: reservation.parkingSpot?.parkingSpotType?.type ?? "N/A",
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat({required IconData icon, required String label, required String value, required Color color}) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(value, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile({required IconData icon, required String label, required String value}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF4B5563), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: Color(0xFF1F2937), fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
