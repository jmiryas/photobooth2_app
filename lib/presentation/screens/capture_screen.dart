import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../services/camera_service.dart';
import '../providers/booth_provider.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final CameraService _cameraService = CameraService();
  CameraController? _controller;

  int _countdown = 3;
  bool _isFlashScreen = false;
  bool _isProcessing = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraService.initialize();
      _controller = await _cameraService.setupController();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Kamera error: $e')));
      }
    }
  }

  // ⭐ FIXED: Pisahkan inisialisasi dan capture sequence
  Future<void> _startCaptureSequence() async {
    // Delay untuk UI siap
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    final provider = context.read<BoothProvider>();

    // Tentukan range foto yang akan di-capture
    final startIndex = provider.isRetakeMode ? provider.currentPhotoIndex : 0;
    final endIndex = provider.isRetakeMode
        ? provider.currentPhotoIndex
        : provider.totalPhotosNeeded - 1;

    for (int i = startIndex; i <= endIndex; i++) {
      if (!mounted) break;

      // ⭐ FIXED: Set index TERLEBIH DAHULU sebelum countdown
      provider.selectPhotoForRetake(i);

      // Countdown 3-2-1
      for (int c = 3; c > 0; c--) {
        if (!mounted) break;
        setState(() => _countdown = c);
        await Future.delayed(const Duration(seconds: 1));
      }

      if (!mounted) break;

      // Capture photo
      await _captureSinglePhoto(provider);

      // ⭐ FIXED: Pindah ke foto berikutnya SETELAH capture berhasil
      if (i < endIndex) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    // ⭐ FIXED: Selesaikan capture hanya jika masih mounted
    if (mounted) {
      provider.finishCapture();
    }
  }

  Future<void> _captureSinglePhoto(BoothProvider provider) async {
    setState(() {
      _isFlashScreen = true;
      _isProcessing = true;
    });

    try {
      final filePath = await _cameraService.capturePhoto();
      debugPrint('✅ Photo captured: $filePath');

      // ⭐ PENTING: Simpan foto ke provider
      provider.savePhoto(filePath);
    } catch (e) {
      debugPrint('❌ Capture error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengambil foto: $e')));
      }
    } finally {
      await Future.delayed(const Duration(milliseconds: 150));
      if (mounted) {
        setState(() {
          _isFlashScreen = false;
          _isProcessing = false;
          _countdown = 3;
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BoothProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Stack(
            children: [
              _buildMainContent(provider),
              if (_isFlashScreen) _buildFlashOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BoothProvider provider) {
    return Column(
      children: [
        const SizedBox(height: 24),

        // Progress Indicator
        _buildProgressChip(provider),

        const SizedBox(height: 24),

        // Camera Preview
        Expanded(child: _buildCameraPreview()),

        const SizedBox(height: 48),

        // ⭐ TAMBAHAN: Tombol Start Capture (untuk testing/debugging)
        if (_isInitialized && !_isProcessing)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ElevatedButton(
              onPressed: _startCaptureSequence,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt),
                  SizedBox(width: 8),
                  Text(
                    'MULAI CAPTURE',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildProgressChip(BoothProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        'Foto ${provider.currentPhotoIndex + 1} dari ${provider.totalPhotosNeeded}',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.textMain,
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    final isReady = _controller != null && _controller!.value.isInitialized;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(48),
        border: Border.all(color: AppColors.surface, width: 8),
        boxShadow: AppColors.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: isReady ? _buildActivePreview() : _buildLoadingPreview(),
      ),
    );
  }

  Widget _buildActivePreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera feed
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller!.value.previewSize!.height,
            height: _controller!.value.previewSize!.width,
            child: CameraPreview(_controller!),
          ),
        ),

        // Countdown overlay
        if (!_isFlashScreen && !_isProcessing)
          Center(
            child: Text(
              '$_countdown',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 180,
                fontWeight: FontWeight.w800,
                color: AppColors.surface,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingPreview() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.surface),
          SizedBox(height: 16),
          Text('Menyiapkan kamera...', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildFlashOverlay() {
    return Positioned.fill(child: Container(color: Colors.white));
  }
}
