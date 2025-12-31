import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parkhere_mobile/model/parking_spot.dart';
import 'package:parkhere_mobile/model/vehicle.dart';
import 'package:parkhere_mobile/model/parking_sector.dart';
import 'package:parkhere_mobile/model/parking_reservation.dart';
import 'package:parkhere_mobile/providers/parking_spot_provider.dart';
import 'package:parkhere_mobile/providers/parking_sector_provider.dart';
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
  List<ParkingSpot> _allSpots = [];
  List<ParkingSector> _sectors = [];
  List<Vehicle> _vehicles = [];
  List<ParkingReservation> _reservations = [];
  bool _isLoading = true;

  int _selectedSectorId = 0;
  
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
      final sectorProvider = Provider.of<ParkingSectorProvider>(context, listen: false);
      final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);
      final reservationProvider = Provider.of<ParkingReservationProvider>(context, listen: false);
      final userId = UserProvider.currentUser?.id;

      final sectorsResult = await sectorProvider.get(); // Fetch ALL sectors to show inactive ones
      final vehiclesResult = userId != null 
          ? await vehicleProvider.get(filter: {'userId': userId})
          : null;
      final reservationsResult = await reservationProvider.get();

      if (mounted) {
        setState(() {
          _sectors = sectorsResult.items ?? [];
          _vehicles = vehiclesResult?.items ?? [];
          _reservations = reservationsResult.items ?? [];
          
          if (_vehicles.isNotEmpty) _selectedVehicle = _vehicles.first;
          if (_sectors.isNotEmpty && _selectedSectorId == 0) {
            _selectedSectorId = _sectors.first.id;
          }
        });
        
        // Load spots for the initial sector
        if (_selectedSectorId != 0) {
          await _loadSpotsForSector(_selectedSectorId);
        } else {
             setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSpotsForSector(int sectorId) async {
    setState(() => _isLoading = true);
    try {
       final spotProvider = Provider.of<ParkingSpotProvider>(context, listen: false);
       // Filter by sector ID
       final spotsResult = await spotProvider.get(filter: {'parkingSectorId': sectorId});
       
       if (mounted) {
         setState(() {
           _allSpots = spotsResult.items ?? [];
           _isLoading = false;
         });
       }
    } catch (e) {
      print("Error loading spots: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<ParkingSpot> _getSpots(int sectorId, String wing) {
    // _allSpots now only contains spots for the selected sector
    return _allSpots.where((spot) {
      final matchesWing = spot.parkingWingName.toLowerCase().contains(wing.toLowerCase());
      return matchesWing;
    }).toList()..sort((a, b) => a.id.compareTo(b.id));
  }

  bool _isSpotReserved(ParkingSpot spot) {
    if (spot.isOccupied) return false;
    final now = DateTime.now();
    return _reservations.any((r) => 
        r.parkingSpotId == spot.id && 
        r.startTime!.isBefore(now) &&
        r.endTime!.isAfter(now)
    );
  }

  Color _getSpotColor(ParkingSpot spot) {
    if (spot.parkingSpotTypeId == 2) return Colors.amber[700]!; // VIP
    if (spot.parkingSpotTypeId == 4) return Colors.green[600]!; // Electric
    if (spot.parkingSpotTypeId == 3) return AppColors.disabled; // Disabled - Indigo
    return AppColors.primary; // Regular - Blue
  }

  void _showReservationModal(ParkingSpot spot) {
    final now = DateTime.now();
    setState(() {
      _startTime = now.add(const Duration(minutes: 15));
      _endTime = _startTime.add(const Duration(hours: 2));
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)
                  ),
                ),
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getSpotColor(spot).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.local_parking, color: _getSpotColor(spot), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(spot.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text("${spot.parkingSectorName} • ${spot.parkingWingName}", 
                            style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                const Text("Vehicle", style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _buildVehicleDropdown(setModalState),
                const SizedBox(height: 16),
                
                const Text("Time", style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildTimeSelector("Start", _startTime, (t) => setModalState(() => _startTime = t))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTimeSelector("End", _endTime, (t) => setModalState(() => _endTime = t))),
                  ],
                ),
                
                const Spacer(),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total", style: TextStyle(color: Colors.grey)),
                        Text("${_calculatePrice(spot).toStringAsFixed(2)} BAM",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(
                      width: 140,
                      child: AppButton(
                        text: "Book",
                        onPressed: _selectedVehicle != null ? () => _handleBooking(spot) : null,
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
    if (_vehicles.isEmpty) return const Text("No vehicles", style: TextStyle(color: Colors.red));
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
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

  Widget _buildTimeSelector(String label, DateTime time, Function(DateTime) onChanged) {
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
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(DateFormat('HH:mm').format(time), 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  double _calculatePrice(ParkingSpot spot) {
    final durationHours = _endTime.difference(_startTime).inMinutes / 60.0;
    double multiplier = 1.0;
    if (spot.parkingSpotTypeId == 2) multiplier = 1.5;
    if (spot.parkingSpotTypeId == 4) multiplier = 1.2;
    if (spot.parkingSpotTypeId == 3) multiplier = 0.75;
    return durationHours * 3.0 * multiplier;
  }

  Future<void> _handleBooking(ParkingSpot spot) async {
    Navigator.pop(context);
    
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
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking failed'), backgroundColor: Colors.red),
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
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Find Parking', 
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                  const SizedBox(height: 16),
                  
                  // Legend Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SPOT TYPES', 
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1.2)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _buildLegend(Colors.green[600]!, "Electric"),
                          _buildLegend(Colors.amber[700]!, "VIP"),
                          _buildLegend(AppColors.disabled, "Disabled"),
                          _buildLegend(AppColors.primary, "Regular"),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('AVAILABILITY', 
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1.2)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _buildLegend(AppColors.reserved, "Reserved"),
                          _buildLegend(AppColors.occupied, "Occupied"),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Sector Selection
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _sectors.map((sector) {
                        final isSelected = _selectedSectorId == sector.id;
                        final isActive = sector.isActive;
                        
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              if (!isActive) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Sector is not active'), backgroundColor: Colors.orange),
                                );
                                return;
                              }
                              
                              if (_selectedSectorId != sector.id) {
                                setState(() => _selectedSectorId = sector.id);
                                _loadSpotsForSector(sector.id);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : (isActive ? Colors.white : Colors.grey[200]),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : (isActive ? Colors.grey[300]! : Colors.transparent)
                                ),
                              ),
                              child: Text(
                                sector.name.isNotEmpty ? sector.name : "Floor ${sector.floorNumber + 1}",
                                style: TextStyle(
                                  color: isSelected ? Colors.white : (isActive ? Colors.black : Colors.grey[500]),
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
            ),

            // Content
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildWing("LEFT WING", _getSpots(_selectedSectorId, "left")),
                        const SizedBox(height: 24),
                        _buildWing("RIGHT WING", _getSpots(_selectedSectorId, "right")),
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildWing(String title, List<ParkingSpot> spots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryDark.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(title, 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark)),
        ),
        const SizedBox(height: 12),
        spots.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(20),
              child: Text("No spots available", style: TextStyle(color: Colors.grey)),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: spots.map((spot) => _buildSpot(spot)).toList(),
            ),
      ],
    );
  }

  Widget _buildSpot(ParkingSpot spot) {
    final isOccupied = spot.isOccupied;
    final isReserved = _isSpotReserved(spot);
    final spotColor = _getSpotColor(spot);
    
    Color bgColor, borderColor;
    IconData? icon;
    
    if (isOccupied) {
      bgColor = AppColors.occupied.withOpacity(0.15);
      borderColor = AppColors.occupied.withOpacity(0.4);
      icon = Icons.block;
    } else if (isReserved) {
      bgColor = AppColors.reserved.withOpacity(0.15);
      borderColor = AppColors.reserved.withOpacity(0.4);
      icon = Icons.schedule;
    } else {
      bgColor = spotColor.withOpacity(0.1);
      borderColor = spotColor.withOpacity(0.5);
      if (spot.parkingSpotTypeId == 4) icon = Icons.electric_bolt;
      else if (spot.parkingSpotTypeId == 2) icon = Icons.star;
      else if (spot.parkingSpotTypeId == 3) icon = Icons.accessible;
    }

    return GestureDetector(
      onTap: (isOccupied || isReserved) ? null : () => _showReservationModal(spot),
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(icon, size: 18, 
                color: isOccupied ? AppColors.occupied : (isReserved ? AppColors.reserved : spotColor)),
            const SizedBox(height: 2),
            Text(
              spot.name.split('-').last.trim(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isOccupied ? AppColors.occupied : (isReserved ? AppColors.reserved : spotColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
