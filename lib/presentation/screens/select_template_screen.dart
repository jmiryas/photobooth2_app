// lib/presentation/screens/select_template_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/enums/template_type.dart';
import '../providers/booth_provider.dart';

class SelectTemplateScreen extends StatelessWidget {
  const SelectTemplateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BoothProvider>();
    final isAnySelected = provider.hasSelectedTemplate;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Header
              Text(
                'Pilih Desain Fotomu',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ketuk desain yang kamu suka',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: AppColors.textSub,
                ),
              ),

              const SizedBox(height: 32),

              // Template Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: TemplateType.values.length,
                  itemBuilder: (context, index) {
                    final template = TemplateType.values[index];
                    final isSelected = provider.selectedTemplate == template;

                    return _TemplateCard(
                      template: template,
                      isSelected: isSelected,
                      onTap: () => context.read<BoothProvider>().selectTemplate(
                        template,
                      ),
                    );
                  },
                ),
              ),

              // Continue Button
              _buildContinueButton(context, isAnySelected),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context, bool isEnabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: GestureDetector(
        onTap: isEnabled
            ? () => Provider.of<BoothProvider>(
                context,
                listen: false,
              ).confirmTemplate()
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: isEnabled ? AppColors.primaryGradient : null,
            color: isEnabled ? null : AppColors.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(100),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'LANJUT',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isEnabled
                      ? AppColors.surface
                      : AppColors.textSub.withValues(alpha: 0.5),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                color: isEnabled
                    ? AppColors.surface
                    : AppColors.textSub.withValues(alpha: 0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final TemplateType template;
  final bool isSelected;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.template,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 4,
          ),
          boxShadow: isSelected ? AppColors.innerShadow : AppColors.softShadow,
        ),
        child: Stack(
          children: [
            if (isSelected)
              const Positioned(
                top: 16,
                right: 16,
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _TemplatePreview(template: template, isSelected: isSelected),
                  const SizedBox(height: 12),
                  Text(
                    template.label.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textMain,
                    ),
                  ),
                  Text(
                    '(${template.description})',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: AppColors.textSub,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplatePreview extends StatelessWidget {
  final TemplateType template;
  final bool isSelected;

  const _TemplatePreview({required this.template, required this.isSelected});

  Widget _slot() => Expanded(
    child: Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.15)
            : AppColors.surfaceVariant,
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : AppColors.textSub.withValues(alpha: 0.3),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    Widget content;

    switch (template.layout) {
      case PhotoLayout.single:
        content = Column(children: [_slot()]);
        break;
      case PhotoLayout.vertical:
        content = Column(
          children: List.generate(template.photoCount, (_) => _slot()),
        );
        break;
      case PhotoLayout.grid2x2:
        content = Column(
          children: [
            Expanded(child: Row(children: [_slot(), _slot()])),
            Expanded(child: Row(children: [_slot(), _slot()])),
          ],
        );
        break;
    }

    return Container(
      width: 60,
      height: 80,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.surfaceVariant,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: content,
    );
  }
}
