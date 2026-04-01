// lib/services/camera_service.dart
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CameraService {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  bool _isInitialized = false;

  List<CameraDescription> get cameras => List.unmodifiable(_cameras);

  bool get isInitialized => _isInitialized;

  CameraController? get controller => _controller;

  /// Initialize dan dapatkan list kamera
  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
      debugPrint('Found ${_cameras.length} cameras');
    } on CameraException catch (e) {
      debugPrint('Camera initialization error: ${e.description}');
      throw CameraServiceException('Failed to get cameras: ${e.description}');
    }
  }

  /// Setup controller dengan kamera depan (default)
  Future<CameraController> setupController({
    ResolutionPreset resolution = ResolutionPreset.high,
    bool enableAudio = false,
    CameraLensDirection preferredDirection = CameraLensDirection.front,
  }) async {
    if (_cameras.isEmpty) {
      throw CameraServiceException('No cameras available');
    }

    // Pilih kamera depan jika ada
    final camera = _cameras.firstWhere(
      (c) => c.lensDirection == preferredDirection,
      orElse: () => _cameras.first,
    );

    // Dispose controller lama jika ada
    await disposeController();

    _controller = CameraController(
      camera,
      resolution,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      _isInitialized = true;
      debugPrint('Camera controller initialized: ${camera.name}');
      return _controller!;
    } on CameraException catch (e) {
      _isInitialized = false;
      throw CameraServiceException(
        'Failed to initialize controller: ${e.description}',
      );
    }
  }

  /// Ambil foto dan simpan ke temporary directory
  Future<String> capturePhoto() async {
    if (_controller == null || !_isInitialized) {
      throw CameraServiceException('Camera not initialized');
    }

    if (_controller!.value.isTakingPicture) {
      throw CameraServiceException('Already capturing');
    }

    try {
      // ⭐ PENTING: Pastikan controller masih valid
      if (!_controller!.value.isInitialized) {
        throw CameraServiceException('Camera not initialized');
      }

      final XFile photo = await _controller!.takePicture();

      // ⭐ PENTING: Verifikasi file exists
      final tempFile = File(photo.path);
      if (!await tempFile.exists()) {
        throw CameraServiceException('Captured file does not exist');
      }

      // Copy ke app directory
      final appDir = await getTemporaryDirectory();
      final fileName = 'capture_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final newPath = path.join(appDir.path, fileName);

      final savedFile = await tempFile.copy(newPath);

      // ⭐ HAPUS file temporary asli
      try {
        await tempFile.delete();
      } catch (_) {}

      debugPrint('✅ Photo saved: ${savedFile.path}');
      return savedFile.path;
    } on CameraException catch (e) {
      throw CameraServiceException('Camera error: ${e.description}');
    } catch (e) {
      throw CameraServiceException('Failed to capture: $e');
    }
  }

  /// Dispose controller
  Future<void> disposeController() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
      _isInitialized = false;
    }
  }

  /// Cleanup semua resources
  Future<void> dispose() async {
    await disposeController();
    _cameras = [];
  }
}

class CameraServiceException implements Exception {
  final String message;
  CameraServiceException(this.message);

  @override
  String toString() => 'CameraServiceException: $message';
}
