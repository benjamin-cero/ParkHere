import 'package:flutter/material.dart';
import 'package:parkhere_desktop/layouts/master_screen.dart';
import 'package:parkhere_desktop/model/category.dart';
import 'package:parkhere_desktop/model/search_result.dart';
import 'package:parkhere_desktop/model/subcategory.dart';
import 'package:parkhere_desktop/providers/category_provider.dart';
import 'package:parkhere_desktop/providers/subcategory_provider.dart';
import 'package:parkhere_desktop/screens/subcategory_details_screen.dart';
import 'package:parkhere_desktop/utils/base_cards_grid.dart';
import 'package:parkhere_desktop/utils/base_pagination.dart';
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
  final ScrollController _scrollController = ScrollController();

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

  @override
  void dispose() {
    _scrollController.dispose();
    nameController.dispose();
    super.dispose();
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
      child: Column(
        children: [
          _buildSearch(),
          Expanded(child: _buildResultView()),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1E3A8A), const Color(0xFF1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              onSubmitted: (_) => _performSearch(page: 0),
              decoration: InputDecoration(
                hintText: "Search subcategories...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7), size: 18),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Category?>(
                  value: _selectedCategory,
                  dropdownColor: const Color(0xFF1E3A8A),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 20),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13),
                  hint: Text("Category", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem<Category?>(value: null, child: Text("All Categories")),
                    ..._categories.map(
                      (c) => DropdownMenuItem<Category?>(value: c, child: Text(c.name)),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() => _selectedCategory = val);
                    _performSearch(page: 0);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _performSearch(page: 0),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1E3A8A),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text("Search", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubcategoryDetailsScreen(),
                  settings: const RouteSettings(name: 'SubcategoryDetailsScreen'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text("New", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    if (subcategories == null || subcategories!.items == null || subcategories!.items!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text("No subcategories found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
          ],
        ),
      );
    }

    final int totalCount = subcategories?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();

    return BaseCardsGrid(
      controller: _scrollController,
      items: subcategories!.items!.map((e) {
        return BaseGridCardItem(
          title: e.name,
          subtitle: e.categoryName,
          isActive: e.isActive,
          data: {
            Icons.description_outlined: e.description ?? "No description",
            Icons.info_outline: e.isActive ? "Active" : "Inactive",
          },
          actions: [
            BaseGridAction(
              label: "Details",
              icon: Icons.edit_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubcategoryDetailsScreen(item: e),
                    settings: const RouteSettings(name: 'SubcategoryDetailsScreen'),
                  ),
                );
              },
              isPrimary: true,
            ),
          ],
        );
      }).toList(),
      pagination: (subcategories != null && totalCount > 0)
          ? BasePagination(
              scrollController: _scrollController,
              currentPage: _currentPage,
              totalPages: totalPages,
              onPrevious: _currentPage > 0 ? () => _performSearch(page: _currentPage - 1) : null,
              onNext: _currentPage < totalPages - 1 ? () => _performSearch(page: _currentPage + 1) : null,
              showPageSizeSelector: true,
              pageSize: _pageSize,
              pageSizeOptions: _pageSizeOptions,
              onPageSizeChanged: (newSize) {
                if (newSize != null && newSize != _pageSize) {
                  _performSearch(page: 0, pageSize: newSize);
                }
              },
            )
          : null,
    );
  }
}
