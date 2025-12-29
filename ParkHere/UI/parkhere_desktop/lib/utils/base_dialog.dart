import 'package:flutter/material.dart';

enum BaseDialogType { info, success, warning, error, confirmation }

class BaseDialog {
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    BaseDialogType type = BaseDialogType.info,
    String? confirmLabel,
    String? cancelLabel,
  }) {
    Color primaryColor;
    IconData icon;
    
    switch (type) {
      case BaseDialogType.success:
        primaryColor = const Color(0xFF10B981);
        icon = Icons.check_circle_rounded;
        break;
      case BaseDialogType.error:
        primaryColor = const Color(0xFFEF4444);
        icon = Icons.error_rounded;
        break;
      case BaseDialogType.warning:
        primaryColor = const Color(0xFFF59E0B);
        icon = Icons.warning_rounded;
        break;
      case BaseDialogType.confirmation:
        primaryColor = const Color(0xFF1E3A8A);
        icon = Icons.help_rounded;
        break;
      case BaseDialogType.info:
      default:
        primaryColor = const Color(0xFF3B82F6);
        icon = Icons.info_rounded;
        break;
    }

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              // Message
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              // Actions
              Row(
                children: [
                  if (type == BaseDialogType.confirmation || cancelLabel != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          cancelLabel ?? "Cancel",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (type == BaseDialogType.confirmation || cancelLabel != null)
                    const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        confirmLabel ?? (type == BaseDialogType.confirmation ? "Confirm" : "OK"),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
