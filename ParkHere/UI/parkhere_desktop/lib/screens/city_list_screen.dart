import 'package:flutter/material.dart';
import 'package:parkhere_desktop/layouts/master_screen.dart';
import 'package:parkhere_desktop/model/city.dart';
import 'package:parkhere_desktop/model/search_result.dart';
import 'package:parkhere_desktop/providers/city_provider.dart';
import 'package:parkhere_desktop/screens/city_details_screen.dart';
import 'package:parkhere_desktop/utils/base_cards_grid.dart';
import 'package:parkhere_desktop/utils/base_pagination.dart';
import 'package:parkhere_desktop/utils/base_search_bar.dart';
import 'package:provider/provider.dart';

class CityListScreen extends StatefulWidget {
  const CityListScreen({super.key});

  @override
  State<CityListScreen> createState() => _CityListScreenState();
}

class _CityListScreenState extends State<CityListScreen> {
  late CityProvider cityProvider;
  final TextEditingController nameController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  SearchResult<City>? cities;
  int _currentPage = 0;
  int _pageSize = 10;
  bool _isLoading = false;
  final List<int> _pageSizeOptions = [5, 10, 20, 50];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      cityProvider = context.read<CityProvider>();
      await _performSearch(page: 0);
    });
  }

  Future<void> _performSearch({int? page, int? pageSize}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final int pageToFetch = page ?? _currentPage;
      final int pageSizeToUse = pageSize ?? _pageSize;
      
      var filter = {
        "name": nameController.text,
        "page": pageToFetch,
        "pageSize": pageSizeToUse,
        "includeTotalCount": true,
      };
      
      var result = await cityProvider.get(filter: filter);
      
      if (mounted) {
        setState(() {
          cities = result;
          _currentPage = pageToFetch;
          _pageSize = pageSizeToUse;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading cities: ${e.toString()}")),
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Cities",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          Expanded(child: _buildResultView()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Manage Cities",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "View and manage the list of available cities",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CityDetailsScreen(),
                  settings: const RouteSettings(name: 'CityDetailsScreen'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              "Add New City",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return Column(
      children: [
        // 2. Search Bar
        BaseSearchBar(
          fields: [
            BaseSearchField(
              controller: nameController,
              hint: "Search cities by name...",
              icon: Icons.search,
              onSubmitted: () => _performSearch(page: 0),
            ),
          ],
          onSearch: () => _performSearch(page: 0),
          onClear: () {
            nameController.clear();
            _performSearch(page: 0);
          },
        ),

        // List Content
        Expanded(
          child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildCityList(),
        ),
      ],
    );
  }

  Widget _buildCityList() {
    if (cities == null || cities!.items == null || cities!.items!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_city_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "No cities found",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Try adjusting your search criteria",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    final int totalPages = ((cities?.totalCount ?? 0) / _pageSize).ceil();

    return BaseCardsGrid(
      controller: _scrollController,
      childAspectRatio: 1.6,
      items: cities!.items!.map((city) {
        return BaseGridCardItem(
          title: city.name,
          subtitle: "City",
          imageUrl: null, // No image for city yet
          data: const {},
          actions: [
            BaseGridAction(
              label: "Edit",
              icon: Icons.edit,
              onPressed: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CityDetailsScreen(city: city),
                    settings: const RouteSettings(name: 'CityDetailsScreen'),
                  ),
                );
              },
              isPrimary: true,
            ),
          ],
        );
      }).toList(),
      pagination: (cities != null && (cities?.totalCount ?? 0) > 0)
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
              onPageSelected: (page) => _performSearch(page: page),
            )
          : null,
    );
  }
}

