import 'package:flutter/material.dart';
import 'package:parkhere_desktop/layouts/master_screen.dart';
import 'package:parkhere_desktop/model/festival.dart';
import 'package:parkhere_desktop/model/subcategory.dart';
import 'package:parkhere_desktop/model/search_result.dart';
import 'package:parkhere_desktop/providers/festival_provider.dart';
import 'package:parkhere_desktop/providers/subcategory_provider.dart';
import 'package:parkhere_desktop/screens/festival_details_screen.dart';
import 'package:parkhere_desktop/screens/festival_upsert_screen.dart';
import 'package:parkhere_desktop/utils/base_cards_grid.dart';
import 'package:parkhere_desktop/utils/base_pagination.dart';
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
  final ScrollController _scrollController = ScrollController();

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

  @override
  void dispose() {
    _scrollController.dispose();
    titleController.dispose();
    cityController.dispose();
    super.dispose();
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  onSubmitted: (_) => _performSearch(page: 0),
                  decoration: InputDecoration(
                    hintText: "Search festivals...",
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
                child: TextField(
                  controller: cityController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  onSubmitted: (_) => _performSearch(page: 0),
                  decoration: InputDecoration(
                    hintText: "City...",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    prefixIcon: Icon(Icons.location_city, color: Colors.white.withOpacity(0.7), size: 18),
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
                flex: 1,
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: selectedSubcategoryId,
                      dropdownColor: const Color(0xFF1E3A8A),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 20),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13),
                      hint: Text("Subcategory", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<int?>(value: null, child: Text("All")),
                        ...subcategories.map(
                          (s) => DropdownMenuItem<int?>(value: s.id, child: Text(s.name)),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() => selectedSubcategoryId = val);
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
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                onPressed: () {
                  titleController.clear();
                  cityController.clear();
                  setState(() => selectedSubcategoryId = null);
                  _performSearch(page: 0);
                },
                tooltip: "Reset",
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FestivalUpsertScreen(),
                      settings: const RouteSettings(name: 'FestivalUpsertScreen'),
                    ),
                  );
                  if (result == true) await _performSearch(page: _currentPage);
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
        ],
      ),
    );
  }

  Widget _buildResultView() {
    if (festivals == null || festivals!.items == null || festivals!.items!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.festival_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text("No festivals found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
          ],
        ),
      );
    }

    final int totalCount = festivals?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();

    return BaseCardsGrid(
      controller: _scrollController,
      items: festivals!.items!.map((e) {
        return BaseGridCardItem(
          title: e.title,
          subtitle: e.cityName,
          imageUrl: e.logo,
          isActive: e.isActive,
          data: {
            Icons.category_outlined: e.subcategoryName,
            Icons.calendar_today_outlined: e.dateRange,
          },
          actions: [
            BaseGridAction(
              label: "Details",
              icon: Icons.info_outline,
              onPressed: () async {
                final full = await festivalProvider.getById(e.id);
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FestivalDetailsScreen(festival: full ?? e),
                    settings: const RouteSettings(name: 'FestivalDetailsScreen'),
                  ),
                );
              },
              isPrimary: false,
            ),
            BaseGridAction(
              label: "Edit",
              icon: Icons.edit_outlined,
              onPressed: () async {
                final full = await festivalProvider.getById(e.id);
                if (!mounted) return;
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FestivalUpsertScreen(festival: full ?? e),
                    settings: const RouteSettings(name: 'FestivalUpsertScreen'),
                  ),
                );
                if (result == true) await _performSearch(page: _currentPage);
              },
              isPrimary: true,
            ),
          ],
        );
      }).toList(),
      pagination: (festivals != null && totalCount > 0)
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
