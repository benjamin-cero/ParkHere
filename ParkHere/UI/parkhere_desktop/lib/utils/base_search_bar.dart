import 'package:flutter/material.dart';

class BaseSearchBar extends StatelessWidget {
  final List<Widget> fields;
  final VoidCallback onSearch;
  final VoidCallback onClear;
  final String title;
  final IconData icon;

  const BaseSearchBar({
    super.key,
    required this.fields,
    required this.onSearch,
    required this.onClear,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                tooltip: "Clear Filters",
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ...fields.map((field) {
                    // Check if it's a dropdown or textfield and give it proper width
                    double? width;
                    if (constraints.maxWidth > 900) {
                      width = (constraints.maxWidth - (fields.length * 12) - 150) / fields.length;
                    } else if (constraints.maxWidth > 600) {
                      width = (constraints.maxWidth - 24) / 2;
                    } else {
                      width = constraints.maxWidth;
                    }
                    
                    return SizedBox(
                      width: width,
                      child: field,
                    );
                  }),
                  SizedBox(
                    width: constraints.maxWidth > 600 ? 150 : constraints.maxWidth,
                    child: ElevatedButton.icon(
                      onPressed: onSearch,
                      icon: const Icon(Icons.search),
                      label: const Text("Search"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1E3A8A),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Helper for search fields within BaseSearchBar
class BaseSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final VoidCallback? onSubmitted;

  const BaseSearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: (_) => onSubmitted?.call(),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
          prefixIcon: Icon(icon, color: Colors.white, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

/// Helper for dropdowns within BaseSearchBar
class BaseSearchDropdown<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final IconData icon;

  const BaseSearchDropdown({
    super.key,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 20),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13),
                dropdownColor: const Color(0xFF1E3A8A),
                hint: Text(hint, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                isExpanded: true,
                items: items,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
