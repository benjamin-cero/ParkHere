import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:parkhere_desktop/layouts/master_screen.dart';
import 'package:parkhere_desktop/model/festival.dart';

import 'package:parkhere_desktop/model/asset.dart';
import 'package:parkhere_desktop/model/city.dart';
import 'package:parkhere_desktop/model/subcategory.dart';
import 'package:parkhere_desktop/model/organizer.dart';
import 'package:parkhere_desktop/providers/festival_provider.dart';
import 'package:parkhere_desktop/providers/asset_provider.dart';
import 'package:parkhere_desktop/providers/city_provider.dart';
import 'package:parkhere_desktop/providers/subcategory_provider.dart';
import 'package:parkhere_desktop/providers/organizer_provider.dart';
import 'package:parkhere_desktop/utils/base_textfield.dart';
import 'package:parkhere_desktop/utils/base_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class FestivalUpsertScreen extends StatefulWidget {
  final Festival? festival; // null for create, Festival object for edit

  const FestivalUpsertScreen({super.key, this.festival});

  @override
  State<FestivalUpsertScreen> createState() => _FestivalUpsertScreenState();
}

class _FestivalUpsertScreenState extends State<FestivalUpsertScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _basePriceController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  int? _selectedCityId;
  int? _selectedSubcategoryId;
  int? _selectedOrganizerId;
  bool _isActive = true;

  List<Asset> _existingAssets = [];
  List<File> _newImages = [];
  List<String> _assetsToDelete = [];

  // Festival logo state (base64 like country flag)
  String? _logoBase64;
  File? _logoFile;

  late FestivalProvider _festivalProvider;
  late AssetProvider _assetProvider;
  late CityProvider _cityProvider;
  late SubcategoryProvider _subcategoryProvider;
  late OrganizerProvider _organizerProvider;

  List<City> _cities = [];
  List<Subcategory> _subcategories = [];
  List<Organizer> _organizers = [];

  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.festival != null;
    _initializeData();

    // Add listener to location controller to update map preview
    _locationController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _initializeData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _festivalProvider = context.read<FestivalProvider>();
      _assetProvider = context.read<AssetProvider>();
      _cityProvider = context.read<CityProvider>();
      _subcategoryProvider = context.read<SubcategoryProvider>();
      _organizerProvider = context.read<OrganizerProvider>();

      await Future.wait([
        _loadCities(),
        _loadSubcategories(),
        _loadOrganizers(),
      ]);

      if (_isEditing) {
        _populateForm();
        await _loadExistingAssets();
      }
    });
  }

  Future<void> _loadCities() async {
    try {
      final result = await _cityProvider.get(
        filter: {'page': 0, 'pageSize': 1000, 'includeTotalCount': false},
      );
      if (result.items != null) {
        setState(() {
          _cities = result.items!;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadSubcategories() async {
    try {
      final result = await _subcategoryProvider.get(
        filter: {'page': 0, 'pageSize': 1000, 'includeTotalCount': false},
      );
      if (result.items != null) {
        setState(() {
          _subcategories = result.items!;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadOrganizers() async {
    try {
      final result = await _organizerProvider.get(
        filter: {'page': 0, 'pageSize': 1000, 'includeTotalCount': false},
      );
      if (result.items != null) {
        setState(() {
          _organizers = result.items!;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadExistingAssets() async {
    if (widget.festival != null) {
      try {
        // First try to get assets from the festival object if they're already loaded
        if (widget.festival!.assets.isNotEmpty) {
          setState(() {
            _existingAssets = widget.festival!.assets;
          });
        } else {
          // If not loaded, fetch them separately
          final result = await _assetProvider.get(
            filter: {'festivalId': widget.festival!.id},
          );
          if (result.items != null) {
            setState(() {
              _existingAssets = result.items!;
            });
          }
        }
      } catch (e) {
        print('Error loading existing assets: $e');
      }
    }
  }

  void _populateForm() {
    final festival = widget.festival!;
    _titleController.text = festival.title;
    _basePriceController.text = festival.basePrice.toString();
    _locationController.text = festival.location ?? '';
    _startDate = festival.startDate;
    _endDate = festival.endDate;
    _selectedCityId = festival.cityId;
    _selectedSubcategoryId = festival.subcategoryId;
    _selectedOrganizerId = festival.organizerId;
    _isActive = festival.isActive;
    _logoBase64 = festival.logo; // preload existing logo if any

    // Trigger rebuild to show map if location exists
    setState(() {});
  }

  Future<void> _pickImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _newImages.addAll(
            result.paths
                .map((path) => File(path!))
                .where((file) => file.existsSync()),
          );
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _pickLogo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final bytes = await file.readAsBytes();
        setState(() {
          _logoFile = file;
          _logoBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  void _removeExistingAsset(String assetId) {
    setState(() {
      _assetsToDelete.add(assetId);
      _existingAssets.removeWhere((asset) => asset.id.toString() == assetId);
    });
  }

  Future<void> _saveFestival() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = {
        'title': _titleController.text.trim(),
        'startDate': _startDate!.toIso8601String(),
        'endDate': _endDate!.toIso8601String(),
        'basePrice': double.parse(_basePriceController.text),
        'location': _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        'cityId': _selectedCityId!,
        'subcategoryId': _selectedSubcategoryId!,
        'organizerId': _selectedOrganizerId!,
        'isActive': _isActive,
        'logo': _logoBase64,
      };

      Festival savedFestival;
      if (_isEditing) {
        savedFestival = await _festivalProvider.update(
          widget.festival!.id,
          request,
        );
      } else {
        savedFestival = await _festivalProvider.insert(request);
      }

      // Handle assets
      await _handleAssets(savedFestival.id);

      // Delete marked assets
      for (String assetId in _assetsToDelete) {
        await _assetProvider.delete(int.parse(assetId));
      }

      // Refresh the festival data to include assets
      if (_isEditing) {
        final result = await _festivalProvider.get(
          filter: {'id': savedFestival.id, 'pageSize': 1},
        );
        if (result.items != null && result.items!.isNotEmpty) {
          savedFestival = result.items!.first;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Festival updated successfully!'
                  : 'Festival created successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back to list screen and trigger refresh
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleAssets(int festivalId) async {
    // Upload new images
    for (File imageFile in _newImages) {
      try {
        final bytes = await imageFile.readAsBytes();
        final base64String = base64Encode(bytes);
        final fileName = imageFile.path.split('/').last;
        final contentType = 'image/${fileName.split('.').last}';

        await _assetProvider.insert({
          'fileName': fileName,
          'contentType': contentType,
          'base64Content': base64String,
          'festivalId': festivalId,
          'festivalTitle': '', // Add empty string for now
        });
      } catch (e) {
        // Handle individual asset upload error
        print('Error uploading asset: $e');
      }
    }
  }

  Future<void> _showMapPicker() async {
    // Show a dialog with a map for location picking
    final coordinates = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return _MapPickerDialog(
          initialLocation: _locationController.text.isNotEmpty
              ? _locationController.text
              : '43.8563,18.4131',
        );
      },
    );

    if (coordinates != null) {
      setState(() {
        _locationController.text = coordinates;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: _isEditing ? 'Edit Festival' : 'New Festival',
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfoCard(),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildLogoCard()),
                  const SizedBox(width: 20),
                  Expanded(child: _buildLocationCard()),
                  const SizedBox(width: 20),
                  Expanded(child: _buildAssetsCard()),
                ],
              ),
              const SizedBox(height: 30),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Festival Logo',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: _logoBase64 != null && _logoBase64!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        base64Decode(_logoBase64!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildLogoPlaceholder();
                        },
                      ),
                    )
                  : _buildLogoPlaceholder(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickLogo,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Select Logo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _logoFile = null;
                        _logoBase64 = null;
                      });
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear Logo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 162, 159, 159),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.festival, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text(
          'No logo selected',
          style: TextStyle(fontSize: 16, color: Colors.grey[500]),
        ),
        const SizedBox(height: 4),
        Text(
          "Click 'Select Logo' to upload",
          style: TextStyle(fontSize: 14, color: Colors.grey[400]),
        ),
      ],
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _titleController,
                    decoration: customTextFieldDecoration(
                      'Festival Title',
                      prefixIcon: Icons.festival,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a festival title';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TextFormField(
                    controller: _basePriceController,
                    decoration: customTextFieldDecoration(
                      'Base Price',
                      prefixIcon: Icons.attach_money,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a base price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    'Start Date',
                    _startDate,
                    (date) => setState(() => _startDate = date),
                    Icons.calendar_today,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildDateField(
                    'End Date',
                    _endDate,
                    (date) => setState(() => _endDate = date),
                    Icons.calendar_today,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    'City',
                    _selectedCityId,
                    _cities
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    (value) => setState(() => _selectedCityId = value),
                    Icons.location_city,
                    'Select City',
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildDropdown(
                    'Subcategory',
                    _selectedSubcategoryId,
                    _subcategories
                        .map(
                          (s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name),
                          ),
                        )
                        .toList(),
                    (value) => setState(() => _selectedSubcategoryId = value),
                    Icons.category,
                    'Select Subcategory',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    'Organizer',
                    _selectedOrganizerId,
                    _organizers
                        .map(
                          (o) => DropdownMenuItem(
                            value: o.id,
                            child: Text(o.name),
                          ),
                        )
                        .toList(),
                    (value) => setState(() => _selectedOrganizerId = value),
                    Icons.person,
                    'Select Organizer',
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Row(
                    children: [
                      Switch(
                        value: _isActive,
                        onChanged: (value) => setState(() => _isActive = value),
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text('Active'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _locationController,
                    decoration: customTextFieldDecoration(
                      'Coordinates (e.g., 43.8563,18.4131)',
                      prefixIcon: Icons.location_on,
                    ),
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        final coords = value.trim().split(',');
                        if (coords.length != 2) {
                          return 'Please enter coordinates in format: latitude,longitude';
                        }
                        if (double.tryParse(coords[0]) == null ||
                            double.tryParse(coords[1]) == null) {
                          return 'Please enter valid coordinates';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _showMapPicker,
                  icon: const Icon(Icons.map),
                  label: const Text('Pick on Map'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_locationController.text.isNotEmpty)
              Container(
                height: 300,
                width: double.infinity,
                child: BaseMap(
                  start: _locationController.text,
                  end: _locationController.text,
                  height: 300,
                  width: double.infinity,
                  showRouteInfoOverlay: false,
                  showZoomControls: true,
                  title: 'Selected Location',
                  accentColor: Theme.of(context).colorScheme.primary,
                  isSelectable: false,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Festival Assets',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Images'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Existing assets
            if (_existingAssets.isNotEmpty) ...[
              Text(
                'Existing Assets',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _existingAssets.map((asset) {
                  if (_assetsToDelete.contains(asset.id.toString()))
                    return const SizedBox.shrink();

                  return Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            base64Decode(asset.base64Content),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image_not_supported),
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () =>
                              _removeExistingAsset(asset.id.toString()),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // New images
            if (_newImages.isNotEmpty) ...[
              Text(
                'New Images',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _newImages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final image = entry.value;

                  return Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(image, fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeNewImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],

            if (_existingAssets.isEmpty && _newImages.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No assets added yet',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Click "Add Images" to upload festival photos',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade300,
            foregroundColor: Colors.black87,
          ),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveFestival,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(_isEditing ? 'Update Festival' : 'Create Festival'),
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? selectedDate,
    Function(DateTime?) onDateSelected,
    IconData icon,
  ) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        );
        if (date != null) {
          onDateSelected(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedDate != null
                    ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                    : label,
                style: TextStyle(
                  color: selectedDate != null
                      ? Colors.black
                      : Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    int? selectedValue,
    List<DropdownMenuItem<int>> items,
    Function(int?) onChanged,
    IconData icon,
    String hint,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<int>(
        value: selectedValue,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: InputBorder.none,
          hintText: hint,
          prefixIcon: Icon(icon),
        ),
        items: [
          DropdownMenuItem<int>(value: null, child: Text('Select $label')),
          ...items,
        ],
        onChanged: onChanged,
        validator: (value) {
          if (value == null) {
            return 'Please select a $label';
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _basePriceController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}

class _MapPickerDialog extends StatefulWidget {
  final String initialLocation;

  const _MapPickerDialog({required this.initialLocation});

  @override
  State<_MapPickerDialog> createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<_MapPickerDialog> {
  String _selectedLocation = '';
  late String _currentLocation;

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.initialLocation;
    _selectedLocation = widget.initialLocation;
  }

  void _onLocationSelected(LatLng point) {
    setState(() {
      _selectedLocation =
          '${point.latitude.toStringAsFixed(4)},${point.longitude.toStringAsFixed(4)}';
      _currentLocation = _selectedLocation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 800,
        height: 600,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Click on the map to select location',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Expanded(
              child: BaseMap(
                start: _currentLocation,
                end: _currentLocation,
                height: 500,
                width: 800,
                showRouteInfoOverlay: false,
                showZoomControls: true,
                title: 'Click to select location',
                accentColor: Theme.of(context).colorScheme.primary,
                isSelectable: true,
                onLocationSelected: _onLocationSelected,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Selected: $_selectedLocation',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.of(context).pop(_selectedLocation),
                        child: const Text('Use Selected'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
