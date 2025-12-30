import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parkhere_mobile/model/review.dart';
import 'package:parkhere_mobile/providers/review_provider.dart';
import 'package:parkhere_mobile/providers/user_provider.dart';
import 'package:parkhere_mobile/utils/base_picture_cover.dart';
import 'package:parkhere_mobile/utils/base_pagination.dart';
import 'package:parkhere_mobile/screens/review_details_screen.dart';
import 'package:intl/intl.dart';

class ReviewListScreen extends StatefulWidget {
  const ReviewListScreen({super.key});

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  List<Review> _reviews = [];
  bool _isLoading = true;
  int _currentPage = 0;
  int _totalPages = 1;
  int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    if (UserProvider.currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
      final result = await reviewProvider.get(
        filter: {
          'page': _currentPage,
          'pageSize': _pageSize,
          'includeTotalCount': true,
          'userId': UserProvider.currentUser!.id,
        },
      );

      if (mounted) {
        setState(() {
          _reviews = result.items ?? [];
          final totalCount = result.totalCount ?? 0;
          _totalPages = (totalCount / _pageSize).ceil();
          if (_totalPages == 0) _totalPages = 1;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onPageChanged(int newPage) {
    setState(() {
      _currentPage = newPage;
    });
    _loadReviews();
  }


  void _navigateToReviewDetails(Review review) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewDetailsScreen(review: review),
      ),
    ).then((_) => _loadReviews());
  }

  void _navigateToReviewSelection() {
    // Selection screen was deleted as part of wellness cleanup.
    // Review creation will be integrated into the reservation flow later.
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8FAFC),
            Colors.white,
          ],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'My Reviews',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF2F855A),
                        Color(0xFF38A169),
                      ],
                    ),
                  ),
                  child: IconButton(
                    onPressed: _navigateToReviewSelection,
                    icon: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    tooltip: 'Add Review',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F855A)),
                    ),
                  )
                : _reviews.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadReviews,
                        color: const Color(0xFF2F855A),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _reviews.length,
                          itemBuilder: (context, index) {
                            final review = _reviews[index];
                            return _buildReviewCard(review);
                          },
                        ),
                      ),
          ),
          BasePagination(
            currentPage: _currentPage,
            totalPages: _totalPages,
            onNext: () {
              if (_currentPage < _totalPages - 1) {
                _onPageChanged(_currentPage + 1);
              }
            },
            onPrevious: () {
              if (_currentPage > 0) {
                _onPageChanged(_currentPage - 1);
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.rate_review_outlined,
                size: 64,
                color: Color(0xFF2F855A),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "No Reviews Yet",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Your reviews for past parking reservations will appear here.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF2F855A).withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToReviewDetails(review),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE8F5E9)),
                  ),
                  child: const Icon(
                    Icons.local_parking_rounded,
                    color: Color(0xFF2F855A),
                    size: 40,
                  ),
                ),
                const SizedBox(width: 16),
                // Review Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.parkingReservation?.parkingSpot?.name != null
                            ? "Parking Spot: ${review.parkingReservation!.parkingSpot!.name}"
                            : "Reservation #${review.reservationId}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Rating Stars
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < review.rating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: const Color(0xFFF59E0B),
                            size: 18,
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      if (review.comment != null && review.comment!.isNotEmpty)
                        Text(
                          review.comment!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('MMM dd, yyyy').format(review.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

