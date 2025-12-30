import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parkhere_mobile/model/vehicle.dart';
import 'package:parkhere_mobile/providers/vehicle_provider.dart';
import 'package:parkhere_mobile/providers/user_provider.dart';
import 'package:parkhere_mobile/utils/base_textfield.dart';

class VehicleManagementScreen extends StatefulWidget {
  const VehicleManagementScreen({super.key});

  @override
  State<VehicleManagementScreen> createState() => _VehicleManagementScreenState();
}

class _VehicleManagementScreenState extends State<VehicleManagementScreen> {
  List<Vehicle> _vehicles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    final user = UserProvider.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);
      final result = await vehicleProvider.get(filter: {'userId': user.id});
      if (mounted) {
        setState(() {
          _vehicles = result.items ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddEditDialog([Vehicle? vehicle]) {
    final isEditing = vehicle != null;
    final nameController = TextEditingController(text: vehicle?.name);
    final licensePlateController = TextEditingController(text: vehicle?.licensePlate);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          isEditing ? "Edit Vehicle" : "Add Vehicle",
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: "Vehicle Nickname",
              hintText: "e.g. My SUV",
              controller: nameController,
              prefixIcon: Icons.label_outline_rounded,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: "License Plate",
              hintText: "e.g. ST-123-AB",
              controller: licensePlateController,
              prefixIcon: Icons.tag_rounded,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: AppColors.textLight)),
          ),
          AppButton(
            text: "Save",
            onPressed: () async {
              final user = UserProvider.currentUser;
              if (user == null) return;

              final provider = Provider.of<VehicleProvider>(context, listen: false);
              try {
                if (isEditing) {
                  await provider.update(vehicle.id, {
                    'name': nameController.text,
                    'licensePlate': licensePlateController.text,
                    'userId': user.id,
                  });
                } else {
                  await provider.insert({
                    'name': nameController.text,
                    'licensePlate': licensePlateController.text,
                    'userId': user.id,
                  });
                }
                Navigator.pop(context);
                _loadVehicles();
              } catch (e) {
                // Show error
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("My Vehicles", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primaryDark,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _vehicles.isEmpty
              ? _buildEmptyState()
              : _buildVehicleList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        label: const Text("Add Vehicle", style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add_rounded),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_filled_rounded, size: 80, color: AppColors.primary.withOpacity(0.2)),
          const SizedBox(height: 24),
          const Text(
            "No vehicles added",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
          ),
          const SizedBox(height: 8),
          const Text(
            "Add your car to start booking parking.",
            style: TextStyle(color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleList() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = _vehicles[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: vehicle.isActive ? AppColors.primary.withOpacity(0.1) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.directions_car_rounded,
                color: vehicle.isActive ? AppColors.primary : Colors.grey,
              ),
            ),
            title: Text(
              vehicle.name,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
            ),
            subtitle: Text(
              vehicle.licensePlate,
              style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textLight),
            ),
            trailing: PopupMenuButton(
              icon: const Icon(Icons.more_vert_rounded, color: AppColors.textLight),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text("Edit")),
                const PopupMenuItem(value: 'delete', child: Text("Delete", style: TextStyle(color: AppColors.error))),
              ],
              onSelected: (value) {
                if (value == 'edit') _showAddEditDialog(vehicle);
                if (value == 'delete') {
                  // Implement delete
                }
              },
            ),
          ),
        );
      },
    );
  }
}
