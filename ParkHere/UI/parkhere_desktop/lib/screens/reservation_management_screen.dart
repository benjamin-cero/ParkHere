import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parkhere_desktop/layouts/master_screen.dart';
import 'package:parkhere_desktop/model/parking_reservation.dart';
import 'package:parkhere_desktop/model/search_result.dart';
import 'package:parkhere_desktop/providers/parking_reservation_provider.dart';
import 'package:parkhere_desktop/screens/reservation_details_screen.dart';
import 'package:parkhere_desktop/utils/base_cards_grid.dart';
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
          BaseSearchBar(
            title: "Reservation Monitoring",
            icon: Icons.bookmark_added,
            fields: [
              BaseSearchField(
                controller: _licensePlateController,
                hint: "License plate...",
                icon: Icons.directions_car_rounded,
              ),
              BaseSearchField(
                controller: _fullNameController,
                hint: "User name...",
                icon: Icons.person_search_rounded,
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

    return BaseCardsGrid(
      controller: _scrollController,
      items: (_reservations?.items ?? []).map((res) {
        return BaseGridCardItem(
          title: "${res.user?.firstName} ${res.user?.lastName}",
          subtitle: res.vehicle?.licensePlate ?? "N/A",
          imageUrl: res.user?.picture,
          isActive: res.isPaid,
          statusTitle: res.isPaid ? "Paid" : "Unpaid",
          data: {
            Icons.payments_outlined: "${res.price.toStringAsFixed(2)} KM",
            Icons.access_time_rounded: DateFormat('dd.MM HH:mm').format(res.startTime),
            Icons.local_parking_rounded: res.parkingSpot?.spotCode ?? "N/A",
          },
          actions: [
            BaseGridAction(
              label: "Details",
              icon: Icons.info_outline,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReservationDetailsScreen(reservation: res),
                    settings: const RouteSettings(name: 'ReservationDetailsScreen'),
                  ),
                );
              },
              isPrimary: true,
            ),
          ],
        );
      }).toList(),
      pagination: (_reservations != null && totalCount > 0)
          ? Padding(
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
                onPageSelected: (page) => _loadData(page: page),
              ),
            )
          : null,
    );
  }

}
