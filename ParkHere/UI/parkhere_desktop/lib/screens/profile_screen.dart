import 'package:flutter/material.dart';
import 'package:parkhere_desktop/layouts/master_screen.dart';
import 'package:parkhere_desktop/providers/user_provider.dart';
import 'package:parkhere_desktop/screens/users_edit_screen.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserProvider userProvider;

  @override
  Widget build(BuildContext context) {
    // Listen to provider for real-time updates of currentUser
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        final user = UserProvider.currentUser;

        if (user == null) {
          return const MasterScreen(
            title: 'My Profile',
            child: Center(child: Text('User not found')),
          );
        }

        return MasterScreen(
          title: 'My Profile',
          showBackButton: true,
          onBack: () => Navigator.of(context).pop(),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 260,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      // 1. Hero Header
                      Container(
                        height: 200,
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
                              top: 20,
                              right: 20,
                              child: Icon(
                                Icons.circle,
                                size: 200,
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),
                            Positioned(
                              top: 60,
                              left: 40,
                              child: Icon(
                                Icons.circle_outlined,
                                size: 100,
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 2. Overlapping Profile Picture (Now fully clickable)
                      Positioned(
                        bottom: 0,
                        child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 65,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: (user.picture != null && user.picture!.isNotEmpty)
                                    ? MemoryImage(base64Decode(user.picture!.replaceAll(RegExp(r'^data:image/[^;]+;base64,'), '')))
                                    : null,
                                child: (user.picture == null || user.picture!.isEmpty)
                                    ? Text(
                                        user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
                                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                                      )
                                    : null,
                              ),
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10), // Reduced spacer since height is already 260

                // 3. User Name & Username
                Text(
                  "${user.firstName} ${user.lastName}",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Text(
                    "@${user.username}",
                    style: const TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 4. Content Area
                Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Quick Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildQuickStat(
                            icon: Icons.check_circle_outline,
                            label: user.isActive ? "Active" : "Inactive",
                            color: user.isActive ? Colors.green : Colors.red,
                            value: "Status",
                          ),
                          _buildQuickStat(
                            icon: Icons.admin_panel_settings_outlined,
                            label: user.roles != null && user.roles.isNotEmpty 
                                ? user.roles.map((r) => r.name).join(', ') 
                                : "User",
                            value: "Role",
                            color: Colors.blue,
                          ),
                          _buildQuickStat(
                            icon: Icons.location_city_outlined,
                            label: user.cityName != null && user.cityName.isNotEmpty ? user.cityName : "N/A",
                            value: "City",
                            color: Colors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Information Sections
                      _buildSectionHeader("Contact Information"),
                      const SizedBox(height: 16),
                      _buildInfoTile(
                        icon: Icons.email_outlined,
                        label: "Email Address",
                        value: user.email,
                      ),
                      _buildInfoTile(
                        icon: Icons.phone_outlined,
                        label: "Phone Number",
                        value: user.phoneNumber ?? "Not provided",
                      ),

                      const SizedBox(height: 32),
                      _buildSectionHeader("Personal Details"),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoTile(
                              icon: Icons.person_outline,
                              label: "Gender",
                              value: user.genderName != null && user.genderName.isNotEmpty ? user.genderName : "Not set",
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInfoTile(
                              icon: Icons.cake_outlined,
                              label: "Member Since",
                              value: "Jan 1, 2024", // Placeholder date
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 50),

                      // Edit Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UsersEditScreen(user: user),
                                settings: const RouteSettings(name: 'UsersEditScreen'),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                            shadowColor: const Color(0xFF1E3A8A).withOpacity(0.4),
                          ),
                          icon: const Icon(Icons.edit_rounded),
                          label: const Text("Edit My Profile", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStat({required IconData icon, required String label, required String value, required Color color}) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(value, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
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
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF4B5563), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: Color(0xFF1F2937), fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
