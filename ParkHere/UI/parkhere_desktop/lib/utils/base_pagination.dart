import 'package:flutter/material.dart';

class BasePagination extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
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
    this.showPageSizeSelector = false,
    this.pageSize = 10,
    this.pageSizeOptions = const [5, 7, 10, 20, 50],
    this.onPageSizeChanged,
    this.scrollController,
  });

  @override
  State<BasePagination> createState() => _BasePaginationState();
}

class _BasePaginationState extends State<BasePagination> {
  late double _currentSliderValue;

  @override
  void initState() {
    super.initState();
    _currentSliderValue = _getSliderValueFromPageSize(widget.pageSize);
  }

  @override
  void didUpdateWidget(BasePagination oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageSize != widget.pageSize) {
      _currentSliderValue = _getSliderValueFromPageSize(widget.pageSize);
    }
  }

  double _getSliderValueFromPageSize(int size) {
    int index = widget.pageSizeOptions.indexOf(size);
    return (index != -1 ? index : 0).toDouble();
  }

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
    final int divisions = widget.pageSizeOptions.length > 1 ? widget.pageSizeOptions.length - 1 : 1;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Page info and navigation
          Row(
            children: [
              // Page info chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E3A8A).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Page ${widget.currentPage + 1} of ${widget.totalPages == 0 ? 1 : widget.totalPages}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Previous button
              _buildNavigationButton(
                context,
                icon: Icons.arrow_back_ios_new_rounded,
                label: 'Previous',
                onPressed: (widget.currentPage == 0) ? null : widget.onPrevious,
                isEnabled: widget.currentPage > 0,
              ),

              const SizedBox(width: 12),

              // Next button
              _buildNavigationButton(
                context,
                icon: Icons.arrow_forward_ios_rounded,
                label: 'Next',
                onPressed: (widget.currentPage >= widget.totalPages - 1 || widget.totalPages == 0) ? null : widget.onNext,
                isEnabled: widget.currentPage < widget.totalPages - 1 && widget.totalPages > 0,
                isNext: true,
              ),
            ],
          ),

          // Right side: Page size selector
          if (widget.showPageSizeSelector) _buildPageSizeSelector(context, divisions),
        ],
      ),
    );
  }

  Widget _buildPageSizeSelector(BuildContext context, int divisions) {
    int displayValue = widget.pageSizeOptions[_currentSliderValue.round()];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Items per page:",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 140,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF1E3A8A),
                inactiveTrackColor: const Color(0xFFCBD5E1),
                thumbColor: Colors.white,
                overlayColor: const Color(0xFF1E3A8A).withOpacity(0.1),
                valueIndicatorColor: const Color(0xFF1E3A8A),
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 8,
                  elevation: 4,
                  pressedElevation: 6,
                ),
                valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                valueIndicatorTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              child: Slider(
                min: 0,
                max: (widget.pageSizeOptions.length - 1).toDouble(),
                divisions: divisions,
                value: _currentSliderValue,
                label: displayValue.toString(),
                onChanged: (double val) {
                  setState(() {
                    _currentSliderValue = val;
                  });
                },
                onChangeEnd: (double val) {
                  int idx = val.round();
                  int newSize = widget.pageSizeOptions[idx];
                  if (widget.onPageSizeChanged != null) {
                    widget.onPageSizeChanged!(newSize);
                    _scrollToBottom();
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              displayValue.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required bool isEnabled,
    bool isNext = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: const Color(0xFF1E3A8A).withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: () {
          if (onPressed != null) {
            onPressed();
            _scrollToBottom();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? Colors.white : const Color(0xFFF1F5F9),
          foregroundColor: isEnabled ? const Color(0xFF1E3A8A) : const Color(0xFF94A3B8),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isEnabled ? const Color(0xFF1E3A8A).withOpacity(0.2) : Colors.transparent,
            ),
          ),
          minimumSize: const Size(110, 40),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isNext) ...[
              Icon(icon, size: 16),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            if (isNext) ...[
              const SizedBox(width: 8),
              Icon(icon, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}
