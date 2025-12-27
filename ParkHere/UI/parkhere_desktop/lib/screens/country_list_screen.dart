import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:parkhere_desktop/layouts/master_screen.dart';
import 'package:parkhere_desktop/model/country.dart';
import 'package:parkhere_desktop/model/search_result.dart';
import 'package:parkhere_desktop/providers/country_provider.dart';
import 'package:parkhere_desktop/screens/country_details_screen.dart';
import 'package:parkhere_desktop/utils/base_table.dart';
import 'package:parkhere_desktop/utils/base_pagination.dart';
import 'package:parkhere_desktop/utils/base_textfield.dart';
import 'package:provider/provider.dart';

class CountryListScreen extends StatefulWidget {
  const CountryListScreen({super.key});

  @override
  State<CountryListScreen> createState() => _CountryListScreenState();
}

class _CountryListScreenState extends State<CountryListScreen> {
  late CountryProvider countryProvider;

  TextEditingController nameController = TextEditingController();

  SearchResult<Country>? countries;
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 7, 10, 20, 50];

  // Search for countries with ENTER key, not only when button is clicked
  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;
    var filter = {
      "name": nameController.text,
      "page": pageToFetch,
      "pageSize": pageSizeToUse,
      "includeTotalCount": true, // Ensure backend returns total count
    };
    debugPrint(filter.toString());
    var countries = await countryProvider.get(filter: filter);
    debugPrint(countries.items?.firstOrNull?.name);
    setState(() {
      this.countries = countries;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  void initState() {
    super.initState();
    // Delay to ensure context is available for Provider
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      countryProvider = context.read<CountryProvider>();
      await _performSearch(page: 0);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Countries",
      child: SingleChildScrollView(
        child: Center(
          child: Column(children: [_buildSearch(), _buildResultView()]),
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
          ElevatedButton(onPressed: _performSearch, child: Text("Search")),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CountryDetailsScreen(),
                  settings: const RouteSettings(name: 'CountryDetailsScreen'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A), // Blue
              foregroundColor: Colors.white, // white text & icon
            ),
            child: const Row(children: [Icon(Icons.add), Text('Add Country')]),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final isEmpty =
        countries == null ||
        countries!.items == null ||
        countries!.items!.isEmpty;
    final int totalCount = countries?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage >= totalPages - 1 || totalPages == 0;
    return Column(
      children: [
        BaseTable(
          icon: Icons.flag_outlined,
          title: "Countries",
          width: 600,
          height: 423,
          columns: [
            DataColumn(
              label: Text(
                "Flag",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Name",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
          rows: isEmpty
              ? []
              : countries!.items!
                    .map(
                      (e) => DataRow(
                        onSelectChanged: (value) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CountryDetailsScreen(country: e),
                              settings: const RouteSettings(
                                name: 'CountryDetailsScreen',
                              ),
                            ),
                          );
                        },
                        cells: [
                          DataCell(
                            e.flag != null
                                ? Container(
                                    width: 40,
                                    height: 30,
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
                                        base64Decode(e.flag!),
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[200],
                                                child: Icon(
                                                  Icons.flag,
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
                                    height: 30,
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
                            Text(e.name, style: TextStyle(fontSize: 15)),
                          ),
                        ],
                      ),
                    )
                    .toList(),
          emptyIcon: Icons.flag,
          emptyText: "No countries found.",
          emptySubtext: "Try adjusting your search or add a new country.",
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
    );
  }
}
