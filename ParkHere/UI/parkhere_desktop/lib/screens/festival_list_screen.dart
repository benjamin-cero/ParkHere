import 'package:flutter/material.dart';
import 'package:parkhere_desktop/layouts/master_screen.dart';
import 'package:parkhere_desktop/model/festival.dart';
import 'package:parkhere_desktop/model/subcategory.dart';
import 'package:parkhere_desktop/model/search_result.dart';
import 'package:parkhere_desktop/providers/festival_provider.dart';
import 'package:parkhere_desktop/providers/subcategory_provider.dart';
import 'package:parkhere_desktop/screens/festival_details_screen.dart';
import 'package:parkhere_desktop/screens/festival_upsert_screen.dart';
import 'package:parkhere_desktop/utils/base_pagination.dart';
import 'package:parkhere_desktop/utils/base_table.dart';
import 'package:parkhere_desktop/utils/base_textfield.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class FestivalListScreen extends StatefulWidget {
  const FestivalListScreen({super.key});

  @override
  State<FestivalListScreen> createState() => _FestivalListScreenState();
}

class _FestivalListScreenState extends State<FestivalListScreen> {
  late FestivalProvider festivalProvider;
  late SubcategoryProvider subcategoryProvider;
  List<Subcategory> subcategories = [];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  int? selectedSubcategoryId;

  SearchResult<Festival>? festivals;
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 10, 20, 50];

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;

    final filter = {
      'title': titleController.text,
      'cityName': cityController.text,
      'subcategoryId': selectedSubcategoryId,
      'page': pageToFetch,
      'pageSize': pageSizeToUse,
      'includeTotalCount': true,
    };

    final result = await festivalProvider.getWithoutAssets(filter: filter);
    setState(() {
      festivals = result;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      festivalProvider = context.read<FestivalProvider>();
      subcategoryProvider = context.read<SubcategoryProvider>();
      await _loadSubcategories();
      await _performSearch(page: 0);
    });
  }

  Future<void> _loadSubcategories() async {
    try {
      final result = await subcategoryProvider.get(
        filter: {
          'page': 0,
          'pageSize': 1000, // Get all subcategories
          'includeTotalCount': false,
        },
      );
      if (result.items != null) {
        setState(() {
          subcategories = result.items!;
        });
      }
    } catch (e) {
      // Handle error silently for now
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Festivals',
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: customTextFieldDecoration(
                    'Title',
                    prefixIcon: Icons.festival,
                  ),
                  controller: titleController,
                  onSubmitted: (_) => _performSearch(page: 0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  decoration: customTextFieldDecoration(
                    'City',
                    prefixIcon: Icons.location_city,
                  ),
                  controller: cityController,
                  onSubmitted: (_) => _performSearch(page: 0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<int>(
                  decoration: customTextFieldDecoration(
                    'Subcategory',
                    prefixIcon: Icons.category,
                  ),
                  value: selectedSubcategoryId,
                  items: [
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text('All Subcategories'),
                    ),
                    ...subcategories.map(
                      (subcategory) => DropdownMenuItem<int>(
                        value: subcategory.id,
                        child: Text(subcategory.name),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedSubcategoryId = value;
                    });
                    _performSearch(page: 0);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _performSearch,
                    child: const Text('Search'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      titleController.clear();
                      cityController.clear();
                      setState(() {
                        selectedSubcategoryId = null;
                      });
                      _performSearch(page: 0);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.orange,
                    ),
                    child: const Text('Clear'),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FestivalUpsertScreen(),
                          settings: const RouteSettings(
                            name: 'FestivalUpsertScreen',
                          ),
                        ),
                      );
                      // Refresh the list if a festival was created/updated
                      if (result == true) {
                        await _performSearch(page: _currentPage);
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('New Festival'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A), // Blue
                      foregroundColor: Colors.white, // white text & icon
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final isEmpty =
        festivals == null ||
        festivals!.items == null ||
        festivals!.items!.isEmpty;
    final int totalCount = festivals?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage >= totalPages - 1 || totalPages == 0;

    return SingleChildScrollView(
      child: Column(
        children: [
          BaseTable(
            icon: Icons.festival,
            title: 'Festivals',
            width: 1400,
            height: 423,
            columnWidths: [
              65, // Logo
              250, // Title
              120, // Date Range

              130, // City
              125, // Subcategory

              73, // Status
              100, // Actions
            ],
            columns: const [
              DataColumn(
                label: Text(
                  'Logo',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Title',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Date Range',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),

              DataColumn(
                label: Text(
                  'City',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Subcategory',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),

              DataColumn(
                label: Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Actions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
            rows: isEmpty
                ? []
                : festivals!.items!
                      .map(
                        (e) => DataRow(
                          cells: [
                            DataCell(
                              e.logo != null
                                  ? Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.memory(
                                          base64Decode(e.logo!),
                                          fit: BoxFit.fitHeight,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[200],
                                                  child: Icon(
                                                    Icons.festival_outlined,
                                                    color: Colors.grey[400],
                                                    size: 20,
                                                  ),
                                                );
                                              },
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Icon(
                                        Icons.flag,
                                        color: Colors.grey[400],
                                        size: 20,
                                      ),
                                    ),
                            ),
                            DataCell(
                              Text(
                                e.title,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            DataCell(
                              Text(
                                e.dateRange,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),

                            DataCell(
                              Text(
                                e.cityName,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            DataCell(
                              Text(
                                e.subcategoryName,
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
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      final full = await festivalProvider
                                          .getById(e.id);
                                      if (!mounted) return;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FestivalDetailsScreen(
                                                festival: full ?? e,
                                              ),
                                          settings: const RouteSettings(
                                            name: 'FestivalDetailsScreen',
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.info_outline,
                                      color: Colors.blue,
                                    ),
                                    tooltip: 'View Details',
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () async {
                                      final full = await festivalProvider
                                          .getById(e.id);
                                      if (!mounted) return;
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FestivalUpsertScreen(
                                                festival: full ?? e,
                                              ),
                                          settings: const RouteSettings(
                                            name: 'FestivalUpsertScreen',
                                          ),
                                        ),
                                      );
                                      // Refresh the list if a festival was updated
                                      if (result == true) {
                                        await _performSearch(
                                          page: _currentPage,
                                        );
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.orange,
                                    ),
                                    tooltip: 'Edit Festival',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
            emptyIcon: Icons.festival,
            emptyText: 'No festivals found.',
            emptySubtext: 'Try adjusting your search criteria.',
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
