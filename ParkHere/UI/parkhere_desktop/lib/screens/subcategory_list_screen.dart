import 'package:flutter/material.dart';
import 'package:parkhere_desktop/layouts/master_screen.dart';
import 'package:parkhere_desktop/model/category.dart';
import 'package:parkhere_desktop/model/search_result.dart';
import 'package:parkhere_desktop/model/subcategory.dart';
import 'package:parkhere_desktop/providers/category_provider.dart';
import 'package:parkhere_desktop/providers/subcategory_provider.dart';
import 'package:parkhere_desktop/screens/subcategory_details_screen.dart';
import 'package:parkhere_desktop/utils/base_pagination.dart';
import 'package:parkhere_desktop/utils/base_table.dart';
import 'package:parkhere_desktop/utils/base_textfield.dart';
import 'package:provider/provider.dart';

class SubcategoryListScreen extends StatefulWidget {
  const SubcategoryListScreen({super.key});

  @override
  State<SubcategoryListScreen> createState() => _SubcategoryListScreenState();
}

class _SubcategoryListScreenState extends State<SubcategoryListScreen> {
  late SubcategoryProvider subcategoryProvider;
  late CategoryProvider categoryProvider;

  final TextEditingController nameController = TextEditingController();
  Category? _selectedCategory;
  bool _isLoadingCategories = true;
  List<Category> _categories = [];

  SearchResult<Subcategory>? subcategories;
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 7, 10, 20, 50];

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;
    final filter = {
      'name': nameController.text,
      'categoryId': _selectedCategory?.id,
      'page': pageToFetch,
      'pageSize': pageSizeToUse,
      'includeTotalCount': true,
    };
    final result = await subcategoryProvider.get(filter: filter);
    setState(() {
      subcategories = result;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      subcategoryProvider = context.read<SubcategoryProvider>();
      categoryProvider = context.read<CategoryProvider>();
      await _loadCategories();
      await _performSearch(page: 0);
    });
  }

  Future<void> _loadCategories() async {
    try {
      setState(() => _isLoadingCategories = true);
      final result = await categoryProvider.get();
      setState(() {
        _categories = result.items ?? [];
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _categories = [];
        _isLoadingCategories = false;
      });
    }
  }

  Widget _buildCategoryDropdown({bool asFilter = false}) {
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
        asFilter ? 'All Categories' : 'Category',
        prefixIcon: Icons.category_outlined,
      ),
      items: [
        if (asFilter)
          DropdownMenuItem<Category>(
            value: null,
            child: const Text('All Categories'),
          ),
        ..._categories.map(
          (c) => DropdownMenuItem<Category>(value: c, child: Text(c.name)),
        ),
      ],
      onChanged: (Category? value) {
        setState(() => _selectedCategory = value);
        if (asFilter) _performSearch(page: 0);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Subcategories',
      child: Center(
        child: Column(
          children: [
            _buildSearch(),
            Expanded(child: _buildResultView()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: customTextFieldDecoration(
                'Name',
                prefixIcon: Icons.search,
              ),
              controller: nameController,
              onSubmitted: (_) => _performSearch(page: 0),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(width: 350, child: _buildCategoryDropdown(asFilter: true)),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: _performSearch,
            child: const Text('Search'),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubcategoryDetailsScreen(),
                  settings: const RouteSettings(
                    name: 'SubcategoryDetailsScreen',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A), // Blue
              foregroundColor: Colors.white, // white text & icon
            ),
            child: const Row(
              children: [Icon(Icons.add), Text('Add Subcategory')],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final isEmpty =
        subcategories?.items == null || subcategories!.items!.isEmpty;
    final int totalCount = subcategories?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage >= totalPages - 1 || totalPages == 0;

    return SingleChildScrollView(
      child: Column(
        children: [
          BaseTable(
            icon: Icons.category_outlined,
            title: 'Subcategories',
            width: 1100,
            height: 423,
            columns: const [
              DataColumn(
                label: Text(
                  'Name',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Category',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Active',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
            rows: isEmpty
                ? []
                : subcategories!.items!
                      .map(
                        (e) => DataRow(
                          onSelectChanged: (_) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SubcategoryDetailsScreen(item: e),
                                settings: const RouteSettings(
                                  name: 'SubcategoryDetailsScreen',
                                ),
                              ),
                            );
                          },
                          cells: [
                            DataCell(
                              Text(
                                e.name,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            DataCell(
                              Text(
                                e.categoryName,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            DataCell(
                              Text(
                                e.description ?? '',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            DataCell(
                              Icon(
                                e.isActive ? Icons.check_circle : Icons.cancel,
                                color: e.isActive ? Colors.green : Colors.red,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
            emptyIcon: Icons.category,
            emptyText: 'No subcategories found.',
            emptySubtext: 'Try adjusting your search or add a new subcategory.',
          ),
          const SizedBox(height: 30),
          BasePagination(
            currentPage: _currentPage,
            totalPages: totalPages,
            onPrevious: isFirstPage
                ? null
                : () => _performSearch(page: _currentPage - 1),
            onNext: isLastPage
                ? null
                : () => _performSearch(page: _currentPage + 1),
            showPageSizeSelector: true,
            pageSize: _pageSize,
            pageSizeOptions: _pageSizeOptions,
            onPageSizeChanged: (newSize) {
              if (newSize != null && newSize != _pageSize) {
                _performSearch(page: 0, pageSize: newSize);
              }
            },
          ),
        ],
      ),
    );
  }
}
