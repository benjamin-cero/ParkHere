import 'package:flutter/material.dart';

class BasePagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const BasePagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onNext,
    this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final bool canGoPrevious = currentPage > 0;
    final bool canGoNext = currentPage < totalPages - 1 && totalPages > 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Page Info
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Page ${currentPage + 1} of ${totalPages == 0 ? 1 : totalPages}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2F855A),
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Navigation Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Previous Button
              _buildIconButton(
                icon: Icons.chevron_left_rounded,
                onPressed: canGoPrevious ? onPrevious : null,
                isEnabled: canGoPrevious,
              ),
              const SizedBox(width: 8),

              // Next Button
              _buildIconButton(
                icon: Icons.chevron_right_rounded,
                onPressed: canGoNext ? onNext : null,
                isEnabled: canGoNext,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isEnabled,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: const Color(0xFF2F855A).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isEnabled
                  ? const Color(0xFF2F855A)
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isEnabled ? Colors.white : Colors.grey[500],
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
