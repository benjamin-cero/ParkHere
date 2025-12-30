import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:parkhere_mobile/providers/user_provider.dart';
import 'package:parkhere_mobile/providers/city_provider.dart';
import 'package:parkhere_mobile/providers/gender_provider.dart';
import 'package:parkhere_mobile/model/city.dart';
import 'package:parkhere_mobile/model/gender.dart';
import 'package:parkhere_mobile/utils/base_textfield.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  // Controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  City? _selectedCity;
  Gender? _selectedGender;
  List<City> _cities = [];
  List<Gender> _genders = [];
  String? _pictureBase64;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final cityProvider = Provider.of<CityProvider>(context, listen: false);
      final genderProvider =
          Provider.of<GenderProvider>(context, listen: false);

      final citiesResult = await cityProvider.get(filter: {'pageSize': 1000});
      final gendersResult = await genderProvider.get(filter: {'pageSize': 1000});

      if (mounted) {
        setState(() {
          _cities = citiesResult.items ?? [];
          _genders = gendersResult.items ?? [];
        });
      }
    } catch (_) {}
  }

  Future<void> _pickImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      setState(() {
        _pictureBase64 = base64Encode(file.readAsBytesSync());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(gradient: AppGradients.mainBackground),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildProfilePicPicker(),
                              const SizedBox(height: 32),
                              
                              Text(
                                "Personal Information",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              AppTextField(
                                label: "First Name",
                                controller: firstNameController,
                                prefixIcon: Icons.person_outline_rounded,
                                hintText: "Enter your first name",
                              ),
                              const SizedBox(height: 16),
                              AppTextField(
                                label: "Last Name",
                                controller: lastNameController,
                                prefixIcon: Icons.person_outline_rounded,
                                hintText: "Enter your last name",
                              ),
                              const SizedBox(height: 16),
                              AppTextField(
                                label: "Email",
                                controller: emailController,
                                prefixIcon: Icons.email_outlined,
                                hintText: "Enter your email address",
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 16),
                              AppTextField(
                                label: "Phone Number",
                                controller: phoneController,
                                prefixIcon: Icons.phone_outlined,
                                hintText: "Enter your phone number",
                                keyboardType: TextInputType.phone,
                              ),
                              
                              const SizedBox(height: 32),
                              Text(
                                "Account Credentials",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              AppTextField(
                                label: "Username",
                                controller: usernameController,
                                prefixIcon: Icons.account_circle_outlined,
                                hintText: "Choose a unique username",
                              ),
                              const SizedBox(height: 16),
                              AppTextField(
                                label: "Password",
                                controller: passwordController,
                                prefixIcon: Icons.lock_outline_rounded,
                                obscureText: !_isPasswordVisible,
                                hintText: "Create a secure password",
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    color: AppColors.textLight,
                                  ),
                                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                ),
                              ),
                              const SizedBox(height: 16),
                              AppTextField(
                                label: "Confirm Password",
                                controller: confirmPasswordController,
                                prefixIcon: Icons.lock_clock_outlined,
                                obscureText: true,
                                hintText: "Repeat your password",
                              ),
                              
                              const SizedBox(height: 32),
                              Text(
                                "Preferences",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              _buildDropdown<Gender>(
                                label: "Gender",
                                value: _selectedGender,
                                icon: Icons.person_outline_rounded,
                                items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g.name))).toList(),
                                onChanged: (v) => setState(() => _selectedGender = v),
                              ),
                              const SizedBox(height: 16),
                              _buildDropdown<City>(
                                label: "City",
                                value: _selectedCity,
                                icon: Icons.location_city_outlined,
                                items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                                onChanged: (v) => setState(() => _selectedCity = v),
                              ),
                              
                              const SizedBox(height: 48),
                              AppButton(
                                text: "Create Account",
                                onPressed: _isLoading ? null : _handleRegister,
                                isLoading: _isLoading,
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                "Join ParkHere community",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePicPicker() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Stack(
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    )
                  ],
                  border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 4),
                ),
                child: ClipOval(
                  child: _pictureBase64 != null
                      ? Image.memory(base64Decode(_pictureBase64!), fit: BoxFit.cover)
                      : Center(
                          child: Icon(Icons.person_outline_rounded,
                              size: 70, color: Colors.grey[300]),
                        ),
                ),
              ),
              Positioned(
                bottom: 5,
                right: 5,
                child: Container(
                  padding: const Offset(0, 0) == Offset.zero ? const EdgeInsets.all(12) : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: const Icon(Icons.add_a_photo_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _pictureBase64 == null ? "Tap to add profile picture" : "Tap to change photo",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textLight),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final registrationData = {
        "firstName": firstNameController.text,
        "lastName": lastNameController.text,
        "email": emailController.text,
        "username": usernameController.text,
        "password": passwordController.text,
        "phoneNumber": phoneController.text,
        "genderId": _selectedGender?.id,
        "cityId": _selectedCity?.id,
        "isActive": true,
        "roleIds": [2],
        "picture": _pictureBase64,
      };

      await userProvider.insert(registrationData);
      if (mounted) _showSuccessDialog();
    } catch (e) {
      if (mounted) _showErrorDialog("Registration failed. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _validateForm() {
    if (firstNameController.text.isEmpty || lastNameController.text.isEmpty) {
      _showErrorDialog("Please enter your full name.");
      return false;
    }
    if (emailController.text.isEmpty || !emailController.text.contains('@')) {
      _showErrorDialog("Please enter a valid email address.");
      return false;
    }
    if (usernameController.text.isEmpty) {
      _showErrorDialog("Please enter a username.");
      return false;
    }
    if (passwordController.text.isEmpty || passwordController.text.length < 6) {
      _showErrorDialog("Password must be at least 6 characters long.");
      return false;
    }
    if (passwordController.text != confirmPasswordController.text) {
      _showErrorDialog("Passwords do not match.");
      return false;
    }
    if (phoneController.text.isEmpty) {
      _showErrorDialog("Please enter your phone number.");
      return false;
    }
    if (_selectedCity == null || _selectedGender == null) {
      _showErrorDialog("Please select your city and gender.");
      return false;
    }
    return true;
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 48),
              ),
              const SizedBox(height: 24),
              const Text(
                "Welcome Aboard!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Your account has been created. Start your parking journey with ParkHere.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textLight, height: 1.5),
              ),
              const SizedBox(height: 32),
              AppButton(
                text: "Get Started",
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
              ),
              const SizedBox(height: 24),
              const Text(
                "Oops! Something's wrong",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textLight, height: 1.5),
              ),
              const SizedBox(height: 32),
              AppButton(
                text: "Try Again",
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
