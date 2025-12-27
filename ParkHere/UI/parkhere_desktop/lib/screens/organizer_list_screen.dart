import 'package:flutter/material.dart';
import 'package:parkhere_desktop/layouts/master_screen.dart';
import 'package:parkhere_desktop/model/organizer.dart';
import 'package:parkhere_desktop/model/search_result.dart';
import 'package:parkhere_desktop/providers/organizer_provider.dart';
import 'package:parkhere_desktop/screens/organizer_details_screen.dart';
import 'package:parkhere_desktop/utils/base_pagination.dart';
import 'package:parkhere_desktop/utils/base_table.dart';
import 'package:parkhere_desktop/utils/base_textfield.dart';
import 'package:provider/provider.dart';

class OrganizerListScreen extends StatefulWidget {
  const OrganizerListScreen({super.key});

  @override
  State<OrganizerListScreen> createState() => _OrganizerListScreenState();
}

class _OrganizerListScreenState extends State<OrganizerListScreen> {
  late OrganizerProvider organizerProvider;

  final TextEditingController nameController = TextEditingController();
  SearchResult<Organizer>? organizers;
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 7, 10, 20, 50];

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;
    final filter = {
      'name': nameController.text,
      'page': pageToFetch,
      'pageSize': pageSizeToUse,
      'includeTotalCount': true,
    };
    final result = await organizerProvider.get(filter: filter);
    setState(() {
      organizers = result;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      organizerProvider = context.read<OrganizerProvider>();
      await _performSearch(page: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Organizers',
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
                  builder: (context) => const OrganizerDetailsScreen(),
                  settings: const RouteSettings(name: 'OrganizerDetailsScreen'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A), // Blue
              foregroundColor: Colors.white, // white text & icon
            ),
            child: const Row(
              children: [Icon(Icons.add), Text('Add Organizer')],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final isEmpty =
        organizers == null ||
        organizers!.items == null ||
        organizers!.items!.isEmpty;
    final int totalCount = organizers?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage >= totalPages - 1 || totalPages == 0;

    return SingleChildScrollView(
      child: Column(
        children: [
          BaseTable(
            icon: Icons.groups_outlined,
            title: 'Organizers',
            width: 1000,
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
                  'Contact',
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
                : organizers!.items!
                      .map(
                        (e) => DataRow(
                          onSelectChanged: (_) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    OrganizerDetailsScreen(item: e),
                                settings: const RouteSettings(
                                  name: 'OrganizerDetailsScreen',
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
                                e.contactInfo ?? '',
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
            emptyIcon: Icons.groups_2_outlined,
            emptyText: 'No organizers found.',
            emptySubtext: 'Try adjusting your search or add a new organizer.',
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
