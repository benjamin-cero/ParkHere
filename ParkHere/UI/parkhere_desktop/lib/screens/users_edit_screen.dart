import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:parkhere_desktop/layouts/master_screen.dart';
import 'package:parkhere_desktop/model/user.dart';
import 'package:parkhere_desktop/model/city.dart';
import 'package:parkhere_desktop/model/gender.dart';
import 'package:parkhere_desktop/providers/user_provider.dart';
import 'package:parkhere_desktop/providers/city_provider.dart';
import 'package:parkhere_desktop/providers/gender_provider.dart';
import 'package:parkhere_desktop/utils/base_textfield.dart';
import 'package:parkhere_desktop/screens/users_list_screen.dart';
import 'package:parkhere_desktop/utils/base_dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class UsersEditScreen extends StatefulWidget {
  final User user;

  const UsersEditScreen({super.key, required this.user});

  @override
  State<UsersEditScreen> createState() => _UsersEditScreenState();
}

class _UsersEditScreenState extends State<UsersEditScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late UserProvider userProvider;
  late CityProvider cityProvider;
  late GenderProvider genderProvider;
  bool isLoading = true;
  bool _isLoadingCities = true;
  bool _isLoadingGenders = true;
  bool _isSaving = false;
  List<City> _cities = [];
  List<Gender> _genders = [];
  City? _selectedCity;
  Gender? _selectedGender;
  File? _image;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    cityProvider = Provider.of<CityProvider>(context, listen: false);
    genderProvider = Provider.of<GenderProvider>(context, listen: false);
    _initialValue = {
      "firstName": widget.user.firstName,
      "lastName": widget.user.lastName,
      "email": widget.user.email,
      "username": widget.user.username,
      "phoneNumber": widget.user.phoneNumber ?? '',
      "isActive": widget.user.isActive,
      "picture": widget.user.picture,
    };
    initFormData();
    _loadCities();
    _loadGenders();
  }

  initFormData() async {
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadCities() async {
    try {
      setState(() {
        _isLoadingCities = true;
      });

      final result = await cityProvider.get();
      if (result.items != null && result.items!.isNotEmpty) {
        setState(() {
          _cities = result.items!;
          _isLoadingCities = false;
        });
        _setDefaultCitySelection();
      } else {
        setState(() {
          _cities = [];
          _isLoadingCities = false;
        });
      }
    } catch (e) {
      setState(() {
        _cities = [];
        _isLoadingCities = false;
      });
    }
  }

  void _setDefaultCitySelection() {
    if (_cities.isNotEmpty) {
      try {
        _selectedCity = _cities.firstWhere(
          (city) => city.id == widget.user.cityId,
          orElse: () => _cities.first,
        );
      } catch (e) {
        _selectedCity = _cities.first;
      }
      setState(() {});
    }
  }

  Future<void> _loadGenders() async {
    try {
      setState(() {
        _isLoadingGenders = true;
      });

      final result = await genderProvider.get();
      if (result.items != null && result.items!.isNotEmpty) {
        setState(() {
          _genders = result.items!;
          _isLoadingGenders = false;
        });
        _setDefaultGenderSelection();
      } else {
        setState(() {
          _genders = [];
          _isLoadingGenders = false;
        });
      }
    } catch (e) {
      setState(() {
        _genders = [];
        _isLoadingGenders = false;
      });
    }
  }

  void _setDefaultGenderSelection() {
    if (_genders.isNotEmpty) {
      try {
        _selectedGender = _genders.firstWhere(
          (gender) => gender.id == widget.user.genderId,
          orElse: () => _genders.first,
        );
      } catch (e) {
        _selectedGender = _genders.first;
      }
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      _image = File(result.files.single.path!);
      _initialValue['picture'] = base64Encode(_image!.readAsBytesSync());
      setState(() {});
    }
  }

  Widget _buildCityDropdown() {
    if (_isLoadingCities) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text("Loading cities...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_cities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          "No cities available",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return DropdownButtonFormField<City>(
      value: _selectedCity,
      decoration: customTextFieldDecoration(
        "City",
        prefixIcon: Icons.location_city,
      ),
      items: _cities.map((city) {
        return DropdownMenuItem<City>(value: city, child: Text(city.name));
      }).toList(),
      onChanged: (City? value) {
        setState(() {
          _selectedCity = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return "Please select a city";
        }
        return null;
      },
      isExpanded: true,
    );
  }

  Widget _buildGenderDropdown() {
    if (_isLoadingGenders) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text("Loading genders...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_genders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          "No genders available",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return DropdownButtonFormField<Gender>(
      value: _selectedGender,
      decoration: customTextFieldDecoration("Gender", prefixIcon: Icons.person),
      items: _genders.map((gender) {
        return DropdownMenuItem<Gender>(
          value: gender,
          child: Text(gender.name),
        );
      }).toList(),
      onChanged: (Gender? value) {
        setState(() {
          _selectedGender = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return "Please select a gender";
        }
        return null;
      },
      isExpanded: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Only show loading if initial data isn't ready
    if (isLoading) {
       return const MasterScreen(
        title: "Edit User",
        showBackButton: true,
        child: Center(child: CircularProgressIndicator()),
      );
    }
  
    return MasterScreen(
      title: "Edit User",
      showBackButton: true,
      child: SingleChildScrollView(
        child: FormBuilder(
          key: formKey,
          initialValue: _initialValue,
          child: Column(
            children: [
              SizedBox(
                height: 260,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // 1. Hero Header
                    Container(
                      height: 200,
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
                              size: 200,
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                          Positioned(
                            top: 60,
                            left: 40,
                            child: Icon(
                              Icons.circle_outlined,
                              size: 100,
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. Overlapping Editable Profile Picture
                    Positioned(
                      bottom: 0,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: _pickImage,
                              borderRadius: BorderRadius.circular(65),
                              child: CircleAvatar(
                                radius: 65,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: _initialValue['picture'] != null &&
                                        (_initialValue['picture'] as String).isNotEmpty
                                    ? MemoryImage(base64Decode(_initialValue['picture']!
                                        .replaceAll(RegExp(r'^data:image/[^;]+;base64,'), '')))
                                    : null,
                                child: (_initialValue['picture'] == null ||
                                        (_initialValue['picture'] as String).isEmpty)
                                    ? const Icon(Icons.person, size: 64, color: Colors.grey)
                                    : null,
                              ),
                            ),
                          ),
                          
                          // Edit/Camera Badge
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1E3A8A),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 22),
                              ),
                            ),
                          ),
                           // Remove Image Badge (only if image exists)
                          if (_initialValue['picture'] != null && (_initialValue['picture'] as String).isNotEmpty)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: InkWell(
                                  onTap: () async {
                                    bool? confirm = await BaseDialog.show(
                                      context: context,
                                      title: "Confirm Removal",
                                      message: "Are you sure you want to remove your profile picture?",
                                      type: BaseDialogType.confirmation,
                                      confirmLabel: "Remove",
                                      cancelLabel: "Cancel",
                                    );

                                    if (confirm == true) {
                                      setState(() {
                                        _image = null;
                                        _initialValue['picture'] = null;
                                      });
                                    }
                                  },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10), // Reduced spacer

              // 3. Title
              const Text(
                "Edit Profile",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
               const SizedBox(height: 8),
              Text(
                "Update personal details & settings",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),

              // 4. Form Content Area
              Container(
                constraints: const BoxConstraints(maxWidth: 800),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Identity Section
                    _buildSectionHeader("Identity Information"),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: FormBuilderTextField(
                            name: "firstName",
                            decoration: customTextFieldDecoration("First Name", prefixIcon: Icons.person_outline),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.match(RegExp(r'^[\p{L} ]+$', unicode: true), errorText: 'Invalid characters'),
                            ]),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: FormBuilderTextField(
                            name: "lastName",
                            decoration: customTextFieldDecoration("Last Name", prefixIcon: Icons.person_outline),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.match(RegExp(r'^[\p{L} ]+$', unicode: true), errorText: 'Invalid characters'),
                            ]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    FormBuilderTextField(
                      name: "username",
                      decoration: customTextFieldDecoration("Username", prefixIcon: Icons.alternate_email),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.minLength(3),
                      ]),
                    ),

                    const SizedBox(height: 40),

                    // Contact Section
                    _buildSectionHeader("Contact & Location"),
                    const SizedBox(height: 20),
                     Row(
                      children: [
                        Expanded(
                          child: FormBuilderTextField(
                            name: "email",
                            decoration: customTextFieldDecoration("Email", prefixIcon: Icons.email_outlined),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(errorText: 'Email is required'),
                              FormBuilderValidators.email(errorText: 'Invalid email address format'),
                            ]),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: FormBuilderTextField(
                            name: "phoneNumber",
                            decoration: customTextFieldDecoration("Phone (Optional)", prefixIcon: Icons.phone_outlined),
                            validator: (value) {
                              if (value == null || value.isEmpty) return null;
                              return FormBuilderValidators.match(
                                RegExp(r'^[+]{0,1}[0-9\s\-]{8,20}$'),
                                errorText: 'Invalid phone number format',
                              )(value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildCityDropdown()),
                        const SizedBox(width: 20),
                        Expanded(child: _buildGenderDropdown()),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Settings Section (Hidden if editing self)
                    if (widget.user.id != UserProvider.currentUser?.id) ...[
                      _buildSectionHeader("Account Status"),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                           boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: FormBuilderSwitch(
                          name: 'isActive',
                          title: const Text('Active Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Text("Allow this user to log in to the system", style: TextStyle(color: Colors.grey[500])),
                          initialValue: _initialValue['isActive'] as bool? ?? true,
                          decoration: const InputDecoration(border: InputBorder.none),
                          activeColor: const Color(0xFF1E3A8A),
                          onChanged: (val) async {
                            if (val == false) {
                              bool? confirm = await BaseDialog.show(
                                context: context,
                                title: "Confirm Deactivation",
                                message: "Are you sure you want to deactivate this user? They will no longer be able to log in.",
                                type: BaseDialogType.confirmation,
                                confirmLabel: "Deactivate",
                                cancelLabel: "Cancel",
                              );
                              if (confirm != true) {
                                formKey.currentState?.fields['isActive']?.didChange(true);
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],

                    // Action Buttons
                    Row(
                      children: [
                         Expanded(
                          child: SizedBox(
                            height: 55,
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                foregroundColor: Colors.grey[700],
                              ),
                              child: const Text("Cancel", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _handleSave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3A8A),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 4,
                                shadowColor: const Color(0xFF1E3A8A).withOpacity(0.4),
                              ),
                              child: _isSaving
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text("Save Changes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
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

   Future<void> _handleSave() async {
    formKey.currentState?.saveAndValidate();
    if (formKey.currentState?.validate() ?? false) {
      if (_selectedCity == null || _selectedGender == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select city and gender')));
        return;
      }

      setState(() => _isSaving = true);
      var request = Map.from(formKey.currentState?.value ?? {});
      request['cityId'] = _selectedCity!.id;
      request['genderId'] = _selectedGender!.id;
      request['picture'] = _initialValue['picture'];

      try {
        if (widget.user.id == UserProvider.currentUser?.id) {
          await userProvider.updateProfile(widget.user.id, request);
        } else {
          await userProvider.update(widget.user.id, request);
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User updated successfully'), backgroundColor: Colors.green),
          );
          
          if (widget.user.id == UserProvider.currentUser?.id) {
            // If editing self, just go back to profile
            Navigator.of(context).pop();
          } else {
            // If admin editing others, go back to list
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const UsersListScreen(),
                settings: const RouteSettings(name: 'UsersListScreen'),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }
}
