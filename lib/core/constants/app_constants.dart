// lib/core/constants/app_constants.dart
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Our Memories Photobooth';
  static const String brandName = 'Our Memories';

  // Pricing
  static const int pricePerSession = 10000;
  static const String currency = 'Rp';

  // Session Config
  static const int retakeQuota = 3;
  static const int countdownSeconds = 3;
  static const int paymentTimeoutSeconds = 300; // 5 menit
  static const int doneScreenTimeoutSeconds = 180; // 3 menit

  // Printer Config
  static const String targetPrinterName = 'RPP02N';
  static const int printerWidthPx = 384; // 58mm @ 203dpi
  static const int printerWidthMm = 58;

  // Photo Config
  static const int photoQuality = 85;
  static const double photoAspectRatio = 3 / 2;

  // Template IDs
  static const String templateSolo = 'Solo';
  static const String templateDuo = 'Duo';
  static const String templateTrio = 'Trio';
  static const String templateQuadro = 'Quadro';
}
