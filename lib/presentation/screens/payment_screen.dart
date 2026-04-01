// lib/presentation/screens/payment_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../providers/booth_provider.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BoothProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 32),

              // Total Card
              _buildTotalCard(),

              const SizedBox(height: 32),

              // QRIS Area
              Expanded(child: _buildQRISArea()),

              const SizedBox(height: 32),

              // Timer (double tap untuk debug)
              GestureDetector(
                onDoubleTap: () => provider.paymentSuccess(),
                child: _buildTimer(provider),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalCard() {
    final priceFormatted = AppConstants.pricePerSession
        .toString()
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          Text(
            'Total Pembayaran',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.textSub,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${AppConstants.currency} $priceFormatted',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Termasuk PPN',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQRISArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(40),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'QRIS',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.error,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.bgStart, width: 2),
            ),
            child: const Center(
              child: Icon(
                Icons.qr_code_2_rounded,
                size: 180,
                color: AppColors.textMain,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Pindai kode QRIS di atas dengan aplikasi bank atau e-wallet kamu.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.textSub,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimer(BoothProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(100),
        boxShadow: AppColors.innerShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.schedule_rounded,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'Sisa Waktu: ${provider.formattedPaymentTime}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
        ],
      ),
    );
  }
}
