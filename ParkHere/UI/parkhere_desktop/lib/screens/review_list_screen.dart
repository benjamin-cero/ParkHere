import 'package:flutter/material.dart';
import 'package:parkhere_desktop/layouts/master_screen.dart';
import 'package:parkhere_desktop/model/review.dart';
import 'package:parkhere_desktop/model/festival.dart';
import 'package:parkhere_desktop/model/search_result.dart';
import 'package:parkhere_desktop/providers/review_provider.dart';
import 'package:parkhere_desktop/providers/festival_provider.dart';
import 'package:parkhere_desktop/screens/review_details_screen.dart';
import 'package:parkhere_desktop/utils/base_pagination.dart';
import 'package:parkhere_desktop/utils/base_table.dart';
import 'package:parkhere_desktop/utils/base_textfield.dart';
import 'package:provider/provider.dart';

class ReviewListScreen extends StatefulWidget {
  const ReviewListScreen({super.key});

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  late ReviewProvider reviewProvider;
  late FestivalProvider festivalProvider;
  List<Festival> festivals = [];

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController festivalTitleController = TextEditingController();
  int? selectedRating;

  SearchResult<Review>? reviews;
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 10, 20, 50];

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;

    final filter = {
      'userFullName': usernameController.text,
      'festivalTitle': festivalTitleController.text,
      'minRating': selectedRating,
      'maxRating': selectedRating,
      'page': pageToFetch,
      'pageSize': pageSizeToUse,
      'includeTotalCount': true,
    };

    final result = await reviewProvider.get(filter: filter);
    setState(() {
      reviews = result;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      reviewProvider = context.read<ReviewProvider>();
      festivalProvider = context.read<FestivalProvider>();
      await _loadFestivals();
      await _performSearch(page: 0);
    });
  }

  Future<void> _loadFestivals() async {
    try {
      final result = await festivalProvider.get(
        filter: {
          'page': 0,
          'pageSize': 1000, // Get all festivals
          'includeTotalCount': false,
        },
      );
      if (result.items != null) {
        setState(() {
          festivals = result.items!;
        });
      }
    } catch (e) {
      // Handle error silently for now
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Reviews',
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
                    'Full Name',
                    prefixIcon: Icons.person,
                  ),
                  controller: usernameController,
                  onSubmitted: (_) => _performSearch(page: 0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  decoration: customTextFieldDecoration(
                    'Title',
                    prefixIcon: Icons.festival,
                  ),
                  controller: festivalTitleController,
                  onSubmitted: (_) => _performSearch(page: 0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<int>(
                  decoration: customTextFieldDecoration(
                    'Rating',
                    prefixIcon: Icons.star,
                  ),
                  value: selectedRating,
                  items: [
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text('All Ratings'),
                    ),
                    ...List.generate(5, (index) => index + 1).map(
                      (rating) => DropdownMenuItem<int>(
                        value: rating,
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // Keep row tight
                          children: [
                            Flexible(
                              child: Text('$rating'),
                            ), // Allow text to wrap or shrink
                            const SizedBox(width: 4),
                            ...List.generate(
                              rating,
                              (index) => const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedRating = value;
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
                      usernameController.clear();
                      setState(() {
                        festivalTitleController.clear();
                        selectedRating = null;
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final isEmpty =
        reviews == null || reviews!.items == null || reviews!.items!.isEmpty;
    final int totalCount = reviews?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage >= totalPages - 1 || totalPages == 0;

    return SingleChildScrollView(
      child: Column(
        children: [
          BaseTable(
            icon: Icons.rate_review,
            title: 'Reviews',
            width: 1200,
            height: 423,
            columnWidths: [
              200, // Festival
              150, // Full Name
              100, // Rating
              300, // Comment
              150, // Date
              100, // Actions
            ],
            columns: const [
              DataColumn(
                label: Text(
                  'Festival',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Full Name',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Rating',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Comment',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Date',
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
                : reviews!.items!
                      .map(
                        (e) => DataRow(
                          cells: [
                            DataCell(
                              Text(
                                e.festivalTitle,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            DataCell(
                              Text(
                                e.userFullName,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  ...List.generate(
                                    e.rating,
                                    (index) => const Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Text(
                                e.comment ?? 'No comment',
                                style: const TextStyle(fontSize: 15),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DataCell(
                              Text(
                                '${e.createdAt.day}/${e.createdAt.month}/${e.createdAt.year}',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            DataCell(
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ReviewDetailsScreen(review: e),
                                      settings: const RouteSettings(
                                        name: 'ReviewDetailsScreen',
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
                            ),
                          ],
                        ),
                      )
                      .toList(),
            emptyIcon: Icons.rate_review,
            emptyText: 'No reviews found.',
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
