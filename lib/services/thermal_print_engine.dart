// lib/services/thermal_print_engine.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../core/constants/app_constants.dart';
import 'print_service.dart';

class ThermalPrintEngine {
  final PrintService _printService;

  ThermalPrintEngine(this._printService);

  /// Render widget ke PNG bytes dengan high quality
  Future<Uint8List> widgetToImage(
    Widget widget, {
    required double width,
    double pixelRatio = 2.0,
  }) async {
    final repaintBoundary = RenderRepaintBoundary();

    final renderView = RenderView(
      view: ui.PlatformDispatcher.instance.views.first,
      child: RenderPositionedBox(
        alignment: Alignment.center,
        child: repaintBoundary,
      ),
      configuration: ViewConfiguration(
        logicalConstraints: BoxConstraints(
          minWidth: width,
          maxWidth: width,
          minHeight: 0.0,
          maxHeight: double.infinity,
        ),
        physicalConstraints: BoxConstraints(
          minWidth: width * pixelRatio,
          maxWidth: width * pixelRatio,
          minHeight: 0.0,
          maxHeight: double.infinity,
        ),
        devicePixelRatio: pixelRatio,
      ),
    );

    final pipelineOwner = PipelineOwner();
    final buildOwner = BuildOwner(focusManager: FocusManager());

    final rootElement = RenderObjectToWidgetAdapter(
      container: repaintBoundary,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: const MediaQueryData(size: Size(384, 800)),
          child: Material(color: Colors.white, child: widget),
        ),
      ),
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final image = await repaintBoundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  /// Process image untuk thermal printer
  Future<img.Image> processForThermal(
    dynamic input, {
    int targetWidth = AppConstants.printerWidthPx,
    bool applyDithering = true,
  }) async {
    img.Image? sourceImage;

    if (input is Uint8List) {
      sourceImage = img.decodeImage(input);
    } else if (input is String) {
      final file = File(input);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        sourceImage = img.decodeImage(bytes);
      }
    } else if (input is img.Image) {
      sourceImage = input;
    }

    if (sourceImage == null) {
      throw ThermalPrintException('Failed to decode image');
    }

    // 1. Resize ke width printer
    final resized = img.copyResize(
      sourceImage,
      width: targetWidth,
      maintainAspect: true,
    );

    // 2. Grayscale
    final grayscale = img.grayscale(resized.clone());

    // 3. Dithering dengan library (Floyd-Steinberg) - Versi Image v4
    if (applyDithering) {
      return img.quantize(
        grayscale,
        numberOfColors: 2,
        dither: img.DitherKernel.floydSteinberg,
      );
    }

    // 4. Fallback: Threshold manual (pengganti img.threshold)
    for (final p in grayscale) {
      final luma = p.luminance;
      if (luma > 128) {
        p.setRgb(255, 255, 255);
      } else {
        p.setRgb(0, 0, 0);
      }
    }
    return grayscale;
  }

  /// Convert image ke format ESC/POS untuk printer
  Future<List<int>> convertToEscPos(img.Image image) async {
    final List<int> bytes = [];

    // ESC/POS header untuk image
    bytes.addAll([0x1D, 0x76, 0x30, 0x00]); // GS v 0

    final width = image.width;
    final height = image.height;
    final widthBytes = (width + 7) ~/ 8;

    // Width (xL, xH)
    bytes.add(widthBytes & 0xFF);
    bytes.add((widthBytes >> 8) & 0xFF);

    // Height (yL, yH)
    bytes.add(height & 0xFF);
    bytes.add((height >> 8) & 0xFF);

    // Pixel data (1 bit per pixel)
    for (int y = 0; y < height; y++) {
      for (int xByte = 0; xByte < widthBytes; xByte++) {
        int byte = 0;
        for (int bit = 0; bit < 8; bit++) {
          final x = xByte * 8 + bit;
          if (x < width) {
            final pixel = image.getPixel(x, y);
            // Jika pixel gelap (threshold), set bit
            if (pixel.r < 128) {
              byte |= (0x80 >> bit);
            }
          }
        }
        bytes.add(byte);
      }
    }

    return bytes;
  }

  /// Full pipeline: Widget → Print
  Future<bool> printWidget(
    Widget widget, {
    String? label,
    Function(double progress)? onProgress,
  }) async {
    try {
      onProgress?.call(0.1);

      // 1. Render widget ke image
      final imageBytes = await widgetToImage(
        widget,
        width: AppConstants.printerWidthPx.toDouble(),
      );

      onProgress?.call(0.3);

      // 2. Process untuk thermal
      final processed = await processForThermal(imageBytes);

      onProgress?.call(0.5);

      // 3. Convert ke ESC/POS
      // final escPosData = await convertToEscPos(processed); // PERBAIKAN: Diberi komen karena variabel ini tidak dipakai (menghindari warning)

      onProgress?.call(0.7);

      // 4. Print via blue_thermal_printer
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        path.join(
          tempDir.path,
          'receipt_${DateTime.now().millisecondsSinceEpoch}.png',
        ),
      );

      // Save processed image
      await tempFile.writeAsBytes(img.encodePng(processed));

      onProgress?.call(0.8);

      // Print menggunakan blue_thermal_printer
      final result = await _printViaBlueThermal(tempFile.path);

      onProgress?.call(1.0);

      // Cleanup
      try {
        await tempFile.delete();
      } catch (_) {}

      return result;
    } catch (e) {
      debugPrint('Thermal print error: $e');
      return false;
    }
  }

  /// Print menggunakan blue_thermal_printer
  Future<bool> _printViaBlueThermal(String imagePath) async {
    try {
      // Ensure connected
      if (!_printService.isConnected) {
        final connected = await _printService.connectToPrinter();
        if (!connected) return false;
      }

      // PERBAIKAN: Baca file menjadi Uint8List karena printImage tidak menerima String
      final Uint8List imageBytes = await File(imagePath).readAsBytes();
      await _printService.printImage(imageBytes);

      // Feed paper
      await _printService.feedPaper(3);

      return true;
    } catch (e) {
      debugPrint('Print via blue_thermal error: $e');
      return false;
    }
  }

  /// Process multiple photos untuk strip layout
  Future<img.Image> createPhotoStrip(
    List<String> photoPaths,
    int targetWidth, {
    int spacing = 4,
    int padding = 12,
  }) async {
    if (photoPaths.isEmpty) {
      throw ThermalPrintException('No photos provided');
    }

    final List<img.Image> images = [];
    for (final p in photoPaths) {
      final file = File(p);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final decoded = img.decodeImage(bytes);
        if (decoded != null) {
          images.add(decoded);
        }
      }
    }

    if (images.isEmpty) {
      throw ThermalPrintException('No valid photos to process');
    }

    final availableWidth = targetWidth - (padding * 2);

    // PERBAIKAN: Hindari penamaan variabel 'img' agar tidak bentrok dengan package img
    final resizedImages = images.map((image) {
      return img.copyResize(image, width: availableWidth, maintainAspect: true);
    }).toList();

    int totalHeight = padding * 2;
    for (int i = 0; i < resizedImages.length; i++) {
      totalHeight += resizedImages[i].height
          .toInt(); // PERBAIKAN: Gunakan .toInt()
      if (i < resizedImages.length - 1) {
        totalHeight += spacing;
      }
    }

    final canvas = img.Image(width: targetWidth, height: totalHeight);

    canvas.clear(
      img.ColorUint8.rgb(255, 255, 255),
    ); // PERBAIKAN: Gunakan clear() untuk fill

    int currentY = padding;
    for (final photo in resizedImages) {
      img.compositeImage(canvas, photo, dstX: padding, dstY: currentY);
      currentY += photo.height.toInt() + spacing; // PERBAIKAN: Gunakan .toInt()
    }

    return canvas;
  }

  /// Generate receipt widget berdasarkan template type
  Widget generateReceiptWidget({
    required String templateType,
    required List<String> photoPaths,
    required TransactionModel transaction,
  }) {
    // Import receipt templates
    final templates = _getReceiptTemplates(
      photoPaths: photoPaths,
      transaction: transaction,
    );

    return templates[templateType] ?? templates[AppConstants.templateSolo]!;
  }

  Map<String, Widget> _getReceiptTemplates({
    required List<String> photoPaths,
    required TransactionModel transaction,
  }) {
    // These will be imported from receipt_templates.dart
    // Placeholder implementation - actual widgets in receipt_templates.dart
    return {
      AppConstants.templateSolo: Container(), // T1TransportReceipt
      AppConstants.templateDuo: Container(), // T2CafeReceipt
      AppConstants.templateTrio: Container(), // T3BankReceipt
      AppConstants.templateQuadro: Container(), // T4ConcertReceipt
    };
  }
}

class ThermalPrintException implements Exception {
  final String message;
  ThermalPrintException(this.message);

  @override
  String toString() => 'ThermalPrintException: $message';
}

// Model untuk transaction (simplified)
class TransactionModel {
  final String orderNumber;
  final DateTime timestamp;
  final List<TransactionItem> items;
  final int taxAmount;
  final int discountAmount;
  final int total;

  TransactionModel({
    required this.orderNumber,
    required this.timestamp,
    required this.items,
    this.taxAmount = 0,
    this.discountAmount = 0,
    required this.total,
  });
}

class TransactionItem {
  final String name;
  final int quantity;
  final int price;

  TransactionItem({required this.name, this.quantity = 1, required this.price});

  int get total => quantity * price;
}
