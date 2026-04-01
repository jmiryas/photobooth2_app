// lib/presentation/screens/capture_screen.dart
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

  @override
  void initState() {
    super.initState();
    _initializeAndCapture();
  }

  Future<void> _initializeAndCapture() async {
    try {
      await _cameraService.initialize();
      _controller = await _cameraService.setupController();

      if (mounted) setState(() {});

      // Delay untuk UI siap
      await Future.delayed(const Duration(milliseconds: 500));
      await _runCaptureSequence();
    } catch (e) {
      debugPrint('Camera error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Kamera error: $e')));
      }
    }
  }

  Future<void> _runCaptureSequence() async {
    final provider = context.read<BoothProvider>();

    final startIndex = provider.isRetakeMode ? provider.currentPhotoIndex : 0;
    final endIndex = provider.isRetakeMode
        ? provider.currentPhotoIndex
        : provider.totalPhotosNeeded - 1;

    for (int i = startIndex; i <= endIndex; i++) {
      if (!mounted) break;

      // Update UI index
      provider.nextPhoto();
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

      // Delay antar foto
      if (i < endIndex) {
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    if (mounted) provider.finishCapture();
  }

  Future<void> _captureSinglePhoto(BoothProvider provider) async {
    setState(() {
      _isFlashScreen = true;
      _isProcessing = true;
    });

    try {
      final filePath = await _cameraService.capturePhoto();
      provider.savePhoto(filePath);
    } catch (e) {
      debugPrint('Capture error: $e');
    } finally {
      await Future.delayed(const Duration(milliseconds: 100));
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
      ],
    );
  }

  Widget _buildProgressChip(BoothProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.8),
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
        // Camera feed dengan aspect ratio fix
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
                  Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 20),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingPreview() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.surface),
    );
  }

  Widget _buildFlashOverlay() {
    return Positioned.fill(child: Container(color: Colors.white));
  }
}
