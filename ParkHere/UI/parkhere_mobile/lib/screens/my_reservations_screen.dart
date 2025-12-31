import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parkhere_mobile/model/parking_reservation.dart';
import 'package:parkhere_mobile/model/vehicle.dart';
import 'package:parkhere_mobile/providers/parking_reservation_provider.dart';
import 'package:parkhere_mobile/providers/user_provider.dart';
import 'package:parkhere_mobile/providers/vehicle_provider.dart';
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
  List<Vehicle> _userVehicles = [];
  String _selectedFilter = "Pending";

  @override
  void initState() {
    super.initState();
    _loadReservations();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    final userId = UserProvider.currentUser?.id;
    if (userId == null) return;
    try {
      final provider = Provider.of<VehicleProvider>(context, listen: false);
      final result = await provider.get(filter: {'userId': userId});
      if (mounted) setState(() => _userVehicles = result.items ?? []);
    } catch (_) {}
  }

  Future<void> _loadReservations() async {
    final userId = UserProvider.currentUser?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<ParkingReservationProvider>(context, listen: false);
      final result = await provider.get(filter: {
        'userId': userId,
        'excludePassed': false, // We want to see history too in this screen
        'retrieveAll': true,
      });
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
    if (res.actualStartTime != null) return "Arrived";
    return "Pending";
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Arrived": return AppColors.occupied; // Red
      case "Completed": return Colors.grey;
      case "Pending": return AppColors.reserved; // Yellow
      default: return Colors.orange;
    }
  }

  void _showEditModal(ParkingReservation res) {
    final now = DateTime.now();
    if (res.startTime.difference(now).inMinutes < 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot edit reservation less than 30 minutes before arrival."),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    DateTime editStartTime = res.startTime;
    int editDurationHours = res.endTime.difference(res.startTime).inHours;
    int editDurationMinutes = res.endTime.difference(res.startTime).inMinutes % 60;
    Vehicle? editVehicle = _userVehicles.firstWhere((v) => v.id == res.vehicleId, orElse: () => _userVehicles.first);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final calculatedEndTime = editStartTime.add(Duration(hours: editDurationHours, minutes: editDurationMinutes));
          
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
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
                const Text("Edit Booking", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                const SizedBox(height: 24),
                
                const Text("Select Vehicle", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Vehicle>(
                      value: _userVehicles.any((v) => v.id == editVehicle?.id) ? editVehicle : null,
                      isExpanded: true,
                      items: _userVehicles.map((v) => DropdownMenuItem(value: v, child: Text("${v.name} (${v.licensePlate})"))).toList(),
                      onChanged: (v) => setModalState(() => editVehicle = v),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text("Arrival Date & Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: editStartTime,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (pickedDate != null) {
                      final TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(editStartTime));
                      if (pickedTime != null) {
                        setModalState(() {
                          editStartTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
                        });
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[200]!)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('MMM d, yyyy  •  hh:mm a').format(editStartTime), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text("Duration", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildDurationInput("Hours", editDurationHours, (v) => setModalState(() => editDurationHours = v))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDurationInput("Minutes", editDurationMinutes, (v) => setModalState(() => editDurationMinutes = v))),
                  ],
                ),
                const SizedBox(height: 20),
                Text("Calculated Leaving: ${DateFormat('hh:mm a').format(calculatedEndTime)}", 
                  style: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold, fontSize: 13)),

                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: AppButton(
                    text: "Save Changes",
                    onPressed: () async {
                      try {
                        final provider = Provider.of<ParkingReservationProvider>(context, listen: false);
                        await provider.update(res.id, {
                          'vehicleId': editVehicle!.id,
                          'startTime': editStartTime.toIso8601String(),
                          'endTime': calculatedEndTime.toIso8601String(),
                        });
                        if (mounted) {
                          Navigator.pop(context);
                          _loadReservations();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reservation updated!"), backgroundColor: AppColors.primary));
                        }
                      } catch (_) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to update"), backgroundColor: AppColors.error));
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleCancel(ParkingReservation res) {
    final now = DateTime.now();
    if (res.startTime.difference(now).inMinutes < 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot cancel reservation less than 30 minutes before arrival."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Booking"),
        content: const Text("Are you sure you want to cancel this reservation? This action cannot be undone."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Keep Booking", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final provider = Provider.of<ParkingReservationProvider>(context, listen: false);
                await provider.delete(res.id);
                if (mounted) {
                  Navigator.pop(context);
                  _loadReservations();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Reservation cancelled successfully"), backgroundColor: Colors.redAccent),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to cancel reservation"), backgroundColor: Colors.redAccent),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Yes, Cancel"),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationInput(String label, int value, Function(int) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[200]!)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              Text("$value", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          Column(
            children: [
              GestureDetector(onTap: () => onChanged(value + (label == "Hours" ? 1 : 15)), child: const Icon(Icons.arrow_drop_up, size: 20)),
              GestureDetector(onTap: () { if (value > 0) onChanged(value - (label == "Hours" ? 1 : 15)); }, child: const Icon(Icons.arrow_drop_down, size: 20)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter and sort reservations
    final filtered = _reservations.where((r) {
      final status = _getStatus(r);
      return status == _selectedFilter;
    }).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));

    // For "Completed", we might want newest first
    final displayList = _selectedFilter == "Completed" ? filtered.reversed.toList() : filtered;

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : displayList.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        itemCount: displayList.length,
                        itemBuilder: (context, index) => _buildReservationCard(displayList[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(ParkingReservation res) {
    final status = _getStatus(res);
    final statusColor = _getStatusColor(status);
    final now = DateTime.now();
    
    // Only allow editing in Pending tab, and if more than 30 mins away
    final isPending = status == "Pending";
    final isArrived = status == "Arrived";
    final canEdit = isPending && res.startTime.difference(now).inMinutes > 30;
    
    final spot = res.parkingSpot;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          // Card Header with status color
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Icon(Icons.local_parking_rounded, color: statusColor, size: 20),
                const SizedBox(width: 12),
                Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.1)),
                const Spacer(),
                Text(DateFormat('MMM dd, yyyy').format(res.startTime), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            spot?.name ?? "Spot #${res.parkingSpotId}", 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.primaryDark)
                          ),
                          const SizedBox(height: 4),
                          if (spot != null)
                             Text(
                              "${spot.parkingSectorName} • ${spot.parkingWingName}", 
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)
                            ),
                          const SizedBox(height: 4),
                          Text(
                            "${res.vehicle?.name ?? 'Vehicle'} • ${res.vehicle?.licensePlate ?? ''}", 
                            style: const TextStyle(fontSize: 14, color: AppColors.textLight)
                          ),
                        ],
                      ),
                    ),
                    Text("${res.price.toStringAsFixed(2)} BAM",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                  ],
                ),
                const Divider(height: 40),
                
                // Spot Details Tag
                if (spot != null) ...[
                   Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: _buildMiniInfo(Icons.category_rounded, spot.parkingSpotTypeName, false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn("Arrival", DateFormat('HH:mm').format(res.startTime), false),
                    _buildInfoColumn("Departure", DateFormat('HH:mm').format(res.endTime), false),
                    _buildInfoColumn("Date", DateFormat('MMM dd').format(res.startTime), false),
                  ],
                ),
                
                 if (isPending) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: canEdit ? () => _showEditModal(res) : null,
                          icon: Icon(canEdit ? Icons.edit_note_rounded : Icons.lock_outline_rounded, size: 20),
                          label: Text(canEdit ? "Edit" : "Locked"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[200],
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: OutlinedButton.icon(
                          onPressed: canEdit ? () => _handleCancel(res) : null,
                          icon: const Icon(Icons.cancel_outlined, size: 20),
                          label: const Text("Cancel"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: BorderSide(color: canEdit ? Colors.redAccent : Colors.grey[200]!),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                
                if (isArrived) ...[
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.occupied.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_car_rounded, color: AppColors.occupied, size: 18),
                        const SizedBox(width: 8),
                        Text("Session in progress", style: TextStyle(color: AppColors.occupied, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('My Bookings', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                    Text('Manage your parking sessions', style: TextStyle(color: AppColors.textLight)),
                  ],
                ),
              ),
              IconButton(onPressed: _loadReservations, icon: const Icon(Icons.refresh_rounded, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ["Pending", "Arrived", "Completed"].map((filter) {
                final isSelected = _selectedFilter == filter;
                Color activeColor;
                switch(filter) {
                  case "Pending": activeColor = AppColors.reserved; break;
                  case "Arrived": activeColor = AppColors.occupied; break;
                  default: activeColor = Colors.grey[600]!;
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? activeColor : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? activeColor : Colors.grey[300]!),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[600],
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
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

  Widget _buildMiniInfo(IconData icon, String label, bool isFeatured) {
    return Row(
      children: [
        Icon(icon, size: 14, color: isFeatured ? Colors.white70 : AppColors.textLight),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: isFeatured ? Colors.white70 : AppColors.textLight)),
      ],
    );
  }

  Widget _buildInfoColumn(String label, String value, bool isFeatured) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: isFeatured ? Colors.white.withOpacity(0.6) : AppColors.textLight, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isFeatured ? Colors.white : AppColors.primaryDark)),
      ],
    );
  }
}
