import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:parkhere_mobile/providers/user_provider.dart';
import 'package:parkhere_mobile/providers/city_provider.dart';
import 'package:parkhere_mobile/model/city.dart';
import 'package:parkhere_mobile/utils/base_textfield.dart';
import 'package:parkhere_mobile/screens/vehicle_management_screen.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static ImageProvider? getUserImageProvider(String? picture) {
    if (picture == null || picture.isEmpty) return null;
    try {
      Uint8List bytes = base64Decode(picture);
      return MemoryImage(bytes);
    } catch (e) {
      return null;
    }
  }

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  
  City? _selectedCity;
  List<City> _cities = [];
  String? _pictureBase64;

  @override
  void initState() {
    super.initState();
    final user = UserProvider.currentUser;
    _firstNameController = TextEditingController(text: user?.firstName);
    _lastNameController = TextEditingController(text: user?.lastName);
    _phoneController = TextEditingController(text: user?.phoneNumber);
    _pictureBase64 = user?.picture;
    _loadCities();
  }

  Future<void> _loadCities() async {
    try {
      final cityProvider = Provider.of<CityProvider>(context, listen: false);
      final result = await cityProvider.get(filter: {'pageSize': 1000});
      if (mounted) {
        setState(() {
          _cities = result.items ?? [];
          if (UserProvider.currentUser != null) {
            try {
              _selectedCity = _cities.firstWhere((c) => c.id == UserProvider.currentUser!.cityId);
            } catch (_) {}
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _pickImage() async {
    if (!_isEditing) return;
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      setState(() {
        _pictureBase64 = base64Encode(file.readAsBytesSync());
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);
  }

  void _handleSave() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = UserProvider.currentUser!;
      
      final updateData = {
        "firstName": _firstNameController.text,
        "lastName": _lastNameController.text,
        "phoneNumber": _phoneController.text,
        "email": currentUser.email,
        "username": currentUser.username,
        "genderId": currentUser.genderId, // Not editable here for now
        "cityId": _selectedCity?.id ?? currentUser.cityId,
        "picture": _pictureBase64,
        "isActive": true
      };

      await userProvider.update(currentUser.id, updateData);
      
      // Refresh current user data
      UserProvider.currentUser = await userProvider.getById(currentUser.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = UserProvider.currentUser;
    if (user == null) {
      return const Center(child: Text("User session lost. Please login again."));
    }

    return Container(
      decoration: const BoxDecoration(color: AppColors.background),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Card
              _buildProfileHeader(user),
              const SizedBox(height: 32),
              
              // Vehicles Shortcut
              _buildVehicleShortcut(),
              const SizedBox(height: 32),

              // Info Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Personal Details",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        IconButton(
                          onPressed: _toggleEdit,
                          icon: Icon(
                            _isEditing ? Icons.close_rounded : Icons.edit_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    if (_isEditing) ...[
                      AppTextField(
                        label: "First Name",
                        controller: _firstNameController,
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: "Last Name",
                        controller: _lastNameController,
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 16),
                        AppTextField(
                          label: "Phone",
                          controller: _phoneController,
                          prefixIcon: Icons.phone_android_rounded,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<City>(
                          value: _selectedCity,
                          items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                          onChanged: (v) => setState(() => _selectedCity = v),
                          decoration: InputDecoration(
                            labelText: "City",
                            prefixIcon: const Icon(Icons.location_city_rounded, color: AppColors.primary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          text: "Save Changes",
                          onPressed: _handleSave,
                        ),
                      ),
                    ] else ...[
                      _buildInfoRow(Icons.email_outlined, "Email", user.email),
                      _buildInfoRow(Icons.phone_android_rounded, "Phone", user.phoneNumber ?? "Not set"),
                      _buildInfoRow(Icons.location_city_rounded, "City", user.cityName),
                      _buildInfoRow(Icons.person_pin_circle_rounded, "Gender", user.genderName),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: AppGradients.mainBackground,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 4),
                  ),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundImage: ProfileScreen.getUserImageProvider(_isEditing ? _pictureBase64 : user.picture),
                    backgroundColor: Colors.white24,
                    child: (_isEditing ? _pictureBase64 : user.picture) == null 
                        ? const Icon(Icons.person, size: 40, color: Colors.white70) 
                        : null,
                  ),
                ),
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt_rounded, size: 18, color: AppColors.primary),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '@${user.username}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_outline_rounded, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        "MEMBER",
                        style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleShortcut() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const VehicleManagementScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        ),
        child: const Row(
          children: [
            Icon(Icons.directions_car_rounded, color: AppColors.primary),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "My Vehicles",
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                  ),
                  Text(
                    "Manage your cars and license plates",
                    style: TextStyle(fontSize: 12, color: AppColors.textLight),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.w500),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
