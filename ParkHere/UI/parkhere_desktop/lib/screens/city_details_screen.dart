import 'package:flutter/material.dart';
import 'package:parkhere_desktop/layouts/master_screen.dart';
import 'package:parkhere_desktop/model/city.dart';
import 'package:parkhere_desktop/model/country.dart';
import 'package:parkhere_desktop/providers/city_provider.dart';
import 'package:parkhere_desktop/providers/country_provider.dart';
import 'package:parkhere_desktop/utils/base_textfield.dart';
import 'package:parkhere_desktop/screens/city_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class CityDetailsScreen extends StatefulWidget {
  final City? city;

  const CityDetailsScreen({super.key, this.city});

  @override
  State<CityDetailsScreen> createState() => _CityDetailsScreenState();
}

class _CityDetailsScreenState extends State<CityDetailsScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late CityProvider cityProvider;
  late CountryProvider countryProvider;
  bool isLoading = true;
  bool _isLoadingCountries = true;
  bool _isSaving = false;
  List<Country> _countries = [];
  Country? _selectedCountry;

  @override
  void initState() {
    super.initState();
    cityProvider = Provider.of<CityProvider>(context, listen: false);
    countryProvider = Provider.of<CountryProvider>(context, listen: false);
    _initialValue = {
      "name": widget.city?.name ?? '',
      "countryId": widget.city?.countryId ?? 0,
    };
    initFormData();
    _loadCountries();
  }

  initFormData() async {
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadCountries() async {
    try {
      setState(() {
        _isLoadingCountries = true;
      });

      final result = await countryProvider.get();
      if (result.items != null && result.items!.isNotEmpty) {
        setState(() {
          _countries = result.items!;
          _isLoadingCountries = false;
        });
        _setDefaultCountrySelection();
      } else {
        setState(() {
          _countries = [];
          _isLoadingCountries = false;
        });
      }
    } catch (e) {
      setState(() {
        _countries = [];
        _isLoadingCountries = false;
      });
    }
  }

  void _setDefaultCountrySelection() {
    if (_countries.isNotEmpty) {
      if (widget.city != null) {
        try {
          _selectedCountry = _countries.firstWhere(
            (country) => country.id == widget.city!.countryId,
            orElse: () => _countries.first,
          );
        } catch (e) {
          _selectedCountry = _countries.first;
        }
      } else {
        _selectedCountry = _countries.first;
      }
      setState(() {});
    }
  }

  Widget _buildCountryDropdown() {
    if (_isLoadingCountries) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text(
              "Loading countries...",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (_countries.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Text(
          "No countries available",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return DropdownButtonFormField<Country>(
      value: _selectedCountry,
      decoration: customTextFieldDecoration("Country", prefixIcon: Icons.flag),
      items: _countries.map((country) {
        return DropdownMenuItem<Country>(
          value: country,
          child: Text(country.name),
        );
      }).toList(),
      onChanged: (Country? value) {
        setState(() {
          _selectedCountry = value;
          _initialValue['countryId'] = value?.id ?? 0;
        });
      },
      validator: (value) {
        if (value == null) {
          return "Please select a country";
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: widget.city != null ? "Edit City" : "Add City",
      showBackButton: true,
      child: _buildForm(),
    );
  }

  Widget _buildSaveButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade300,
            foregroundColor: Colors.black87,
          ),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _isSaving
              ? null
              : () async {
                  formKey.currentState?.saveAndValidate();
                  if (formKey.currentState?.validate() ?? false) {
                    if (_selectedCountry == null) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Validation Error'),
                          content: const Text('Please select a country'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                      return;
                    }

                    setState(() => _isSaving = true);
                    var request = Map.from(formKey.currentState?.value ?? {});
                    request['countryId'] = _selectedCountry!.id;

                    try {
                      if (widget.city == null) {
                        await cityProvider.insert(request);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('City created successfully'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      } else {
                        await cityProvider.update(widget.city!.id, request);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('City updated successfully'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const CityListScreen(),
                          settings: const RouteSettings(name: 'CityListScreen'),
                        ),
                      );
                    } catch (e) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Error'),
                          content: Text(
                            e.toString().replaceFirst('Exception: ', ''),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    } finally {
                      if (mounted) setState(() => _isSaving = false);
                    }
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildForm() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 500),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: FormBuilder(
              key: formKey,
              initialValue: _initialValue,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with back button
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.arrow_back),
                        tooltip: 'Go back',
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.location_city,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: 16),
                      Text(
                        widget.city != null ? "Edit City" : "Add New City",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // City Name
                  FormBuilderTextField(
                    name: "name",
                    decoration: customTextFieldDecoration(
                      "City Name",
                      prefixIcon: Icons.location_on,
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.match(
                        RegExp(r'^[\p{L} ]+$', unicode: true),
                        errorText:
                            'Only letters (including international), and spaces allowed',
                      ),
                    ]),
                  ),
                  SizedBox(height: 24),

                  // Country Dropdown
                  _buildCountryDropdown(),
                  SizedBox(height: 50),

                  // Save and Cancel Buttons
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
