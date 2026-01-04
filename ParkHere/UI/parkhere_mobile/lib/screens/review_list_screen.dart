import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parkhere_mobile/model/review.dart';
import 'package:parkhere_mobile/providers/review_provider.dart';
import 'package:parkhere_mobile/providers/user_provider.dart';
import 'package:parkhere_mobile/utils/base_picture_cover.dart';
import 'package:parkhere_mobile/screens/profile_screen.dart';
import 'package:parkhere_mobile/utils/base_pagination.dart';
import 'package:parkhere_mobile/utils/base_textfield.dart';
import 'package:parkhere_mobile/model/parking_reservation.dart';
import 'package:parkhere_mobile/providers/parking_reservation_provider.dart';
import 'package:parkhere_mobile/utils/message_utils.dart';
import 'package:parkhere_mobile/utils/review_dialog.dart';
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
  final Set<int> _expandedReviews = {};
  int? _selectedRating; // null means All


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
      
      Map<String, dynamic> filter = {
        'page': _currentPage,
        'pageSize': _pageSize,
        'includeTotalCount': true,
      };

      if (_selectedRating != null) {
        filter['rating'] = _selectedRating;
      }

      final result = await reviewProvider.get(filter: filter);

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

  void _onRatingFilterChanged(int? rating) {
    if (_selectedRating == rating) return;
    setState(() {
      _selectedRating = rating;
      _currentPage = 0; // Reset to first page
      _reviews = []; // Clear current list
      _isLoading = true;
    });
    _loadReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Community Reviews',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'See what others are saying',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildFilterChip("All", null),
                  const SizedBox(width: 8),
                  _buildFilterChip("5 Stars", 5),
                  const SizedBox(width: 8),
                  _buildFilterChip("4 Stars", 4),
                  const SizedBox(width: 8),
                  _buildFilterChip("3 Stars", 3),
                  const SizedBox(width: 8),
                  _buildFilterChip("2 Stars", 2),
                  const SizedBox(width: 8),
                  _buildFilterChip("1 Star", 1),
                ],
              ),
            ),
            const SizedBox(height: 16),
  
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : _reviews.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadReviews,
                          color: AppColors.primary,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            itemCount: _reviews.length,
                            itemBuilder: (context, index) {
                              final review = _reviews[index];
                              return _buildReviewCard(review);
                            },
                          ),
                        ),
            ),
            if (_totalPages > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: BasePagination(
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
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showReservationPicker,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.rate_review_rounded, color: Colors.white),
        label: const Text("Leave a Review", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _showReservationPicker() async {
    setState(() => _isLoading = true);
    try {
      final resProvider = Provider.of<ParkingReservationProvider>(context, listen: false);
      final result = await resProvider.get(filter: {
        'userId': UserProvider.currentUser?.id,
        'excludePassed': false,
        'retrieveAll': true,
      });

      // Filter for COMPLETED reservations only
      final completed = result.items?.where((r) => r.actualStartTime != null && r.actualEndTime != null).toList() ?? [];

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (completed.isEmpty) {
        MessageUtils.showWarning(context, "No completed reservations found to review.");
        return;
      }

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 24),
              const Text("Select Reservation", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
              const SizedBox(height: 8),
              const Text("Choose a past session to share your feedback.", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: completed.length,
                  itemBuilder: (context, index) {
                    final res = completed[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          res.parkingSpot?.name ?? "Spot #${res.parkingSpotId}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "${DateFormat('MMM dd, yyyy').format(res.startTime)} • ${res.price.toStringAsFixed(2)} BAM",
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                        onTap: () {
                          Navigator.pop(context);
                          _openReviewDialog(res.id);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        MessageUtils.showError(context, "Failed to load reservations.");
      }
    }
  }

  void _openReviewDialog(int reservationId) {
    showDialog(
      context: context,
      builder: (context) => ReviewDialog(reservationId: reservationId),
    ).then((_) => _loadReviews()); // Refresh list after review might have been added
  }

  Widget _buildFilterChip(String label, int? rating) {
    final isSelected = _selectedRating == rating;
    return GestureDetector(
      onTap: () => _onRatingFilterChanged(rating),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            if (rating != null) ...[
              Icon(
                Icons.star_rounded,
                size: 16,
                color: isSelected ? Colors.white : const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.text,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(35),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.rate_review_rounded,
                size: 70,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "No Reviews Yet",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Your reviews for past parking reservations will appear here. Help others find the best spots!",
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textLight,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    // If you haven't updated review.dart to include 'user', you might need to handle nulls
    // adhering to the plan, we assume review.user is available now.
    // If user is null, fallback to placeholder.
    final user = review.user;
    final userImage = ProfileScreen.getUserImageProvider(user?.picture);
    final bool isExpanded = _expandedReviews.contains(review.id);
    final String comment = review.comment ?? "";
    final bool isLongComment = comment.length > 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: User Info & Rating
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: userImage,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: userImage == null
                      ? Text(
                          (user?.firstName.isNotEmpty == true) ? user!.firstName[0].toUpperCase() : 'U',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user != null ? "${user.firstName} ${user.lastName}" : "ParkHere User",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                              color: const Color(0xFFF59E0B),
                              size: 14,
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('MMM dd, y').format(review.createdAt),
                            style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Comment Section
            if (comment.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                isExpanded ? comment : (isLongComment ? "${comment.substring(0, 100)}..." : comment),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.text,
                  height: 1.5,
                ),
              ),
              if (isLongComment)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedReviews.remove(review.id);
                      } else {
                        _expandedReviews.add(review.id);
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      isExpanded ? "See Less" : "See More",
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

