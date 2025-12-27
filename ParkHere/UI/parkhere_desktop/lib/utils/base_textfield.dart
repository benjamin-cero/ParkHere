import 'package:flutter/material.dart';

// ---------------------------
// Input Decoration Helper
// ---------------------------
InputDecoration customTextFieldDecoration(
  String label, {
  IconData? prefixIcon,
  IconData? suffixIcon,
  String? hintText,
  bool isError = false,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hintText,
    filled: true,
    fillColor: const Color(0xFFF1F5F9),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),

    border: OutlineInputBorder(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
      borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
      borderSide: const BorderSide(
        color: Color(0xFFCBD5E1),
        width: 1.5,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
      borderSide: const BorderSide(
        color: Color(0xFF3B82F6),
        width: 2.5,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.0),
      borderSide: const BorderSide(color: Color(0xFFE53E3E), width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.0),
      borderSide: const BorderSide(color: Color(0xFFE53E3E), width: 2.5),
    ),
    prefixIcon: prefixIcon != null
        ? Icon(
            prefixIcon,
            color: isError 
              ? const Color(0xFFE53E3E) 
              : const Color(0xFF64748B),
            size: 22,
          )
        : null,
    suffixIcon: suffixIcon != null
        ? Icon(
            suffixIcon, 
            color: const Color(0xFF64748B), 
            size: 22,
          )
        : null,
    labelStyle: TextStyle(
      color: isError ? const Color(0xFFE53E3E) : const Color(0xFF475569),
      fontSize: 15,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
    ),
    hintStyle: const TextStyle(
      color: Color(0xFF94A3B8),
      fontSize: 15,
      fontWeight: FontWeight.w400,
    ),
    floatingLabelStyle: const TextStyle(
      color: Color(0xFF2563EB),
      fontSize: 15,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    ),
  );
}

// ---------------------------
// Custom Text Field Helper with Animation
// ---------------------------
class AnimatedTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final String? hintText;
  final bool isError;
  final double? width;
  final VoidCallback? onSubmitted;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;

  const AnimatedTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
    this.isError = false,
    this.width,
    this.onSubmitted,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines,
    this.maxLength,
  }) : super(key: key);

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.01).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget textField = Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
          if (hasFocus) {
            _animationController.forward();
          } else {
            _animationController.reverse();
          }
        });
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: TextField(
            controller: widget.controller,
            decoration: customTextFieldDecoration(
              widget.label,
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon,
              hintText: widget.hintText,
              isError: widget.isError,
            ),
            onSubmitted: (_) {
              if (widget.onSubmitted != null) {
                widget.onSubmitted!();
              }
            },
            enabled: widget.enabled,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
          ),
        ),
      ),
    );

    if (widget.width != null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(width: widget.width, child: textField),
      );
    }

    return textField;
  }
}

// Legacy helper function - now uses AnimatedTextField
Widget customTextField({
  required String label,
  required TextEditingController controller,
  IconData? prefixIcon,
  IconData? suffixIcon,
  String? hintText,
  bool isError = false,
  double? width,
  VoidCallback? onSubmitted,
  bool enabled = true,
  bool obscureText = false,
  TextInputType? keyboardType,
  int? maxLines,
  int? maxLength,
}) {
  return AnimatedTextField(
    label: label,
    controller: controller,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    hintText: hintText,
    isError: isError,
    width: width,
    onSubmitted: onSubmitted,
    enabled: enabled,
    obscureText: obscureText,
    keyboardType: keyboardType,
    maxLines: maxLines,
    maxLength: maxLength,
  );
}

// ---------------------------
// Custom Dropdown Helper
// ---------------------------
Widget customDropdownField<T>({
  required String label,
  required T? value,
  required List<DropdownMenuItem<T>> items,
  required ValueChanged<T?> onChanged,
  IconData? prefixIcon,
  String? hintText,
  bool isError = false,
  double? width,
}) {
  Widget dropdown = DropdownButtonFormField<T>(
    decoration: customTextFieldDecoration(
      label,
      prefixIcon: prefixIcon,
      hintText: hintText,
      isError: isError,
    ),
    value: value,
    items: items,
    onChanged: onChanged,
  );

  if (width != null) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(width: width, child: dropdown),
    );
  }

  return dropdown;
}
