import 'package:flutter/material.dart';
import 'package:parkhere_desktop/layouts/master_screen.dart';
import 'package:parkhere_desktop/model/city.dart';
import 'package:parkhere_desktop/model/country.dart';
import 'package:parkhere_desktop/model/search_result.dart';
import 'package:parkhere_desktop/providers/city_provider.dart';
import 'package:parkhere_desktop/providers/country_provider.dart';
import 'package:parkhere_desktop/screens/city_details_screen.dart';
import 'package:parkhere_desktop/utils/base_table.dart';
import 'package:parkhere_desktop/utils/base_pagination.dart';
import 'package:parkhere_desktop/utils/base_textfield.dart';
import 'package:provider/provider.dart';

class CityListScreen extends StatefulWidget {
  const CityListScreen({super.key});

  @override
  State<CityListScreen> createState() => _CityListScreenState();
}

class _CityListScreenState extends State<CityListScreen> {
  late CityProvider cityProvider;
  late CountryProvider countryProvider;

  TextEditingController nameController = TextEditingController();
  Country? _selectedCountry;
  bool _isLoadingCountries = true;
  List<Country> _countries = [];

  SearchResult<City>? cities;
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 7, 10, 20, 50];

  // Search for cities with ENTER key, not only when button is clicked
  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;
    var filter = {
      "name": nameController.text,
      "countryId": _selectedCountry?.id,
      "page": pageToFetch,
      "pageSize": pageSizeToUse,
      "includeTotalCount": true, // Ensure backend returns total count
    };
    debugPrint(filter.toString());
    var cities = await cityProvider.get(filter: filter);
    debugPrint(cities.items?.firstOrNull?.name);
    setState(() {
      this.cities = cities;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  void initState() {
    super.initState();
    // Delay to ensure context is available for Provider
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      cityProvider = context.read<CityProvider>();
      countryProvider = context.read<CountryProvider>();
      await _loadCountries();
      await _performSearch(page: 0);
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
      decoration: customTextFieldDecoration(
        "All Countries",
        prefixIcon: Icons.flag,
      ),
      items: [
        // Add "All Countries" option
        DropdownMenuItem<Country>(value: null, child: Text("All Countries")),
        // Add country options
        ..._countries.map((country) {
          return DropdownMenuItem<Country>(
            value: country,
            child: Text(country.name),
          );
        }).toList(),
      ],
      onChanged: (Country? value) {
        setState(() {
          _selectedCountry = value;
        });
        // Automatically search when country selection changes
        _performSearch(page: 0);
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Cities",
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
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: customTextFieldDecoration(
                "Name",
                prefixIcon: Icons.search,
              ),
              controller: nameController,
              onSubmitted: (value) => _performSearch(),
            ),
          ),
          SizedBox(width: 10),
          // Country dropdown filter
          SizedBox(width: 350, child: _buildCountryDropdown()),
          SizedBox(width: 10),
          ElevatedButton(onPressed: _performSearch, child: Text("Search")),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CityDetailsScreen(),
                  settings: const RouteSettings(name: 'CityDetailsScreen'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A1B9A), // Purple
              foregroundColor: Colors.white, // white text & icon
            ),
            child: const Row(
              children: [Icon(Icons.add), Text('Add City')],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final isEmpty =
        cities == null || cities!.items == null || cities!.items!.isEmpty;
    final int totalCount = cities?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage >= totalPages - 1 || totalPages == 0;
    return SingleChildScrollView(
      child: Column(
        children: [
          BaseTable(
            icon: Icons.location_city_outlined,
            title: "Cities",
            width: 600,
            height: 423,
            columns: [
              DataColumn(
                label: Text(
                  "Name",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  "Country",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
            rows: isEmpty
                ? []
                : cities!.items!
                      .map(
                        (e) => DataRow(
                          onSelectChanged: (value) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CityDetailsScreen(city: e),
                                settings: const RouteSettings(
                                  name: 'CityDetailsScreen',
                                ),
                              ),
                            );
                          },
                          cells: [
                            DataCell(
                              Text(e.name, style: TextStyle(fontSize: 15)),
                            ),
                            DataCell(
                              Text(
                                e.countryName,
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
            emptyIcon: Icons.location_city,
            emptyText: "No cities found.",
            emptySubtext: "Try adjusting your search or add a new city.",
          ),
          SizedBox(height: 30),
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
