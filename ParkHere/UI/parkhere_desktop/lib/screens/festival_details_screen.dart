import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:parkhere_desktop/layouts/master_screen.dart';
import 'package:parkhere_desktop/model/festival.dart';
import 'package:parkhere_desktop/utils/base_map.dart';

class FestivalDetailsScreen extends StatefulWidget {
  final Festival festival;

  const FestivalDetailsScreen({super.key, required this.festival});

  @override
  State<FestivalDetailsScreen> createState() => _FestivalDetailsScreenState();
}

class _FestivalDetailsScreenState extends State<FestivalDetailsScreen> {
  // Use PageView controller for assets
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Festival Details',
      showBackButton: true,
      child: _buildFestivalDetails(),
    );
  }

  Widget _buildFestivalDetails() {
    final festival = widget.festival;
    final coordinates = festival.coordinates;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align children at the top
                children: [
                  // Country flag (smaller, stays at the top)
                  Container(
                    width: 28,
                    height: 25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child:
                          festival.countryFlag != null &&
                              festival.countryFlag!.isNotEmpty
                          ? Image.memory(
                              base64Decode(festival.countryFlag!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.flag,
                                  size: 16, // smaller to match container
                                  color: Theme.of(context).colorScheme.primary,
                                );
                              },
                            )
                          : Icon(
                              Icons.flag,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Festival logo (bigger, stays aligned below flag naturally)
                  Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: festival.logo != null && festival.logo!.isNotEmpty
                          ? Image.memory(
                              base64Decode(festival.logo!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.festival,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.primary,
                                );
                              },
                            )
                          : Icon(
                              Icons.festival,
                              size: 48,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          festival.title,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          festival.dateRange,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: festival.isActive ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      festival.isActive ? 'Active' : 'Inactive',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child:
                    _buildInfoCard('Festival Information', Icons.info_outline, [
                      _buildInfoRow('Title', festival.title),
                      _buildInfoRow('Date Range', festival.dateRange),
                      _buildInfoRow(
                        'Base Price',
                        '\$${festival.basePrice.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 7),
                      const Divider(),
                      _buildInfoRow('City', festival.cityName),
                      _buildInfoRow('Country', festival.countryName),
                      _buildInfoRow('Organizer', festival.organizerName),
                      const SizedBox(height: 7),
                      const Divider(),
                      _buildInfoRow('Subcategory', festival.subcategoryName),
                      _buildInfoRow('Category', festival.categoryName),
                      const SizedBox(height: 7),
                    ]),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: _buildInfoCard(
                  'Festival Assets',
                  Icons.image,
                  [],
                  child: festival.assets.isNotEmpty
                      ? _buildAssetsCarousel(festival.assets)
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'No assets available',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: _buildInfoCard(
                  'Festival Location',
                  Icons.map,
                  [],
                  child: coordinates != null
                      ? BaseMap(
                          start: festival.location,
                          end: festival.location,
                          height: 300,
                          width: double.infinity,
                          showRouteInfoOverlay: false,
                          showZoomControls: true,
                          title: 'Festival Location',
                          accentColor: Theme.of(context).colorScheme.primary,
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Location coordinates not available',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    IconData icon,
    List<Widget> infoRows, {
    Widget? child,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (child != null) child else ...infoRows,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildAssetsCarousel(List<dynamic> assets) {
    return SizedBox(
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: assets.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildAssetItem(
                assets[index],
              ); // changed to _buildAssetItem without glass effect
            },
          ),
          if (assets.length > 1)
            Positioned(
              left: 8,
              child: _buildArrowButton(Icons.arrow_back_ios, () {
                int prevPage = _currentPage - 1;
                if (prevPage < 0) {
                  prevPage = assets.length - 1; // wrap to last
                }
                _pageController.animateToPage(
                  prevPage,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              }),
            ),
          if (assets.length > 1)
            Positioned(
              right: 8,
              child: _buildArrowButton(Icons.arrow_forward_ios, () {
                int nextPage = _currentPage + 1;
                if (nextPage >= assets.length) {
                  nextPage = 0; // wrap to first
                }
                _pageController.animateToPage(
                  nextPage,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              }),
            ),
          if (assets.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  assets.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentPage
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[300],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Replace your existing _buildGlassAssetItem with this _buildAssetItem:
  Widget _buildAssetItem(dynamic asset) {
    String? base64Content;
    if (asset is Map<String, dynamic>) {
      base64Content = asset['base64Content'] as String?;
    } else {
      try {
        base64Content = asset.base64Content;
      } catch (_) {}
    }
    if (base64Content == null || base64Content.isEmpty) {
      return _buildImageError();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Image.memory(base64Decode(base64Content), fit: BoxFit.cover),
    );
  }

  Widget _buildArrowButton(IconData icon, VoidCallback onPressed) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.6),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassAssetItem(dynamic asset) {
    String? base64Content;
    if (asset is Map<String, dynamic>) {
      base64Content = asset['base64Content'] as String?;
    } else {
      try {
        base64Content = asset.base64Content;
      } catch (_) {}
    }
    if (base64Content == null || base64Content.isEmpty) {
      return _buildImageError();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(base64Decode(base64Content), fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.white.withOpacity(0.05)),
          ),
        ],
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
      ),
    );
  }
}
