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
  List<ParkingSpot> _spots = [];
  List<Vehicle> _vehicles = [];
  bool _isLoading = true;
  
  ParkingSpot? _selectedSpot;
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
          _spots = spotsResult.items ?? [];
          _vehicles = vehiclesResult?.items ?? [];
          if (_vehicles.isNotEmpty) _selectedVehicle = _vehicles.first;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double _calculatePrice() {
    if (_selectedSpot == null) return 0;
    final durationHours = _endTime.difference(_startTime).inMinutes / 60.0;
    // Base rate 3 BAM, multiplier depends on spot type (simplified here for UI)
    return durationHours * 3.0; 
  }

  Future<void> _handleBooking() async {
    if (_selectedSpot == null || _selectedVehicle == null) return;

    try {
      final reservationProvider = Provider.of<ParkingReservationProvider>(context, listen: false);
      final userId = UserProvider.currentUser?.id;
      if (userId == null) return;

      await reservationProvider.insert({
        'userId': userId,
        'vehicleId': _selectedVehicle!.id,
        'parkingSpotId': _selectedSpot!.id,
        'startTime': _startTime.toIso8601String(),
        'endTime': _endTime.toIso8601String(),
        'isPaid': false,
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Success!"),
            content: const Text("Your parking spot has been reserved."),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
            ],
          ),
        );
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("1. Select Parking Spot"),
                const SizedBox(height: 16),
                _buildSpotList(),
                const SizedBox(height: 32),
                
                _buildSectionHeader("2. Select Vehicle"),
                const SizedBox(height: 16),
                _buildVehiclePicker(),
                const SizedBox(height: 32),

                _buildSectionHeader("3. Select Time Range"),
                const SizedBox(height: 16),
                _buildTimePicker(),
                const SizedBox(height: 40),

                _buildPriceSummary(),
                const SizedBox(height: 24),
                AppButton(
                  text: "Reserve Now",
                  onPressed: (_selectedSpot != null && _selectedVehicle != null) ? _handleBooking : null,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
    );
  }

  Widget _buildSpotList() {
    return Container(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _spots.length,
        itemBuilder: (context, index) {
          final spot = _spots[index];
          final isSelected = _selectedSpot?.id == spot.id;
          return GestureDetector(
            onTap: () => setState(() => _selectedSpot = spot),
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? AppColors.primary : Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_parking_rounded,
                    color: isSelected ? Colors.white : AppColors.primary,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    spot.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.primaryDark,
                    ),
                  ),
                  Text(
                    spot.parkingSpotTypeName,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white70 : AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVehiclePicker() {
    if (_vehicles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12)),
        child: const Text("Please add a vehicle in your profile first.", style: TextStyle(color: Colors.red)),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Vehicle>(
          value: _selectedVehicle,
          isExpanded: true,
          items: _vehicles.map((v) => DropdownMenuItem(
            value: v,
            child: Text("${v.name} (${v.licensePlate})"),
          )).toList(),
          onChanged: (v) => setState(() => _selectedVehicle = v),
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return Row(
      children: [
        Expanded(child: _buildTimeButton("Start", _startTime)),
        const SizedBox(width: 16),
        Expanded(child: _buildTimeButton("End", _endTime)),
      ],
    );
  }

  Widget _buildTimeButton(String label, DateTime time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            DateFormat('HH:mm').format(time),
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSummary() {
    final price = _calculatePrice();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppGradients.buttonGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Total Estimated Price",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            "${price.toStringAsFixed(2)} BAM",
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
