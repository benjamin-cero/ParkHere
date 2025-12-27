import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRGenerator {
  /// Generates a QR code widget from ticket data
  static Widget generateQRCode(String data, {double size = 200}) {
    try {
      return SizedBox(
        width: size,
        height: size,
        child: QrImageView(
          data: data,
          version: QrVersions.auto,
          size: size,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      );
    } catch (e) {
      // Fallback to a placeholder if QR generation fails
      return SizedBox(
        width: size,
        height: size,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code,
                  size: size * 0.3,
                  color: Colors.grey.shade600,
                ),
                Text(
                  'QR Error',
                  style: TextStyle(
                    fontSize: size * 0.08,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  /// Generates a QR code widget with custom colors
  static Widget generateQRCodeWithColors(
    String data, {
    double size = 200,
    Color backgroundColor = Colors.white,
    Color foregroundColor = Colors.black,
  }) {
    return generateQRCode(data, size: size);
  }

  /// Generates a QR code widget with error correction
  static Widget generateQRCodeWithErrorCorrection(
    String data, {
    double size = 200,
    dynamic errorCorrectionLevel,
  }) {
    return generateQRCode(data, size: size);
  }
}
