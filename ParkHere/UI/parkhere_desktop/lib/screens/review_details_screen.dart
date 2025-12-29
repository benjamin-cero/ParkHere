import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:parkhere_desktop/layouts/master_screen.dart';
import 'package:parkhere_desktop/model/review.dart';

class ReviewDetailsScreen extends StatelessWidget {
  final Review review;

  const ReviewDetailsScreen({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Review Details',
      showBackButton: true,
      onBack: () => Navigator.of(context).pop(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Hero Header
            SizedBox(
              height: 220,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -20,
                          right: -20,
                          child: Icon(Icons.star_rounded, size: 180, color: Colors.white.withOpacity(0.05)),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 6),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: const Color(0xFFF3F4F6),
                        backgroundImage: (review.user?.picture != null && review.user!.picture!.isNotEmpty)
                            ? MemoryImage(base64Decode(review.user!.picture!.replaceAll(RegExp(r'^data:image/[^;]+;base64,'), '')))
                            : null,
                        child: (review.user?.picture == null || review.user!.picture!.isEmpty)
                            ? Text(
                                (review.user?.firstName.isNotEmpty ?? false) ? review.user!.firstName[0].toUpperCase() : '?',
                                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 2. User Name
            Text(
              "${review.user?.firstName} ${review.user?.lastName}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => Icon(
                index < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                color: Colors.amber,
                size: 24,
              )),
            ),
            
            const SizedBox(height: 32),

            // 3. Information Content
            Container(
              constraints: const BoxConstraints(maxWidth: 800),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildSectionHeader("Feedback Details"),
                  const SizedBox(height: 16),
                  
                  // Comment Area
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade100),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.format_quote_rounded, color: Color(0xFF1E3A8A), size: 20),
                            SizedBox(width: 8),
                            Text("Comment", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          (review.comment != null && review.comment!.isNotEmpty) ? review.comment! : "No comment provided.",
                          style: const TextStyle(fontSize: 15, color: Color(0xFF374151), height: 1.5, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Meta Info Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoTile(
                          icon: Icons.calendar_today_rounded,
                          label: "Date",
                          value: _formatDate(review.createdAt),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoTile(
                          icon: Icons.local_parking_rounded,
                          label: "Parking Spot",
                          value: review.parkingReservation?.parkingSpot?.spotCode ?? "N/A",
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader("Customer Information"),
                  const SizedBox(height: 16),
                  
                  _buildInfoTile(
                    icon: Icons.alternate_email_rounded,
                    label: "Username",
                    value: review.user?.username ?? "N/A",
                  ),
                  _buildInfoTile(
                    icon: Icons.email_outlined,
                    label: "Email Address",
                    value: review.user?.email ?? "N/A",
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(color: const Color(0xFF1E3A8A), borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
      ],
    );
  }

  Widget _buildInfoTile({required IconData icon, required String label, required String value}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: Color(0xFF1F2937), fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
