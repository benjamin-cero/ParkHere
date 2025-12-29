import 'package:flutter/material.dart';
import 'package:parkhere_desktop/layouts/master_screen.dart';
import 'package:parkhere_desktop/model/review.dart';
import 'package:parkhere_desktop/model/search_result.dart';
import 'package:parkhere_desktop/providers/review_provider.dart';
import 'package:parkhere_desktop/screens/review_details_screen.dart';
import 'package:parkhere_desktop/utils/base_cards_grid.dart';
import 'package:parkhere_desktop/utils/base_pagination.dart';
import 'package:parkhere_desktop/utils/base_search_bar.dart';
import 'package:provider/provider.dart';

class ReviewListScreen extends StatefulWidget {
  const ReviewListScreen({super.key});

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  late ReviewProvider reviewProvider;
  final ScrollController _scrollController = ScrollController();

  final TextEditingController usernameController = TextEditingController();
  int? selectedRating;

  SearchResult<Review>? reviews;
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 10, 20, 50];

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;

    try {
      final filter = {
        'name': usernameController.text,
        'rating': selectedRating,
        'page': pageToFetch,
        'pageSize': pageSizeToUse,
        'includeTotalCount': true,
        'includeUser': true,
        'includeParkingReservation': true,
        'includeParkingSpot': true,
      };

      final result = await reviewProvider.get(filter: filter);
      
      setState(() {
        reviews = result;
        _currentPage = pageToFetch;
        _pageSize = pageSizeToUse;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading reviews: $e")),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      reviewProvider = context.read<ReviewProvider>();
      await _performSearch(page: 0);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    usernameController.dispose();
    super.dispose();
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
    return BaseSearchBar(
      fields: [
        BaseSearchField(
          controller: usernameController,
          hint: "Search by name...",
          icon: Icons.person,
          onSubmitted: () => _performSearch(page: 0),
        ),
        BaseSearchDropdown<int?>(
          value: selectedRating,
          hint: "Rating",
          icon: Icons.star_rounded,
          items: [
            const DropdownMenuItem<int?>(value: null, child: Text("All")),
            ...List.generate(5, (index) => index + 1).map(
              (rating) => DropdownMenuItem<int?>(
                value: rating,
                child: Row(
                  children: [
                    Text("$rating"),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                  ],
                ),
              ),
            ),
          ],
          onChanged: (val) {
            setState(() => selectedRating = val);
            _performSearch(page: 0);
          },
        ),
      ],
      onSearch: () => _performSearch(page: 0),
      onClear: () {
        usernameController.clear();
        setState(() => selectedRating = null);
        _performSearch(page: 0);
      },
    );
  }

  Widget _buildResultView() {
    if (reviews == null || reviews!.items == null || reviews!.items!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text("No reviews found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
          ],
        ),
      );
    }

    final int totalCount = reviews?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();

    return BaseCardsGrid(
      controller: _scrollController,
      items: reviews!.items!.map((e) {
        return BaseGridCardItem(
          title: "${e.user?.firstName ?? 'Unknown'} ${e.user?.lastName ?? 'User'}",
          subtitle: "@${e.user?.username ?? 'unknown'}",
          imageUrl: e.user?.picture,
          data: {
            Icons.star_outline: "${e.rating} Stars",
            Icons.comment_outlined: e.comment ?? "No comment",
            Icons.calendar_today_outlined: "${e.createdAt.day}/${e.createdAt.month}/${e.createdAt.year}",
          },
          actions: [
            BaseGridAction(
              label: "Details",
              icon: Icons.info_outline,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReviewDetailsScreen(review: e),
                    settings: const RouteSettings(name: 'ReviewDetailsScreen'),
                  ),
                );
              },
              isPrimary: true,
            ),
          ],
        );
      }).toList(),
      pagination: (reviews != null && totalCount > 0)
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
