// lib/presentation/providers/print_provider.dart (COMPLETE)
import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/print_service.dart';
import '../../services/thermal_print_engine.dart';

class PrintProvider extends ChangeNotifier {
  final PrintService _printService;
  late final ThermalPrintEngine _printEngine;

  PrintProvider(this._printService) {
    _printEngine = ThermalPrintEngine(_printService);
  }

  // State
  PrintStatus _status = PrintStatus.idle;
  String _statusMessage = '';
  double _progress = 0.0;
  bool _isPrinting = false;

  // Getters
  PrintStatus get status => _status;
  String get statusMessage => _statusMessage;
  double get progress => _progress;
  bool get isPrinting => _isPrinting;
  bool get isConnected => _printService.isConnected;

  StreamSubscription? _statusSubscription;

  PrintProvider initialize() {
    _statusSubscription = _printService.statusStream.listen((statusData) {
      _status = statusData.status;
      _statusMessage = statusData.message;
      notifyListeners();
    });
    return this;
  }

  /// Connect ke printer
  Future<bool> connectPrinter({String? targetName}) async {
    _isPrinting = true;
    _progress = 0.0;
    notifyListeners();

    final result = await _printService.connectToPrinter(targetName: targetName);

    _isPrinting = false;
    notifyListeners();
    return result;
  }

  /// Disconnect printer
  Future<void> disconnectPrinter() async {
    await _printService.disconnect();
    notifyListeners();
  }

  /// Print widget (full pipeline)
  Future<bool> printWidget(Widget widget, {String? label}) async {
    _isPrinting = true;
    _progress = 0.0;
    _status = PrintStatus.printing;
    _statusMessage = label ?? 'Mencetak...';
    notifyListeners();

    final result = await _printEngine.printWidget(
      widget,
      label: label,
      onProgress: (p) {
        _progress = p;
        notifyListeners();
      },
    );

    _isPrinting = false;
    _progress = result ? 1.0 : 0.0;
    _status = result ? PrintStatus.completed : PrintStatus.error;
    _statusMessage = result ? 'Cetak selesai!' : 'Gagal mencetak';
    notifyListeners();
    return result;
  }

  /// Quick print untuk testing
  Future<bool> printTest() async {
    if (!isConnected) {
      final connected = await connectPrinter();
      if (!connected) return false;
    }

    await _printService.printText(
      'TEST PRINT',
      size: 2,
      bold: true,
      center: true,
    );

    await _printService.feedPaper(3);
    return true;
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _printService.dispose();
    super.dispose();
  }
}

// enum PrintStatus { idle, connecting, connected, printing, completed, error }

// class PrintStatusData {
//   final PrintStatus status;
//   final String message;

//   PrintStatusData(this.status, this.message);
// }
