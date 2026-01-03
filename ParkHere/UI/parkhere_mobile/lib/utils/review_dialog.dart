import 'package:flutter/material.dart';
import 'package:parkhere_mobile/providers/review_provider.dart';
import 'package:parkhere_mobile/providers/user_provider.dart';
import 'package:parkhere_mobile/utils/base_textfield.dart';
import 'package:parkhere_mobile/utils/message_utils.dart';
import 'package:provider/provider.dart';

class ReviewDialog extends StatefulWidget {
  final int reservationId;

  const ReviewDialog({super.key, required this.reservationId});

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40), // spacer
              const Text(
                "Rate Experience",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "How was your parking experience? Help others by sharing your thoughts.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),
          
          // Star Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: index < _rating ? const Color(0xFFF59E0B) : Colors.grey[300],
                    size: 40,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          // Comment field
          AppTextField(
            label: "Comment",
            hintText: "Write your thoughts (optional)...",
            controller: _commentController,
            prefixIcon: Icons.comment_rounded,
          ),
          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Save Review", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      MessageUtils.showError(context, "Please select a star rating");
      return;
    }

    setState(() => _isLoading = true);
    try {
      final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
      final req = {
        'rating': _rating,
        'comment': _commentController.text,
        'reservationId': widget.reservationId,
        'userId': UserProvider.currentUser?.id,
        'createdAt': DateTime.now().toIso8601String(),
      };

      await reviewProvider.insert(req);
      
      if (mounted) {
        MessageUtils.showSuccess(context, "Thank you for your feedback!");
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        MessageUtils.showError(context, "Failed to save review. Please try again later.");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
