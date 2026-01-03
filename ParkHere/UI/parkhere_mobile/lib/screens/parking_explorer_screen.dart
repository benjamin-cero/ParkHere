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
import 'package:parkhere_mobile/utils/message_utils.dart';

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
  double _debt = 0;
  
  Vehicle? _selectedVehicle;
  DateTime _startTime = DateTime.now().add(const Duration(minutes: 15));
  DateTime _endTime = DateTime.now().add(const Duration(hours: 2, minutes: 15));

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    try {
      final sectorProvider = Provider.of<ParkingSectorProvider>(context, listen: false);
      final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);
      final reservationProvider = Provider.of<ParkingReservationProvider>(context, listen: false);
      final userId = UserProvider.currentUser?.id;

      final sectorsResult = await sectorProvider.get(); // Fetch ALL sectors to show inactive ones
      final vehiclesResult = userId != null 
          ? await vehicleProvider.get(filter: {'userId': userId})
          : null;
      final reservationsResult = await reservationProvider.get(filter: {
        'excludePassed': true,
        'retrieveAll': true,
      });

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
          await _loadSpotsForSector(_selectedSectorId, silent: silent);
        } else {
             if (!silent) setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSpotsForSector(int sectorId, {bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    try {
       final spotProvider = Provider.of<ParkingSpotProvider>(context, listen: false);
       // Filter by sector ID
       final spotsResult = await spotProvider.get(filter: {
         'parkingSectorId': sectorId,
         'isActive': true,
       });
       
       if (mounted) {
         setState(() {
           _allSpots = spotsResult.items ?? [];
           if (!silent) _isLoading = false;
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
    // Show as reserved if there is ANY upcoming reservation today or in the future
    return _reservations.any((r) => 
        r.parkingSpotId == spot.id && 
        r.endTime!.isAfter(now) &&
        r.actualEndTime == null // Ignore completed reservations
    );
  }

  Color _getSpotColor(ParkingSpot spot) {
    if (spot.parkingSpotTypeId == 2) return Colors.amber[700]!; // VIP
    if (spot.parkingSpotTypeId == 4) return Colors.green[600]!; // Electric
    if (spot.parkingSpotTypeId == 3) return AppColors.disabled; // Disabled - Indigo
    return AppColors.primary; // Regular - Blue
  }

  int _durationHours = 2;
  int _durationMinutes = 0;

  void _showReservationModal(ParkingSpot spot) async {
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
          final spotReservations = _reservations.where((r) => r.parkingSpotId == spot.id && r.endTime.isAfter(now) && r.actualEndTime == null).toList()
            ..sort((a, b) => a.startTime.compareTo(b.startTime));

          ParkingReservation? conflict;
          for (var res in spotReservations) {
            if (_startTime.isBefore(res.endTime) && calculatedEndTime.isAfter(res.startTime)) {
              conflict = res;
              break;
            }
          }

          // Suggest max stay if conflict exists or if there's a reservation coming up
          String? reservationConflictWarning;
          if (conflict != null) {
            reservationConflictWarning = "Conflict! This spot is booked from ${DateFormat('HH:mm').format(conflict.startTime)}";
          } else {
            // Check for next upcoming
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
                
                // Head Info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: _getSpotColor(spot).withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                      child: Icon(Icons.local_parking_rounded, color: _getSpotColor(spot), size: 28),
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

                // Upcoming Schedule
                if (spotReservations.isNotEmpty) ...[
                  const Text("Upcoming Schedule", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Container(
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
                              Text(DateFormat('MMM d').format(res.startTime), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              Text("${DateFormat('HH:mm').format(res.startTime)} - ${DateFormat('HH:mm').format(res.endTime)}", 
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                
                // Arrival Time
                const Text("Arrive At", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _startTime,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (pickedDate != null) {
                      final TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_startTime));
                      if (pickedTime != null) {
                        setModalState(() {
                          _startTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
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
                        Text(DateFormat('MMM d, yyyy  •  hh:mm a').format(_startTime), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Duration
                const Text("Stay For", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildDurationInput("Hours", _durationHours, (v) => setModalState(() => _durationHours = v))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDurationInput("Minutes", _durationMinutes, (v) => setModalState(() => _durationMinutes = v))),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Warning / Leave info
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: (reservationConflictWarning != null ? AppColors.error : Colors.blue).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(reservationConflictWarning != null ? Icons.warning_amber_rounded : Icons.info_outline_rounded, 
                        color: reservationConflictWarning != null ? AppColors.error : Colors.blue, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          reservationConflictWarning ?? "Leaving at: ${DateFormat('hh:mm a').format(calculatedEndTime)}",
                          style: TextStyle(
                            color: reservationConflictWarning != null ? AppColors.error : Colors.blue, 
                            fontWeight: FontWeight.bold, 
                            fontSize: 13
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                const Text("Select Vehicle", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 8),
                _buildVehicleDropdown(setModalState),

                const Spacer(),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Rate: ${(3.0 * spot.priceMultiplier).toStringAsFixed(2)} BAM/hr", 
                          style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        const Text("Total Price", style: TextStyle(color: Colors.grey, fontSize: 13)),
                        Row(
                          children: [
                             Text("${_calculatePrice(spot).toStringAsFixed(2)} BAM",
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                             if (_debt > 0) ...[
                               const SizedBox(width: 8),
                               Text("+ ${_debt.toStringAsFixed(2)} BAM debt", 
                                style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                             ]
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 160,
                      height: 55,
                      child: AppButton(
                        text: "Book Now",
                        onPressed: (_selectedVehicle != null && conflict == null) ? () => _handleBooking(spot) : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        }
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
              GestureDetector(
                onTap: () {
                    final increment = (label == "Hours" ? 1 : 15);
                    final max = (label == "Hours" ? 24 : 60);
                    if (value + increment <= max) {
                        onChanged(value + increment);
                    }
                }, 
                child: const Icon(Icons.arrow_drop_up, size: 20)
              ),
              GestureDetector(
                onTap: () { 
                    final decrement = (label == "Hours" ? 1 : 15);
                    if (value - decrement >= 0) {
                        onChanged(value - decrement);
                    }
                }, 
                child: const Icon(Icons.arrow_drop_down, size: 20)
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleDropdown(StateSetter setModalState) {
    if (_vehicles.isEmpty) return const Text("No vehicles", style: TextStyle(color: Colors.red));
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.grey[50], border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Vehicle>(
          value: _selectedVehicle,
          isExpanded: true,
          items: _vehicles.map((v) => DropdownMenuItem(value: v, child: Text("${v.name} (${v.licensePlate})"))).toList(),
          onChanged: (v) => setModalState(() => _selectedVehicle = v),
        ),
      ),
    );
  }

  double _calculatePrice(ParkingSpot spot) {
    final durationHours = _durationHours + (_durationMinutes / 60.0);
    double multiplier = spot.priceMultiplier;
    return durationHours * 3.0 * multiplier;
  }

  Future<void> _handleBooking(ParkingSpot spot) async {
    Navigator.pop(context);
    
    try {
      final reservationProvider = Provider.of<ParkingReservationProvider>(context, listen: false);
      final userId = UserProvider.currentUser?.id;
      if (userId == null) return;

      final endTime = _startTime.add(Duration(hours: _durationHours, minutes: _durationMinutes));

      await reservationProvider.insert({
        'userId': userId,
        'vehicleId': _selectedVehicle!.id,
        'parkingSpotId': spot.id,
        'startTime': _startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'isPaid': false,
      });

      if (mounted) {
        MessageUtils.showSuccess(context, 'Reservation successful!');
        await _loadData(silent: true);
      }
    } catch (e) {
      if (mounted) {
        MessageUtils.showError(context, 'Booking failed. Please try again.');
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
                                MessageUtils.showWarning(context, 'Sector is not active');
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
      onTap: isOccupied ? null : () => _showReservationModal(spot),
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
