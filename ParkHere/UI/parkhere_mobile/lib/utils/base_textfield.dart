import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2B6CB0); // Deep Blue
  static const Color primaryDark = Color(0xFF1A365D); // Navy Blue
  static const Color primaryLight = Color(0xFF4299E1); // Sky Blue
  static const Color accent = Color(0xFF63B3ED); // Light Blue
  static const Color background = Color(0xFFF7FAFC);
  static const Color surface = Colors.white;
  static const Color text = Color(0xFF2D3748);
  static const Color textLight = Color(0xFF718096);
  static const Color error = Color(0xFFE53E3E);
  static const Color glassBackground = Color(0x33FFFFFF);
  static const Color glassBorder = Color(0x4DFFFFFF);

  // Status Colors
  static const Color disabled = Color(0xFF667EEA); // Indigo/Purple
  static const Color reserved = Color(0xFFFFCC00); // Yellow/Gold
  static const Color occupied = Color(0xFFE53E3E); // Red
}

class AppGradients {
  static const LinearGradient mainBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primaryDark,
      Color(0xFF2A4365),
      AppColors.primary,
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final bool obscureText;
  final String? hintText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.prefixIcon,
    this.obscureText = false,
    this.hintText,
    this.keyboardType,
    this.suffixIcon,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ]
              : [],
        ),
        child: Focus(
          onFocusChange: (hasFocus) {
            setState(() => _isFocused = hasFocus);
            hasFocus ? _controller.forward() : _controller.reverse();
          },
          child: TextField(
            controller: widget.controller,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            style: const TextStyle(color: AppColors.text, fontSize: 16),
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hintText,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, color: AppColors.primary)
                  : null,
              suffixIcon: widget.suffixIcon,
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[200]!, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[200]!, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              labelStyle: TextStyle(
                  color: _isFocused ? AppColors.primary : AppColors.textLight),
            ),
          ),
        ),
      ),
    );
  }
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outline;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.outline = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (outline) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(text,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: onPressed != null ? AppGradients.buttonGradient : null,
        color: onPressed == null ? Colors.grey[300] : null,
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                )
              ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 22, color: Colors.white.withOpacity(0.9)),
                    const SizedBox(width: 8),
                  ],
                  Text(text,
                      style:
                          const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ],
              ),
      ),
    );
  }
}
