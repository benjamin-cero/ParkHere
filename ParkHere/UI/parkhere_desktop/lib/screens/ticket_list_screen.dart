import 'package:flutter/material.dart';
import 'package:parkhere_desktop/layouts/master_screen.dart';
import 'package:parkhere_desktop/model/ticket.dart';
import 'package:parkhere_desktop/model/search_result.dart';
import 'package:parkhere_desktop/providers/ticket_provider.dart';
import 'package:parkhere_desktop/screens/ticket_details_screen.dart';
import 'package:parkhere_desktop/utils/base_cards_grid.dart';
import 'package:parkhere_desktop/utils/base_pagination.dart';
import 'package:parkhere_desktop/utils/base_textfield.dart';
import 'package:parkhere_desktop/widgets/ticket_scanner_dialog.dart';
import 'package:parkhere_desktop/utils/qr_generator.dart';
import 'package:provider/provider.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  late TicketProvider ticketProvider;
  final ScrollController _scrollController = ScrollController();

  final TextEditingController userFullNameController = TextEditingController();
  final TextEditingController festivalTitleController = TextEditingController();

  SearchResult<Ticket>? tickets;
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 10, 20, 50];

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;

    final filter = {
      'userFullName': userFullNameController.text,
      'festivalTitle': festivalTitleController.text,
      'page': pageToFetch,
      'pageSize': pageSizeToUse,
      'includeTotalCount': true,
    };

    final result = await ticketProvider.get(filter: filter);
    
    setState(() {
      tickets = result;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  Future<void> _showScannerDialog() async {
    final result = await showDialog<Ticket>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const TicketScannerDialog(),
    );

    if (result != null) {
      // Show success dialog and refresh the list
      if (mounted) {
        await _showSuccessDialog(result);
        await _performSearch(page: _currentPage);
      }
    }
  }

  Future<void> _showSuccessDialog(Ticket ticket) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            const Text('Ticket Redeemed!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '✅ Ticket successfully redeemed! User can now enter the festival.',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ticketProvider = context.read<TicketProvider>();
      await _performSearch(page: 0);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    userFullNameController.dispose();
    festivalTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Tickets',
      child: Column(
        children: [
          _buildSearch(),
          Expanded(child: _buildResultView()),
        ],
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
            flex: 2,
            child: TextField(
              controller: userFullNameController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              onSubmitted: (_) => _performSearch(page: 0),
              decoration: InputDecoration(
                hintText: "Search by user...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                prefixIcon: Icon(Icons.person, color: Colors.white.withOpacity(0.7), size: 18),
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
          Expanded(
            flex: 2,
            child: TextField(
              controller: festivalTitleController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              onSubmitted: (_) => _performSearch(page: 0),
              decoration: InputDecoration(
                hintText: "Festival...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                prefixIcon: Icon(Icons.festival, color: Colors.white.withOpacity(0.7), size: 18),
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
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
            onPressed: () {
              userFullNameController.clear();
              festivalTitleController.clear();
              _performSearch(page: 0);
            },
            tooltip: "Reset",
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _showScannerDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            icon: const Icon(Icons.qr_code_scanner, size: 18),
            label: const Text("Redeem", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    if (tickets == null || tickets!.items == null || tickets!.items!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.confirmation_number_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text("No tickets found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
          ],
        ),
      );
    }

    final int totalCount = tickets?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();

    return BaseCardsGrid(
      controller: _scrollController,
      items: tickets!.items!.map((e) {
        return BaseGridCardItem(
          title: e.userFullName,
          subtitle: e.festivalTitle,
          isActive: !e.isRedeemed,
          data: {
            Icons.confirmation_number_outlined: e.ticketTypeName,
            Icons.attach_money: "\$${e.finalPrice.toStringAsFixed(2)}",
            Icons.code: e.textCode,
            Icons.info_outline: e.isRedeemed ? "Redeemed" : "Active",
          },
          actions: [
            BaseGridAction(
              label: "Details",
              icon: Icons.info_outline,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TicketDetailsScreen(ticket: e),
                    settings: const RouteSettings(name: 'TicketDetailsScreen'),
                  ),
                );
              },
              isPrimary: true,
            ),
          ],
        );
      }).toList(),
      pagination: (tickets != null && totalCount > 0)
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
