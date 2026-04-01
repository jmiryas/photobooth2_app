// lib/presentation/screens/done_screen.dart (UPDATED dengan print)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/enums/template_type.dart';
import '../../domain/models/transaction_model.dart' as models;
import '../providers/booth_provider.dart';
import '../providers/print_provider.dart';
import '../widgets/receipt/receipt_templates.dart';

class DoneScreen extends StatefulWidget {
  const DoneScreen({super.key});

  @override
  State<DoneScreen> createState() => _DoneScreenState();
}

class _DoneScreenState extends State<DoneScreen> {
  bool _hasPrinted = false;

  @override
  void initState() {
    super.initState();
    // Auto print setelah screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoPrint();
    });
  }

  Future<void> _autoPrint() async {
    if (_hasPrinted) return;

    final boothProvider = context.read<BoothProvider>();
    final printProvider = context.read<PrintProvider>();

    final template = boothProvider.selectedTemplate;
    final photos = boothProvider.capturedPhotos;

    if (template == null || photos.isEmpty) return;

    // Generate transaction
    // Generate transaction
    final transaction = models.TransactionModel(
      orderNumber: models.TransactionModel.generateOrderNumber(),
      timestamp: DateTime.now(),
      items: [
        models.TransactionItem(
          name: 'Foto ${template.label} · 1 sesi',
          price: AppConstants.pricePerSession,
        ),
      ],
      // Cukup masukkan persentasenya saja, model Anda akan otomatis
      // menghitung taxAmount, discountAmount, dan total-nya!
      taxPercent: 11.0,
      discountPercent: 0.0,
    );

    // Generate receipt widget berdasarkan template
    Widget receiptWidget;
    switch (template) {
      case TemplateType.solo:
        receiptWidget = T1TransportReceipt(
          photoPath: photos.first,
          transaction: transaction,
        );
        break;
      case TemplateType.duo:
        receiptWidget = T2CafeReceipt(
          photoPaths: photos,
          transaction: transaction,
        );
        break;
      case TemplateType.trio:
        receiptWidget = T3BankReceipt(
          photoPaths: photos,
          transaction: transaction,
        );
        break;
      case TemplateType.quadro:
        receiptWidget = T4ConcertReceipt(
          photoPaths: photos,
          transaction: transaction,
        );
        break;
    }

    // Print
    final success = await printProvider.printWidget(receiptWidget);

    setState(() {
      _hasPrinted = success;
    });
  }

  @override
  Widget build(BuildContext context) {
    final boothProvider = context.watch<BoothProvider>();
    final printProvider = context.watch<PrintProvider>();

    final isPrinting = printProvider.isPrinting;
    final progress = printProvider.progress;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Title
                Text(
                  isPrinting
                      ? 'Yey! Fotomu Sedang Dicetak!'
                      : (_hasPrinted
                            ? 'Yey! Cetak Selesai!'
                            : 'Siap Mencetak!'),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMain,
                  ),
                ),

                const SizedBox(height: 40),

                // Main Card
                _buildStatusCard(isPrinting, progress, printProvider),

                const SizedBox(height: 32),

                // Auto reset timer
                if (!isPrinting)
                  Text(
                    'Otomatis kembali ke awal dalam ${boothProvider.formattedDoneTime}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppColors.textSub,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                if (!isPrinting) const SizedBox(height: 16),

                // End Session Button
                _buildEndButton(context, isPrinting),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    bool isPrinting,
    double progress,
    PrintProvider printProvider,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(40),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          // Status Icon
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isPrinting
                  ? AppColors.primary.withOpacity(0.1)
                  : (_hasPrinted
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.warning.withOpacity(0.1)),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPrinting
                  ? Icons.print_rounded
                  : (_hasPrinted ? Icons.check_circle_rounded : Icons.pending),
              size: 64,
              color: isPrinting
                  ? AppColors.primary
                  : (_hasPrinted ? AppColors.success : AppColors.warning),
            ),
          ),

          const SizedBox(height: 24),

          // Status Text
          Text(
            printProvider.statusMessage.isNotEmpty
                ? printProvider.statusMessage
                : (isPrinting
                      ? 'Menyiapkan mesin cetak...'
                      : (_hasPrinted
                            ? 'Silakan ambil setruk fotomu!'
                            : 'Menunggu cetak...')),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isPrinting
                  ? AppColors.primary
                  : (_hasPrinted ? AppColors.success : AppColors.warning),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSub,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isPrinting
                      ? AppColors.primary
                      : (_hasPrinted ? AppColors.success : AppColors.warning),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.surfaceVariant,
            color: isPrinting
                ? AppColors.primary
                : (_hasPrinted ? AppColors.success : AppColors.warning),
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
          ),

          const SizedBox(height: 32),

          const Divider(color: AppColors.surfaceVariant, thickness: 1.5),

          const SizedBox(height: 32),

          // QR Download
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  size: 70,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unduh Versi Digital',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Scan QR ini dengan kamera HP-mu untuk mendownload foto asli.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppColors.textSub,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEndButton(BuildContext context, bool isPrinting) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 32, bottom: 32),
      child: GestureDetector(
        onTap: isPrinting
            ? null
            : () => context.read<BoothProvider>().endSessionEarly(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            gradient: isPrinting ? null : AppColors.primaryGradient,
            color: isPrinting ? AppColors.surfaceVariant : null,
            borderRadius: BorderRadius.circular(100),
            boxShadow: isPrinting
                ? []
                : [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.power_settings_new_rounded,
                color: isPrinting
                    ? AppColors.textSub.withOpacity(0.5)
                    : Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'AKHIRI SESI',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isPrinting
                      ? AppColors.textSub.withOpacity(0.5)
                      : Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
