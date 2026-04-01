// lib/presentation/screens/preview_screen.dart
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/enums/template_type.dart';
import '../providers/booth_provider.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BoothProvider>();
    final template = provider.selectedTemplate;

    if (template == null) return const SizedBox.shrink();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 32),

              // Header
              Text(
                'Lihat Hasil Fotomu',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ketuk foto yang ingin diambil ulang',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: AppColors.textSub,
                ),
              ),

              const SizedBox(height: 24),

              // Photo Grid
              Expanded(child: _buildPhotoGrid(context, provider, template)),

              const SizedBox(height: 24),

              // Retake Counter
              _buildRetakeCounter(provider),

              const SizedBox(height: 16),

              // Action Buttons
              _buildActionButtons(context, provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoGrid(
    BuildContext context,
    BoothProvider provider,
    TemplateType template,
  ) {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: AppColors.softShadow,
        ),
        child: _buildLayoutByType(context, provider, template),
      ),
    );
  }

  Widget _buildLayoutByType(
    BuildContext context,
    BoothProvider provider,
    TemplateType template,
  ) {
    final photos = provider.capturedPhotos;

    switch (template.layout) {
      case PhotoLayout.single:
        return _PhotoSlot(
          context: context,
          provider: provider,
          index: 0,
          photoPath: photos.isNotEmpty ? photos[0] : '',
        );

      case PhotoLayout.vertical:
        return Column(
          children: List.generate(
            template.photoCount,
            (index) => Expanded(
              child: _PhotoSlot(
                context: context,
                provider: provider,
                index: index,
                photoPath: index < photos.length ? photos[index] : '',
              ),
            ),
          ),
        );

      case PhotoLayout.grid2x2:
        return Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _PhotoSlot(
                      context: context,
                      provider: provider,
                      index: 0,
                      photoPath: photos.isNotEmpty ? photos[0] : '',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PhotoSlot(
                      context: context,
                      provider: provider,
                      index: 1,
                      photoPath: photos.length > 1 ? photos[1] : '',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _PhotoSlot(
                      context: context,
                      provider: provider,
                      index: 2,
                      photoPath: photos.length > 2 ? photos[2] : '',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PhotoSlot(
                      context: context,
                      provider: provider,
                      index: 3,
                      photoPath: photos.length > 3 ? photos[3] : '',
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }

  Widget _buildRetakeCounter(BoothProvider provider) {
    final retakeLeft = provider.retakeLeft;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Sisa Kesempatan Retake',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textSub,
            ),
          ),
          Text(
            '${retakeLeft}x',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: retakeLeft > 0 ? AppColors.primary : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, BoothProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 32, bottom: 32),
      child: Row(
        children: [
          // Retake Button
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: provider.canRetake ? () => provider.processRetake() : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: provider.canRetake
                        ? AppColors.primary
                        : AppColors.surfaceVariant,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.replay_rounded,
                  color: provider.canRetake
                      ? AppColors.primary
                      : AppColors.textSub.withOpacity(0.3),
                  size: 28,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Continue Button
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () => provider.confirmPhotos(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'LANJUT KE PEMBAYARAN',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.surface,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.surface,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  final BuildContext context;
  final BoothProvider provider;
  final int index;
  final String photoPath;

  const _PhotoSlot({
    required this.context,
    required this.provider,
    required this.index,
    required this.photoPath,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = provider.currentPhotoIndex == index;
    final hasPhoto = photoPath.isNotEmpty;

    return GestureDetector(
      onTap: () => provider.selectPhotoForRetake(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 4,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo dengan mirror effect
              if (hasPhoto)
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: Image.file(File(photoPath), fit: BoxFit.cover),
                )
              else
                const Center(child: CircularProgressIndicator()),

              // Selection overlay
              if (isSelected)
                Container(color: AppColors.primary.withOpacity(0.3)),
              if (isSelected)
                const Center(
                  child: Icon(
                    Icons.replay_rounded,
                    color: AppColors.surface,
                    size: 48,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
