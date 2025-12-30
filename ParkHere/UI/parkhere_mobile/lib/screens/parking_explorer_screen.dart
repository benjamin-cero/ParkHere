import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parkhere_mobile/model/parking_spot.dart';
import 'package:parkhere_mobile/model/vehicle.dart';
import 'package:parkhere_mobile/providers/parking_spot_provider.dart';
import 'package:parkhere_mobile/providers/vehicle_provider.dart';
import 'package:parkhere_mobile/providers/parking_reservation_provider.dart';
import 'package:parkhere_mobile/providers/user_provider.dart';
import 'package:parkhere_mobile/utils/base_textfield.dart';
import 'package:intl/intl.dart';

class ParkingExplorerScreen extends StatefulWidget {
  const ParkingExplorerScreen({super.key});

  @override
  State<ParkingExplorerScreen> createState() => _ParkingExplorerScreenState();
}

class _ParkingExplorerScreenState extends State<ParkingExplorerScreen> {
  // Data
  List<ParkingSpot> _allSpots = [];
  List<Vehicle> _vehicles = [];
  bool _isLoading = true;

  // Selection
  int _selectedSectorId = 1; // Default to A1
  List<ParkingSpot> _leftWingSpots = [];
  List<ParkingSpot> _rightWingSpots = [];
  
  // Reservation
  Vehicle? _selectedVehicle;
  DateTime _startTime = DateTime.now().add(const Duration(minutes: 15));
  DateTime _endTime = DateTime.now().add(const Duration(hours: 2, minutes: 15));

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final spotProvider = Provider.of<ParkingSpotProvider>(context, listen: false);
      final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);
      final userId = UserProvider.currentUser?.id;

      final spotsResult = await spotProvider.get();
      final vehiclesResult = userId != null 
          ? await vehicleProvider.get(filter: {'userId': userId})
          : null;

      if (mounted) {
        setState(() {
          _allSpots = spotsResult.items ?? [];
          _vehicles = vehiclesResult?.items ?? [];
          if (_vehicles.isNotEmpty) _selectedVehicle = _vehicles.first;
          _isLoading = false;
        });
        _filterSpotsBySector();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterSpotsBySector() {
    // Assuming backend returns wing info. 
    // If not, we might need to parse spot.name or code? 
    // But since we updated model, let's try to use parkingSectorId.
    // Fallback: Parse "A1-" etc. if needed.
    
    // Hardcoded logic based on known seeder structure if IDs match:
    // Sector 1 (A1), Sector 2 (A2), etc.
    
    final sectorSpots = _allSpots.where((s) => s.parkingSectorId == _selectedSectorId).toList();
    
    // Sort logic: 
    // Odd wings are Left, Even wings are Right (based on seeder: 1,3,5,7 Left; 2,4,6,8 Right)
    // Or we rely on parkingWingName containing "Left" or "Right"
    
    setState(() {
      _leftWingSpots = sectorSpots.where((s) => 
        s.parkingWingName.contains("Left") || s.parkingWingId % 2 != 0
      ).toList();
      
      _rightWingSpots = sectorSpots.where((s) => 
        s.parkingWingName.contains("Right") || s.parkingWingId % 2 == 0
      ).toList();
      
      // Sort by name or code to ensure 1-15 order
      _leftWingSpots.sort((a, b) => a.name.compareTo(b.name));
      _rightWingSpots.sort((a, b) => a.name.compareTo(b.name));
    });
  }

  void _onSectorChanged(int sectorId) {
    setState(() {
      _selectedSectorId = sectorId;
    });
    _filterSpotsBySector();
  }

  void _showReservationModal(ParkingSpot spot) {
    // Reset times for new reservation attempt
    setState(() {
      _startTime = DateTime.now().add(const Duration(minutes: 15));
      _endTime = DateTime.now().add(const Duration(hours: 2, minutes: 15));
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.local_parking_rounded, color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          spot.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                        ),
                        Text(
                          "${spot.parkingSectorName} • ${spot.parkingWingName} Wing",
                          style: const TextStyle(color: AppColors.textLight),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Vehicle
                const Text("Select Vehicle", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
                const SizedBox(height: 8),
                _buildVehicleDropdown(setModalState),
                const SizedBox(height: 24),

                // Time
                const Text("Select Time", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildTimeSelector(context, "Start", _startTime, (t) => setModalState(() => _startTime = t))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTimeSelector(context, "End", _endTime, (t) => setModalState(() => _endTime = t))),
                  ],
                ),
                const SizedBox(height: 12),
                 Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "Tip: You can extend your booking up to 30 minutes before it expires.",
                          style: TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Warning
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[100]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "Warning: Overstaying will result in a penalty multiplier applied to your fee.",
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Price", style: TextStyle(color: AppColors.textLight)),
                        Text(
                          "${_calculatePrice(spot).toStringAsFixed(2)} BAM",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 160,
                      child: AppButton(
                        text: "Confirm",
                        onPressed: (_selectedVehicle != null) 
                          ? () => _handleBookingConfirm(spot) 
                          : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildVehicleDropdown(StateSetter setModalState) {
    if (_vehicles.isEmpty) return const Text("No vehicles found. Add one in profile.", style: TextStyle(color: Colors.red));
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Vehicle>(
          value: _selectedVehicle,
          isExpanded: true,
          items: _vehicles.map((v) => DropdownMenuItem(
            value: v,
            child: Text("${v.name} (${v.licensePlate})"),
          )).toList(),
          onChanged: (v) => setModalState(() => _selectedVehicle = v),
        ),
      ),
    );
  }

  Widget _buildTimeSelector(BuildContext context, String label, DateTime time, Function(DateTime) onChanged) {
    return GestureDetector(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(time),
        );
        if (picked != null) {
          final now = DateTime.now();
          onChanged(DateTime(now.year, now.month, now.day, picked.hour, picked.minute));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(time),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  double _calculatePrice(ParkingSpot spot) {
    final durationHours = _endTime.difference(_startTime).inMinutes / 60.0;
    // Base rate 3 BAM. 
    // Ideally we get multiplier from spot type, but simplified:
    double multiplier = 1.0;
    if (spot.parkingSpotTypeName == "VIP") multiplier = 1.5;
    if (spot.parkingSpotTypeName == "Electric") multiplier = 1.2;
    // Handicapped usually cheaper or free, let's say 0.75
    if (spot.parkingSpotTypeName == "Handicapped") multiplier = 0.75;

    return durationHours * 3.0 * multiplier;
  }

  Future<void> _handleBookingConfirm(ParkingSpot spot) async {
    Navigator.pop(context); // Close modal
    
    // Show loading or confirm dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Reservation"),
        content: Text("Are you sure you want to reserve ${spot.name}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Reserve")),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final reservationProvider = Provider.of<ParkingReservationProvider>(context, listen: false);
      final userId = UserProvider.currentUser?.id;
      if (userId == null) return;

      await reservationProvider.insert({
        'userId': userId,
        'vehicleId': _selectedVehicle!.id,
        'parkingSpotId': spot.id,
        'startTime': _startTime.toIso8601String(),
        'endTime': _endTime.toIso8601String(),
        'isPaid': false,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reservation successful!'), backgroundColor: Colors.green),
        );
        _loadData(); // Refresh spots
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to reserve spot.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
             Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Find Parking',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Select your preferred spot',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Legend
                  Row(
                    children: [
                      _buildLegendItem(AppColors.primary, "Free"),
                      const SizedBox(width: 8),
                      _buildLegendItem(Colors.grey[300]!, "Taken"),
                    ],
                  )
                ],
              ),
            ),
            
            // Sector Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildSectorTab(1, "Sector A1"),
                  const SizedBox(width: 8),
                  _buildSectorTab(2, "Sector A2"),
                  const SizedBox(width: 8),
                  _buildSectorTab(3, "Sector A3"),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Wings Content
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Wing
                        Expanded(
                          child: Column(
                            children: [
                              const Text("LEFT WING", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textLight, letterSpacing: 1)),
                              const SizedBox(height: 16),
                              Expanded(child: _buildSpotGrid(_leftWingSpots)),
                            ],
                          ),
                        ),
                        
                        // Divider
                        Container(width: 1, color: Colors.grey[200], margin: const EdgeInsets.symmetric(horizontal: 8)),
                        
                        // Right Wing
                        Expanded(
                          child: Column(
                            children: [
                              const Text("RIGHT WING", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textLight, letterSpacing: 1)),
                              const SizedBox(height: 16),
                              Expanded(child: _buildSpotGrid(_rightWingSpots)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
      ],
    );
  }

  Widget _buildSectorTab(int id, String label) {
    final isSelected = _selectedSectorId == id;
    return GestureDetector(
      onTap: () => _onSectorChanged(id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey[300]!),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.text,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSpotGrid(List<ParkingSpot> spots) {
    if (spots.isEmpty) return const Center(child: Text("No spots", style: TextStyle(color: Colors.grey)));

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: spots.length,
      itemBuilder: (context, index) {
        final spot = spots[index];
        return _buildSpotItem(spot);
      },
    );
  }

  Widget _buildSpotItem(ParkingSpot spot) {
    final isOccupied = spot.isOccupied;
    return GestureDetector(
      onTap: isOccupied ? null : () => _showReservationModal(spot),
      child: Container(
        decoration: BoxDecoration(
          color: isOccupied ? Colors.grey[200] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOccupied ? Colors.grey[300]! : AppColors.primary.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: isOccupied ? [] : [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              spot.name, // e.g. "L1" or "A1-L1"
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isOccupied ? Colors.grey : AppColors.primaryDark,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            if (!isOccupied)
              const Icon(Icons.check_circle_outline, size: 16, color: AppColors.primary),
             if (isOccupied)
              const Icon(Icons.block, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
