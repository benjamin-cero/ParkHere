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
      onBack: () => Navigator.of(context).pop(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Hero Header
            SizedBox(
              height: 220,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    height: 160,
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
                          top: -20,
                          right: -20,
                          child: Icon(Icons.event_available_rounded, size: 180, color: Colors.white.withOpacity(0.05)),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: Icon(Icons.receipt_long_rounded, size: 60, color: const Color(0xFF1E3A8A)),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 2. Reservation Title
            Text(
              "${reservation.user?.firstName} ${reservation.user?.lastName}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: reservation.isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                reservation.isPaid ? "Paid" : "Unpaid",
                style: TextStyle(
                  color: reservation.isPaid ? const Color(0xFF166534) : const Color(0xFF92400E),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 32),

            // 3. Information Content
            Container(
              constraints: const BoxConstraints(maxWidth: 800),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                   // Quick Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildSmallStat(
                          icon: Icons.timer_outlined,
                          label: "Duration",
                          value: durationStr,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSmallStat(
                          icon: Icons.payments_outlined,
                          label: "Total Price",
                          value: "${reservation.price.toStringAsFixed(2)} BAM",
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader("Planned Schedule"),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoTile(
                          icon: Icons.login_rounded,
                          label: "Expected Arrival",
                          value: DateFormat('dd.MM.yyyy HH:mm').format(reservation.startTime),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoTile(
                          icon: Icons.logout_rounded,
                          label: "Expected Departure",
                          value: DateFormat('dd.MM.yyyy HH:mm').format(reservation.endTime),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader("Actual Session"),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoTile(
                          icon: Icons.access_time_filled_rounded,
                          label: "Actual Entry",
                          value: reservation.actualStartTime != null 
                              ? DateFormat('dd.MM.yyyy HH:mm').format(reservation.actualStartTime!) 
                              : "Pending Arrival",
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoTile(
                          icon: Icons.history_rounded,
                          label: "Actual Exit",
                          value: reservation.actualEndTime != null 
                              ? DateFormat('dd.MM.yyyy HH:mm').format(reservation.actualEndTime!) 
                              : "Pending Departure",
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader("Parking Location"),
                  const SizedBox(height: 16),
                  
                  _buildInfoTile(
                    icon: Icons.map_outlined,
                    label: "Sector",
                    value: reservation.parkingSpot?.parkingWing?.parkingSectorName ?? "N/A",
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoTile(
                          icon: Icons.grid_view_rounded,
                          label: "Wing",
                          value: reservation.parkingSpot?.parkingWing?.name ?? "N/A",
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoTile(
                          icon: Icons.pin_drop_outlined,
                          label: "Spot Code",
                          value: reservation.parkingSpot?.spotCode ?? "N/A",
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(color: const Color(0xFF1E3A8A), borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
      ],
    );
  }

  Widget _buildSmallStat({required IconData icon, required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1F2937))),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
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
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: const Color(0xFF1E3A8A), size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: Color(0xFF1F2937), fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
