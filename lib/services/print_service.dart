import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../core/constants/app_constants.dart';

// ⭐ TAMBAHKAN: Enum PrintStatus
enum PrintStatus { idle, connecting, connected, printing, completed, error }

// ⭐ TAMBAHKAN: Class PrintStatusData
class PrintStatusData {
  final PrintStatus status;
  final String message;

  PrintStatusData(this.status, this.message);
}

class PrintService {
  final BlueThermalPrinter _printer = BlueThermalPrinter.instance;

  BluetoothDevice? _connectedDevice;
  bool _isConnecting = false;

  StreamController<PrintStatusData>? _statusController;

  Stream<PrintStatusData> get statusStream {
    _statusController ??= StreamController<PrintStatusData>.broadcast();
    return _statusController!.stream;
  }

  bool get isConnected => _connectedDevice != null;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  /// Scan dan return list paired devices
  Future<List<BluetoothDevice>> getPairedDevices() async {
    try {
      final devices = await _printer.getBondedDevices();
      debugPrint('Found ${devices.length} paired devices');
      return devices;
    } catch (e) {
      debugPrint('Error getting paired devices: $e');
      return [];
    }
  }

  /// Connect ke printer target
  Future<bool> connectToPrinter({String? targetName}) async {
    if (_isConnecting) return false;

    final target = targetName ?? AppConstants.targetPrinterName;

    try {
      _isConnecting = true;
      _emitStatus(PrintStatus.connecting, 'Mencari printer...');

      final devices = await getPairedDevices();

      if (devices.isEmpty) {
        _emitStatus(PrintStatus.error, 'Tidak ada printer terdaftar');
        return false;
      }

      // Cari printer target
      BluetoothDevice? targetDevice;
      try {
        targetDevice = devices.firstWhere((d) => d.name == target);
      } catch (_) {
        targetDevice = devices.firstWhere(
          (d) => d.name != null && d.name!.isNotEmpty,
          orElse: () => devices.first,
        );
      }

      _emitStatus(
        PrintStatus.connecting,
        'Menghubungkan ke ${targetDevice.name}...',
      );

      final bool? isConnected = await _printer.isConnected;

      if (isConnected == true &&
          _connectedDevice?.address == targetDevice.address) {
        _emitStatus(PrintStatus.connected, 'Sudah terhubung');
        return true;
      }

      if (isConnected == true) {
        await _printer.disconnect();
      }

      await _printer.connect(targetDevice);
      await Future.delayed(const Duration(milliseconds: 500));

      final bool? verifyConnection = await _printer.isConnected;

      if (verifyConnection == true) {
        _connectedDevice = targetDevice;
        _emitStatus(PrintStatus.connected, 'Terhubung ke ${targetDevice.name}');
        return true;
      } else {
        _emitStatus(PrintStatus.error, 'Gagal terhubung');
        return false;
      }
    } catch (e) {
      _emitStatus(PrintStatus.error, 'Error: $e');
      return false;
    } finally {
      _isConnecting = false;
    }
  }

  /// Disconnect printer
  Future<void> disconnect() async {
    try {
      await _printer.disconnect();
      _connectedDevice = null;
      _emitStatus(PrintStatus.idle, 'Terputus');
    } catch (e) {
      debugPrint('Disconnect error: $e');
    }
  }

  /// Print image
  Future<bool> printImage(Uint8List imageBytes, {String? label}) async {
    if (!await _ensureConnected()) return false;

    try {
      _emitStatus(PrintStatus.printing, label ?? 'Mencetak...');

      // Simpan ke file temporary
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        path.join(
          tempDir.path,
          'print_${DateTime.now().millisecondsSinceEpoch}.png',
        ),
      );

      await tempFile.writeAsBytes(imageBytes);

      // Print menggunakan blue_thermal_printer
      await _printer.printImage(tempFile.path);

      // Feed paper
      await feedPaper(3);

      // Cleanup
      try {
        await tempFile.delete();
      } catch (_) {}

      _emitStatus(PrintStatus.completed, 'Cetak selesai');
      return true;
    } catch (e) {
      _emitStatus(PrintStatus.error, 'Print failed: $e');
      return false;
    }
  }

  /// Print text (ESC/POS commands)
  Future<bool> printText(
    String text, {
    int size = 1,
    bool bold = false,
    bool center = true,
  }) async {
    if (!await _ensureConnected()) return false;

    try {
      _printer.printNewLine();

      if (center) {
        _printer.printCustom(text, size, 1);
      } else {
        _printer.printCustom(text, size, 0);
      }

      return true;
    } catch (e) {
      debugPrint('Print text error: $e');
      return false;
    }
  }

  /// Print new lines
  Future<void> feedPaper(int lines) async {
    for (int i = 0; i < lines; i++) {
      _printer.printNewLine();
    }
  }

  /// Pastikan printer connected
  Future<bool> _ensureConnected() async {
    final bool? isConnected = await _printer.isConnected;
    if (isConnected != true) {
      return await connectToPrinter();
    }
    return true;
  }

  void _emitStatus(PrintStatus status, String message) {
    debugPrint('PrintStatus: $status - $message');
    _statusController?.add(PrintStatusData(status, message));
  }

  void dispose() {
    disconnect();
    _statusController?.close();
  }
}
