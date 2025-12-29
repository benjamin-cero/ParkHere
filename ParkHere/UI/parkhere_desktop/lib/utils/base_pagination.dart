import 'package:flutter/material.dart';

class BasePagination extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final Function(int)? onPageSelected;
  final bool showPageSizeSelector;
  final int pageSize;
  final List<int> pageSizeOptions;
  final ValueChanged<int?>? onPageSizeChanged;
  final ScrollController? scrollController;

  const BasePagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onNext,
    this.onPrevious,
    this.onPageSelected,
    this.showPageSizeSelector = false,
    this.pageSize = 10,
    this.pageSizeOptions = const [5, 10, 20, 50],
    this.onPageSizeChanged,
    this.scrollController,
  });

  @override
  State<BasePagination> createState() => _BasePaginationState();
}

class _BasePaginationState extends State<BasePagination> {
  void _scrollToBottom() {
    if (widget.scrollController != null && widget.scrollController!.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.scrollController!.animateTo(
          widget.scrollController!.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Page Size Selector
          if (widget.showPageSizeSelector) _buildPageSizeSelector() else const SizedBox(),

          // Center: Page Numbers and Nav
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNavButton(
                icon: Icons.chevron_left_rounded,
                onPressed: widget.onPrevious,
                isEnabled: widget.currentPage > 0,
              ),
              const SizedBox(width: 8),
              ..._buildPageNumbers(),
              const SizedBox(width: 8),
              _buildNavButton(
                icon: Icons.chevron_right_rounded,
                onPressed: widget.onNext,
                isEnabled: widget.currentPage < widget.totalPages - 1,
              ),
            ],
          ),

          // Right: Results Info
          Text(
            "Page ${widget.currentPage + 1} of ${widget.totalPages == 0 ? 1 : widget.totalPages}",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageSizeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Show", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: widget.pageSize,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF1E3A8A)),
              style: const TextStyle(
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              items: widget.pageSizeOptions.map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (newSize) {
                if (newSize != null && widget.onPageSizeChanged != null) {
                  widget.onPageSizeChanged!(newSize);
                  _scrollToBottom();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> numbers = [];
    int total = widget.totalPages == 0 ? 1 : widget.totalPages;
    int current = widget.currentPage;

    if (total <= 7) {
      for (int i = 0; i < total; i++) {
        numbers.add(_buildPageButton(i));
      }
    } else {
      // Logic for truncation: 1 2 3 ... 10
      numbers.add(_buildPageButton(0));
      
      if (current > 2) {
        numbers.add(_buildEllipsis());
      }

      int start = (current - 1).clamp(1, total - 2);
      int end = (current + 1).clamp(1, total - 2);

      if (current <= 2) end = 3;
      if (current >= total - 3) start = total - 4;

      for (int i = start; i <= end; i++) {
        numbers.add(_buildPageButton(i));
      }

      if (current < total - 3) {
        numbers.add(_buildEllipsis());
      }

      numbers.add(_buildPageButton(total - 1));
    }

    return numbers;
  }

  Widget _buildPageButton(int pageIndex) {
    bool isSelected = pageIndex == widget.currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: () {
          if (!isSelected && widget.onPageSelected != null) {
            widget.onPageSelected!(pageIndex);
            _scrollToBottom();
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E3A8A) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? null : Border.all(color: Colors.transparent),
          ),
          child: Text(
            (pageIndex + 1).toString(),
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF374151),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEllipsis() {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      child: Text(
        "...",
        style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildNavButton({required IconData icon, required VoidCallback? onPressed, required bool isEnabled}) {
    return InkWell(
      onTap: isEnabled ? () {
        onPressed?.call();
        _scrollToBottom();
      } : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isEnabled ? const Color(0xFFF3F4F6) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isEnabled ? const Color(0xFF1E3A8A) : Colors.grey[300],
        ),
      ),
    );
  }
}
