// lib/services/thermal_print_engine.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../core/constants/app_constants.dart';
import 'print_service.dart';

class ThermalPrintEngine {
  final PrintService _printService;

  ThermalPrintEngine(this._printService);

  /// Process dan print widget
  Future<bool> printWidget(
    Widget widget, {
    String? label,
    Function(double progress)? onProgress,
  }) async {
    try {
      onProgress?.call(0.1);

      // 1. Render widget ke raw image bytes
      final imageBytes = await _renderWidgetToImage(widget);
      onProgress?.call(0.3);

      // 2. Process image (Resize, Grayscale, Dithering, dan Standarisasi RGB)
      final processedImage = await _processImage(imageBytes);
      onProgress?.call(0.6);

      // 3. Encode kembali ke format PNG murni (tanpa metadata palette yang merusak)
      final finalBytes = Uint8List.fromList(img.encodePng(processedImage));
      onProgress?.call(0.8);

      // 4. Serahkan ke PrintService.
      // PrintService akan mengurus penulisan temp file, pengiriman ke bluetooth,
      // update status stream, dan mendorong kertas (feed paper).
      final result = await _printService.printImage(finalBytes, label: label);

      onProgress?.call(1.0);
      return result;
    } catch (e) {
      debugPrint('Thermal print error: $e');
      return false;
    }
  }

  /// Render widget ke bytes
  Future<Uint8List> _renderWidgetToImage(Widget widget) async {
    // Render placeholder manual
    final image = img.Image(width: 384, height: 600);

    // Warnai background jadi putih solid (mencegah alpha/transparansi)
    for (final p in image) {
      p.setRgb(255, 255, 255);
    }

    img.drawString(
      image,
      'OUR MEMORIES',
      font: img.arial24,
      x: 100,
      y: 50,
      color: img.ColorRgb8(0, 0, 0),
    );

    return Uint8List.fromList(img.encodePng(image));
  }

  /// Process image untuk thermal (Production Standard)
  Future<img.Image> _processImage(Uint8List input) async {
    final source = img.decodeImage(input);
    if (source == null) throw Exception('Failed to decode image');

    // 1. Resize menggunakan Interpolasi Cubic agar foto tetap tajam
    final resized = img.copyResize(
      source,
      width: AppConstants.printerWidthPx,
      maintainAspect: true,
      interpolation: img.Interpolation.cubic,
    );

    // 2. Grayscale dasar
    final gray = img.grayscale(resized.clone());

    // 3. Dithering (Floyd-Steinberg) untuk ilusi gradasi foto
    final dithered = img.quantize(
      gray,
      numberOfColors: 2,
      dither: img.DitherKernel.floydSteinberg,
    );

    // 4. STANDARISASI RGB:
    // Menyalin pixel ke kanvas baru agar metadata Indexed Palette dari dithered hancur.
    // Ini memastikan Android BitmapFactory bisa membaca bytes dengan sempurna
    // tanpa mendeteksinya sebagai pixel kosong.
    final printableImage = img.Image(
      width: dithered.width,
      height: dithered.height,
    );

    for (final p in printableImage) {
      final sourcePixel = dithered.getPixel(p.x, p.y);
      p.setRgb(sourcePixel.r, sourcePixel.g, sourcePixel.b);
    }

    return printableImage;
  }
}
