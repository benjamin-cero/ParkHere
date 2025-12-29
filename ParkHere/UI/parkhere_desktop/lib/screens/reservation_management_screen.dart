import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parkhere_desktop/layouts/master_screen.dart';
import 'package:parkhere_desktop/model/parking_reservation.dart';
import 'package:parkhere_desktop/model/search_result.dart';
import 'package:parkhere_desktop/providers/parking_reservation_provider.dart';
import 'package:parkhere_desktop/screens/reservation_details_screen.dart';
import 'package:parkhere_desktop/utils/base_table.dart';
import 'package:parkhere_desktop/utils/base_pagination.dart';
import 'package:parkhere_desktop/utils/base_search_bar.dart';
import 'package:provider/provider.dart';

class ReservationManagementScreen extends StatefulWidget {
  const ReservationManagementScreen({super.key});

  @override
  State<ReservationManagementScreen> createState() => _ReservationManagementScreenState();
}

class _ReservationManagementScreenState extends State<ReservationManagementScreen> {
  late ParkingReservationProvider _reservationProvider;
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  SearchResult<ParkingReservation>? _reservations;
  
  final TextEditingController _licensePlateController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();

  int _currentPage = 0;
  int _pageSize = 10;
  final List<int> _pageSizeOptions = [5, 10, 20, 50];

  @override
  void initState() {
    super.initState();
    _reservationProvider = context.read<ParkingReservationProvider>();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _licensePlateController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _loadData({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;

    setState(() => _isLoading = true);
    try {
      var filter = {
        "includeTotalCount": true,
        "licensePlate": _licensePlateController.text,
        "fullName": _fullNameController.text,
        "page": pageToFetch,
        "pageSize": pageSizeToUse,
        "includeUser": true,
        "includeVehicle": true,
        "includeParkingSpot": true,
        "includeParkingSession": true,
      };
      
      final result = await _reservationProvider.get(filter: filter);
      setState(() {
        _reservations = result;
        _currentPage = pageToFetch;
        _pageSize = pageSizeToUse;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading data: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Reservation Management",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          BaseSearchBar(
            fields: [
              BaseSearchField(
                controller: _licensePlateController,
                hint: "Search by license plate...",
                icon: Icons.directions_car_rounded,
                onSubmitted: () => _loadData(page: 0),
              ),
              BaseSearchField(
                controller: _fullNameController,
                hint: "Search by user name...",
                icon: Icons.person_search_rounded,
                onSubmitted: () => _loadData(page: 0),
              ),
            ],
            onSearch: () => _loadData(page: 0),
            onClear: () {
              _licensePlateController.clear();
              _fullNameController.clear();
              _loadData(page: 0);
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading && _reservations == null
                ? const Center(child: CircularProgressIndicator())
                : _buildResultView(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Manage Reservations",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Monitor and search all parking reservations",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _loadData(page: 0),
            icon: const Icon(Icons.refresh_rounded),
            color: const Color(0xFF1E3A8A),
            tooltip: "Refresh Data",
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF3F4F6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final bool isEmpty = _reservations == null || _reservations!.items == null || _reservations!.items!.isEmpty;
    final int totalCount = _reservations?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();

    if (isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
              child: const Icon(Icons.search_off_rounded, size: 48, color: Color(0xFF9CA3AF)),
            ),
            const SizedBox(height: 16),
            const Text("No reservations found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
            const Text("Try adjusting filters", style: TextStyle(color: Color(0xFF6B7280))),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: BaseTable(
              width: double.infinity,
              height: double.infinity,
              title: "Reservation List",
              icon: Icons.list_alt_rounded,
              columns: const [
                DataColumn(label: Text("License Plate")),
                DataColumn(label: Text("User")),
                DataColumn(label: Text("Spot")),
                DataColumn(label: Text("Planned Start")),
                DataColumn(label: Text("Planned End")),
                DataColumn(label: Text("Price")),
                DataColumn(label: Text("Status")),
              ],
              rows: (_reservations?.items ?? []).map((res) {
                return DataRow(
                  onSelectChanged: (_) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReservationDetailsScreen(reservation: res),
                      ),
                    );
                  },
                  cells: [
                    DataCell(Text(res.vehicle?.licensePlate ?? "N/A", style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text("${res.user?.firstName} ${res.user?.lastName}")),
                    DataCell(Text(res.parkingSpot?.spotCode ?? "N/A")),
                    DataCell(Text(DateFormat('dd.MM HH:mm').format(res.startTime))),
                    DataCell(Text(DateFormat('dd.MM HH:mm').format(res.endTime))),
                    DataCell(Text("${res.price.toStringAsFixed(2)} BAM")),
                    DataCell(_buildStatusBadge(res)),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        if (_reservations != null && totalCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: BasePagination(
              scrollController: _scrollController,
              currentPage: _currentPage,
              totalPages: totalPages,
              onPrevious: _currentPage > 0 ? () => _loadData(page: _currentPage - 1) : null,
              onNext: _currentPage < totalPages - 1 ? () => _loadData(page: _currentPage + 1) : null,
              showPageSizeSelector: true,
              pageSize: _pageSize,
              pageSizeOptions: _pageSizeOptions,
              onPageSizeChanged: (newSize) {
                if (newSize != null && newSize != _pageSize) {
                  _loadData(page: 0, pageSize: newSize);
                }
              },
            ),
          ),
      ],
    );
  }

  Widget _buildStatusBadge(ParkingReservation res) {
    bool isPaid = res.isPaid;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        isPaid ? "Paid" : "Unpaid",
        style: TextStyle(
          color: isPaid ? const Color(0xFF166534) : const Color(0xFF92400E),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
