import 'package:flutter/material.dart';
import 'package:parkhere_desktop/layouts/master_screen.dart';
import 'package:parkhere_desktop/model/organizer.dart';
import 'package:parkhere_desktop/model/search_result.dart';
import 'package:parkhere_desktop/providers/organizer_provider.dart';
import 'package:parkhere_desktop/screens/organizer_details_screen.dart';
import 'package:parkhere_desktop/utils/base_cards_grid.dart';
import 'package:parkhere_desktop/utils/base_pagination.dart';
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
  final ScrollController _scrollController = ScrollController();
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
  void dispose() {
    _scrollController.dispose();
    nameController.dispose();
    super.dispose();
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
            child: TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              onSubmitted: (_) => _performSearch(page: 0),
              decoration: InputDecoration(
                hintText: "Search organizers...",
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
                  builder: (context) => const OrganizerDetailsScreen(),
                  settings: const RouteSettings(name: 'OrganizerDetailsScreen'),
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
            label: const Text("Add Organizer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    if (organizers == null || organizers!.items == null || organizers!.items!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text("No organizers found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
          ],
        ),
      );
    }

    final int totalCount = organizers?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();

    return BaseCardsGrid(
      controller: _scrollController,
      items: organizers!.items!.map((e) {
        return BaseGridCardItem(
          title: e.name,
          subtitle: e.contactInfo ?? "No contact info",
          isActive: e.isActive,
          data: {
            Icons.info_outline: e.isActive ? "Active Organizer" : "Inactive",
          },
          actions: [
            BaseGridAction(
              label: "Details",
              icon: Icons.edit_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrganizerDetailsScreen(item: e),
                    settings: const RouteSettings(name: 'OrganizerDetailsScreen'),
                  ),
                );
              },
              isPrimary: true,
            ),
          ],
        );
      }).toList(),
      pagination: (organizers != null && totalCount > 0)
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
