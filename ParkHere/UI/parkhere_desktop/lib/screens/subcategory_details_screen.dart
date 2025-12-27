import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:parkhere_desktop/layouts/master_screen.dart';
import 'package:parkhere_desktop/model/category.dart';
import 'package:parkhere_desktop/model/subcategory.dart';
import 'package:parkhere_desktop/providers/category_provider.dart';
import 'package:parkhere_desktop/providers/subcategory_provider.dart';
import 'package:parkhere_desktop/screens/subcategory_list_screen.dart';
import 'package:parkhere_desktop/utils/base_textfield.dart';
import 'package:provider/provider.dart';

class SubcategoryDetailsScreen extends StatefulWidget {
  final Subcategory? item;
  const SubcategoryDetailsScreen({super.key, this.item});

  @override
  State<SubcategoryDetailsScreen> createState() =>
      _SubcategoryDetailsScreenState();
}

class _SubcategoryDetailsScreenState extends State<SubcategoryDetailsScreen> {
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  late SubcategoryProvider subcategoryProvider;
  late CategoryProvider categoryProvider;
  Map<String, dynamic> initialValue = {};
  bool _isLoadingCategories = true;
  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    subcategoryProvider = Provider.of<SubcategoryProvider>(
      context,
      listen: false,
    );
    categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    initialValue = {
      'name': widget.item?.name ?? '',
      'description': widget.item?.description ?? '',
      'isActive': widget.item?.isActive ?? true,
      'categoryId': widget.item?.categoryId ?? 0,
    };
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() => _isLoadingCategories = true);
      final result = await categoryProvider.get();
      _categories = result.items ?? [];
      if (_categories.isNotEmpty) {
        if (widget.item != null) {
          try {
            _selectedCategory = _categories.firstWhere(
              (c) => c.id == widget.item!.categoryId,
              orElse: () => _categories.first,
            );
          } catch (_) {
            _selectedCategory = _categories.first;
          }
        } else {
          _selectedCategory = _categories.first;
        }
      }
    } catch (_) {
      _categories = [];
    } finally {
      setState(() => _isLoadingCategories = false);
    }
  }

  Widget _buildCategoryDropdown() {
    if (_isLoadingCategories) {
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
            Text('Loading categories...'),
          ],
        ),
      );
    }
    if (_categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          'No categories available',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
    return DropdownButtonFormField<Category>(
      value: _selectedCategory,
      decoration: customTextFieldDecoration(
        'Category',
        prefixIcon: Icons.category_outlined,
      ),
      items: _categories
          .map(
            (category) => DropdownMenuItem<Category>(
              value: category,
              child: Text(category.name),
            ),
          )
          .toList(),
      onChanged: (Category? value) {
        setState(() {
          _selectedCategory = value;
          initialValue['categoryId'] = value?.id ?? 0;
        });
      },
      validator: (value) => value == null ? 'Please select a category' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: widget.item != null ? 'Edit Subcategory' : 'Add Subcategory',
      showBackButton: true,
      child: _buildForm(),
    );
  }

  Widget _buildForm() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: FormBuilder(
              key: formKey,
              initialValue: initialValue,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                        tooltip: 'Go back',
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.category,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        widget.item != null
                            ? 'Edit Subcategory'
                            : 'Add New Subcategory',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  FormBuilderTextField(
                    name: 'name',
                    decoration: customTextFieldDecoration(
                      'Subcategory Name',
                      prefixIcon: Icons.text_fields,
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  _buildCategoryDropdown(),
                  const SizedBox(height: 24),

                  FormBuilderTextField(
                    name: 'description',
                    decoration: customTextFieldDecoration(
                      'Description',
                      prefixIcon: Icons.notes,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  FormBuilderSwitch(
                    name: 'isActive',
                    title: const Text('Active'),
                    initialValue: initialValue['isActive'] as bool? ?? true,
                  ),
                  const SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.of(context).pop(),
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
                                  if (_selectedCategory == null) {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Validation Error'),
                                        content: const Text(
                                          'Please select a category',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                    return;
                                  }
                                  setState(() => _isSaving = true);
                                  final request = Map<String, dynamic>.from(
                                    formKey.currentState?.value ?? {},
                                  );
                                  request['categoryId'] = _selectedCategory!.id;
                                  try {
                                    if (widget.item == null) {
                                      await subcategoryProvider.insert(request);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Subcategory created successfully',
                                          ),
                                          backgroundColor: Colors.green,
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    } else {
                                      await subcategoryProvider.update(
                                        widget.item!.id,
                                        request,
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Subcategory updated successfully',
                                          ),
                                          backgroundColor: Colors.green,
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    }
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SubcategoryListScreen(),
                                        settings: const RouteSettings(
                                          name: 'SubcategoryListScreen',
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Error'),
                                        content: Text(
                                          e.toString().replaceFirst(
                                            'Exception: ',
                                            '',
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                  } finally {
                                    if (mounted)
                                      setState(() => _isSaving = false);
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
