import 'package:flutter/material.dart';
import 'dart:convert';

class BaseGridCardItem {
  final String title;
  final String subtitle;
  final String? imageUrl; // Base64 string or null
  final bool? isActive;
  final String? statusTitle;
  final Map<IconData, String> data;
  final List<BaseGridAction> actions;
  final VoidCallback? onTap;

  BaseGridCardItem({
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.isActive,
    this.statusTitle,
    this.data = const {},
    this.actions = const [],
    this.onTap,
  });
}

class BaseGridAction {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;

  BaseGridAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
  });
}

class BaseCardsGrid extends StatelessWidget {
  final List<BaseGridCardItem> items;
  final Widget? pagination;
  final ScrollController? controller;
  final double childAspectRatio;

  const BaseCardsGrid({
    super.key,
    required this.items,
    this.pagination,
    this.controller,
    this.childAspectRatio = 1.25,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
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
              child: const Icon(
                Icons.grid_view_rounded,
                size: 48,
                color: Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "No items found",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 1;
          if (constraints.maxWidth > 1400) {
            crossAxisCount = 4;
          } else if (constraints.maxWidth > 1100) {
            crossAxisCount = 3;
          } else if (constraints.maxWidth > 700) {
            crossAxisCount = 2;
          }

          return CustomScrollView(
            key: const PageStorageKey('base_cards_grid'),
            controller: controller,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: childAspectRatio,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildCard(items[index]),
                    childCount: items.length,
                  ),
                ),
              ),
              if (pagination != null)
                SliverToBoxAdapter(
                  child: pagination!,
                ),
              // Add a small spacer at the very bottom
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCard(BaseGridCardItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                height: 55, // Compact Header
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              if (item.isActive != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: item.isActive!
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          item.statusTitle ??
                              (item.isActive! ? "Active" : "Inactive"),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                bottom: -35,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 34, // Slightly larger for presence
                    backgroundColor: const Color(0xFFF3F4F6),
                    backgroundImage:
                        (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                            ? MemoryImage(base64Decode(item.imageUrl!))
                            : null,
                    child: (item.imageUrl == null || item.imageUrl!.isEmpty)
                        ? Text(
                            item.title.isNotEmpty
                                ? item.title[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E3A8A),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 38), // Spacer to clear avatar

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 18, // Larger Font
                      fontWeight: FontWeight.w800, // Bolder
                      color: Color(0xFF111827),
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 14, // Larger Subtitle
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...item.data.entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(e.key, size: 16, color: const Color(0xFF9CA3AF)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              e.value,
                              style: const TextStyle(
                                fontSize: 13.5, // Larger data text
                                color: Color(0xFF4B5563),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Actions
          if (item.actions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: item.actions.map((action) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: action.isPrimary
                          ? ElevatedButton(
                              onPressed: action.onPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3A8A),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                elevation: 0,
                              ),
                              child: Text(
                                action.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            )
                          : OutlinedButton(
                              onPressed: action.onPressed,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF4B5563),
                                side:
                                    const BorderSide(color: Color(0xFFD1D5DB)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                backgroundColor: Colors.white,
                              ),
                              child: Text(
                                action.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
