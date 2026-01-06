import 'package:flutter/material.dart';
import 'package:parkhere_desktop/layouts/master_screen.dart';
import 'package:parkhere_desktop/model/user.dart';
import 'package:parkhere_desktop/model/search_result.dart';
import 'package:parkhere_desktop/providers/user_provider.dart';
import 'package:parkhere_desktop/screens/users_details_screen.dart';
import 'package:parkhere_desktop/screens/users_edit_screen.dart';
import 'package:parkhere_desktop/utils/base_cards_grid.dart';
import 'package:parkhere_desktop/utils/base_pagination.dart';
import 'package:parkhere_desktop/utils/base_search_bar.dart';
import 'package:provider/provider.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  late UserProvider userProvider;
  final ScrollController _scrollController = ScrollController();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  int? selectedRoleFilter; // null = All, 1 = Admin, 2 = User

  SearchResult<User>? users;
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 10, 20, 50];

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;

    final filter = {
      'username': usernameController.text,
      'email': emailController.text,
      'roleId': selectedRoleFilter, // null for All
      'page': pageToFetch,
      'pageSize': pageSizeToUse,
      'includeTotalCount': true,
    };

    final result = await userProvider.get(filter: filter);
    setState(() {
      users = result;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userProvider = context.read<UserProvider>();
      await _performSearch(page: 0);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Users',
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
      title: "User Management",
      icon: Icons.people_alt_rounded,
      fields: [
        BaseSearchField(
          controller: usernameController,
          hint: "Username...",
          icon: Icons.search,
          onSubmitted: () => _performSearch(page: 0),
        ),
        BaseSearchField(
          controller: emailController,
          hint: "Email...",
          icon: Icons.email_outlined,
          onSubmitted: () => _performSearch(page: 0),
        ),
        BaseSearchDropdown<int?>(
          value: selectedRoleFilter,
          hint: "Role",
          icon: Icons.admin_panel_settings_rounded,
          items: const [
            DropdownMenuItem<int?>(value: null, child: Text("All")),
            DropdownMenuItem<int>(value: 1, child: Text("Admin")),
            DropdownMenuItem<int>(value: 2, child: Text("User")),
          ],
          onChanged: (val) {
            setState(() => selectedRoleFilter = val);
            _performSearch(page: 0);
          },
        ),
      ],
      onSearch: () => _performSearch(page: 0),
      onClear: () {
        usernameController.clear();
        emailController.clear();
        setState(() => selectedRoleFilter = null);
        _performSearch(page: 0);
      },
    );
  }

  Widget _buildResultView() {
    final isEmpty = users == null || users!.items == null || users!.items!.isEmpty;
    final int totalCount = users?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();

    if (isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.people_alt_outlined, size: 48, color: Color(0xFF3B82F6)),
            ),
            const SizedBox(height: 16),
            const Text("No users found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
            const Text("Try adjusting filters", style: TextStyle(color: Color(0xFF6B7280))),
          ],
        ),
      );
    }

    return BaseCardsGrid(
      controller: _scrollController,
      items: users!.items!.map((user) {
        return BaseGridCardItem(
          title: "${user.firstName} ${user.lastName}",
          subtitle: "@${user.username}",
          imageUrl: user.picture,
          isActive: user.totalDebt > 0 ? false : user.isActive,
          statusTitle: user.totalDebt > 0 
              ? "DEBT: ${user.totalDebt.toStringAsFixed(2)} BAM" 
              : (user.isActive ? "Active" : "Inactive"),
          data: {
            Icons.email_outlined: user.email,
            Icons.location_city_outlined: user.cityName.isEmpty ? "Unknown City" : user.cityName,
            Icons.admin_panel_settings_outlined: user.roles.map((r) => r.name).join(', ').isEmpty 
                ? "No Role" 
                : user.roles.map((r) => r.name).join(', '),
            if (user.totalDebt > 0)
              Icons.account_balance_wallet_outlined: "Debt: ${user.totalDebt.toStringAsFixed(2)} BAM",
          },
          actions: [
            BaseGridAction(
              label: "Details",
              icon: Icons.info_outline,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UsersDetailsScreen(user: user),
                    settings: const RouteSettings(name: 'UsersDetailsScreen'),
                  ),
                );
              },
              isPrimary: false,
            ),
            BaseGridAction(
              label: "Edit",
              icon: Icons.edit_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UsersEditScreen(user: user),
                    settings: const RouteSettings(name: 'UsersEditScreen'),
                  ),
                );
              },
              isPrimary: true,
            ),
          ],
        );
      }).toList(),
      pagination: (users != null && (users?.totalCount ?? 0) > 0)
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
