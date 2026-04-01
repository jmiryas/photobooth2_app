// lib/presentation/widgets/receipt/receipt_templates.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import '../../../core/constants/app_constants.dart';
// import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
// import '../../../domain/enums/template_type.dart';
import '../../../domain/models/transaction_model.dart';

/// Base receipt widget dengan zigzag edges
class ReceiptContainer extends StatelessWidget {
  final List<Widget> children;
  final double width;

  const ReceiptContainer({
    super.key,
    required this.children,
    this.width = 384, // 58mm @ 203dpi
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top zigzag
          _ZigzagEdge(isTop: true),

          // Content
          ...children,

          // Bottom zigzag
          _ZigzagEdge(isTop: false),
        ],
      ),
    );
  }
}

class _ZigzagEdge extends StatelessWidget {
  final bool isTop;

  const _ZigzagEdge({required this.isTop});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(384, 10),
      painter: _ZigzagPainter(isTop: isTop),
    );
  }
}

class _ZigzagPainter extends CustomPainter {
  final bool isTop;

  _ZigzagPainter({required this.isTop});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();

    if (isTop) {
      path.moveTo(0, size.height);
      for (double i = 0; i < size.width; i += 5) {
        path.lineTo(i + 2.5, 0);
        path.lineTo(i + 5, size.height);
      }
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, 0);
      for (double i = 0; i < size.width; i += 5) {
        path.lineTo(i + 2.5, size.height);
        path.lineTo(i + 5, 0);
      }
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// T1: Transportasi 1x1
class T1TransportReceipt extends StatelessWidget {
  final String photoPath;
  final TransactionModel transaction;
  final String from;
  final String to;
  final String seatNumber;

  const T1TransportReceipt({
    super.key,
    required this.photoPath,
    required this.transaction,
    this.from = 'JKT',
    this.to = 'BDG',
    this.seatNumber = 'B-07',
  });

  @override
  Widget build(BuildContext context) {
    return ReceiptContainer(
      children: [
        // Header
        _buildHeader(),

        // Meta info
        _buildMetaRow(),

        // Divider
        const Divider(height: 1, thickness: 1, color: Colors.black),

        // Photo
        _buildPhoto(),

        // Seat info
        _buildSeatInfo(),

        // Orders
        _buildOrders(),

        // Total
        _buildTotal(),

        // Barcode
        _buildBarcode(),

        // Footer
        _buildFooter(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OUR MEMORIES',
            style: AppTypography.receiptCondensed(
              size: 15,
              weight: FontWeight.w600,
            ),
          ),
          Text(
            'PHOTOBOOTH EXPRESS',
            style: GoogleFonts.barlowCondensed(
              fontSize: 7,
              fontWeight: FontWeight.w300,
              letterSpacing: 0.22,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                from,
                style: AppTypography.receiptCondensed(
                  size: 22,
                  weight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: Text(
                  '———>',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ),
              Text(
                to,
                style: AppTypography.receiptCondensed(
                  size: 22,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow() {
    final now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: _MetaItem(
              label: 'TANGGAL',
              value:
                  '${now.day.toString().padLeft(2, '0')} ${['JAN', 'FEB', 'MAR', 'APR', 'MEI', 'JUN', 'JUL', 'AGU', 'SEP', 'OKT', 'NOV', 'DES'][now.month - 1]}',
            ),
          ),
          Expanded(
            child: _MetaItem(
              label: 'WAKTU',
              value:
                  '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
              center: true,
            ),
          ),
          Expanded(
            child: _MetaItem(
              label: 'NO. TRX',
              value: '#${transaction.orderNumber.substring(3, 8)}',
              right: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoto() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      height: 127,
      color: Colors.grey.shade300,
      child: photoPath.isNotEmpty && File(photoPath).existsSync()
          ? Image.file(
              File(photoPath),
              fit: BoxFit.cover,
              width: double.infinity,
            )
          : Container(
              color: Colors.grey.shade300,
              child: const Icon(Icons.image, color: Colors.grey),
            ),
    );
  }

  Widget _buildSeatInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KURSI',
                style: GoogleFonts.barlowCondensed(
                  fontSize: 6,
                  color: Colors.grey,
                  letterSpacing: 0.15,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Text(
                  seatNumber,
                  style: AppTypography.receiptCondensed(
                    size: 20,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Gerbong 2', style: _seatMetaStyle()),
              Text('Kelas Eksekutif', style: _seatMetaStyle()),
              Text('Kasir: Rina', style: _seatMetaStyle()),
            ],
          ),
        ],
      ),
    );
  }

  TextStyle _seatMetaStyle() {
    return GoogleFonts.barlowCondensed(
      fontSize: 6.5,
      color: Colors.grey.shade600,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.08,
    );
  }

  Widget _buildOrders() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DETAIL PESANAN',
            style: GoogleFonts.barlowCondensed(
              fontSize: 6,
              color: Colors.grey,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 5),
          ...transaction.items.map(
            (item) => _OrderRow(
              name: '${item.name} × ${item.quantity}',
              price: 'Rp ${_formatPrice(item.total)}',
            ),
          ),
          const SizedBox(height: 3),
          _OrderRow(
            name: 'PPN 11%',
            price: 'Rp ${_formatPrice(transaction.taxAmount)}',
            muted: true,
          ),
          _OrderRow(
            name: 'Diskon 10%',
            price: '- Rp ${_formatPrice(transaction.discountAmount)}',
            muted: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTotal() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black, width: 1),
          bottom: BorderSide(color: Colors.black, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total',
            style: AppTypography.receiptCondensed(
              size: 11,
              weight: FontWeight.w600,
            ),
          ),
          Text(
            'Rp ${_formatPrice(transaction.total)}',
            style: AppTypography.receiptCondensed(
              size: 11,
              weight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarcode() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      child: Column(
        children: [
          // Fake barcode lines
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(25, (i) {
              final widths = [
                2,
                1,
                3,
                1,
                2,
                3,
                1,
                2,
                1,
                3,
                2,
                1,
                3,
                1,
                2,
                1,
                3,
                2,
                1,
                3,
                1,
                2,
                1,
                3,
                2,
              ];
              final heights = [
                20,
                14,
                17,
                14,
                20,
                17,
                14,
                20,
                14,
                17,
                20,
                14,
                17,
                14,
                20,
                14,
                17,
                20,
                14,
                17,
                14,
                20,
                14,
                17,
                20,
              ];
              return Container(
                width: widths[i].toDouble(),
                height: heights[i].toDouble(),
                margin: const EdgeInsets.symmetric(horizontal: 0.5),
                color: i % 2 == 0 ? Colors.black : Colors.white,
              );
            }),
          ),
          const SizedBox(height: 3),
          Text(
            'OM ${DateTime.now().year} ${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')} ${transaction.orderNumber.substring(3, 8)}',
            style: AppTypography.receiptMono(
              size: 5.5,
              weight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 7, 14, 13),
      child: Column(
        children: [
          Text(
            'Terima kasih telah berkunjung',
            style: GoogleFonts.barlowCondensed(
              fontSize: 8,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.06,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'ourmemories.id · @ourmemories',
            style: GoogleFonts.barlowCondensed(
              fontSize: 6,
              color: Colors.grey,
              letterSpacing: 0.08,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}

/// T2: F&B 1x2
class T2CafeReceipt extends StatelessWidget {
  final List<String> photoPaths;
  final TransactionModel transaction;

  const T2CafeReceipt({
    super.key,
    required this.photoPaths,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return ReceiptContainer(
      children: [
        // Header
        _buildHeader(),

        // Photos
        _buildPhotos(),

        // Transaction line
        _buildTxLine(),

        // Menu items
        _buildMenu(),

        // Calculations
        _buildCalculations(),

        // Total
        _buildTotal(),

        // Footer
        _buildFooter(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Text(
            '· · ·',
            style: GoogleFonts.dmMono(
              fontSize: 7,
              letterSpacing: 0.5,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Our Memories',
            style: AppTypography.receiptSerif(
              size: 17,
              weight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'PHOTOBOOTH & CAFE',
            style: AppTypography.receiptMono(
              size: 6.5,
              weight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotos() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: photoPaths.take(2).map((path) {
          return Container(
            height: 95,
            margin: const EdgeInsets.only(bottom: 2),
            color: Colors.grey.shade300,
            child: path.isNotEmpty && File(path).existsSync()
                ? Image.file(
                    File(path),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  )
                : Container(color: Colors.grey.shade300),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTxLine() {
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '#${transaction.orderNumber}',
            style: AppTypography.receiptMono(
              size: 6.5,
              weight: FontWeight.w300,
            ),
          ),
          Text(
            '${now.day} ${['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'][now.month - 1]} ${now.year} · ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
            style: AppTypography.receiptMono(
              size: 6.5,
              weight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Text(
            '— Menu Pilihan —',
            style: AppTypography.receiptSerif(
              size: 7.5,
              weight: FontWeight.w400,
            ),
          ),
        ),
        ...transaction.items.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.name,
                  style: AppTypography.receiptSerif(
                    size: 8,
                    weight: FontWeight.w400,
                  ),
                ),
                Text(
                  'Rp ${_formatPrice(item.total)}',
                  style: AppTypography.receiptMono(
                    size: 7,
                    weight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalculations() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      child: Column(
        children: [
          _calcRow('Subtotal', transaction.subtotal),
          _calcRow('PPN 11%', transaction.taxAmount, muted: true),
          _calcRow('Diskon Member', -transaction.discountAmount, muted: true),
        ],
      ),
    );
  }

  Widget _calcRow(String label, int value, {bool muted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.receiptMono(
            size: 7,
            weight: muted ? FontWeight.w300 : FontWeight.w400,
            color: muted ? Colors.grey : Colors.black,
          ),
        ),
        Text(
          value < 0
              ? '- Rp ${_formatPrice(-value)}'
              : 'Rp ${_formatPrice(value)}',
          style: AppTypography.receiptMono(
            size: 7,
            weight: muted ? FontWeight.w300 : FontWeight.w400,
            color: muted ? Colors.grey : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildTotal() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black, width: 1),
          bottom: BorderSide(color: Colors.black, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total',
            style: AppTypography.receiptSerif(
              size: 11,
              weight: FontWeight.w700,
            ),
          ),
          Text(
            'Rp ${_formatPrice(transaction.total)}',
            style: AppTypography.receiptMono(size: 9, weight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 13),
      child: Column(
        children: [
          Text(
            'Terima kasih, selamat menikmati',
            style: AppTypography.receiptSerif(
              size: 10,
              weight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '· · ·',
            style: GoogleFonts.dmMono(
              fontSize: 7,
              letterSpacing: 0.4,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'ourmemories.id · Kasir: Budi',
            style: AppTypography.receiptMono(
              size: 6,
              weight: FontWeight.w300,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}

/// T3: Perbankan 1x3
class T3BankReceipt extends StatelessWidget {
  final List<String> photoPaths;
  final TransactionModel transaction;
  final String accountNumber;
  final String customerName;

  const T3BankReceipt({
    super.key,
    required this.photoPaths,
    required this.transaction,
    this.accountNumber = '1234 ···· ···· 5678',
    this.customerName = 'RIZKY R.',
  });

  @override
  Widget build(BuildContext context) {
    return ReceiptContainer(
      children: [
        // Header dengan chip
        _buildHeader(),

        // Photos
        _buildPhotos(),

        // Account info
        _buildAccountInfo(),

        // Transaction details
        _buildTransactionDetails(),

        // Status
        _buildStatus(),

        // Total
        _buildTotal(),

        // Footer
        _buildFooter(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'OURBANK',
                style: AppTypography.receiptMono(
                  size: 12,
                  weight: FontWeight.w500,
                  letterSpacing: 0.14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'OUR MEMORIES FINANCIAL',
                style: AppTypography.receiptMono(
                  size: 6,
                  weight: FontWeight.w300,
                  color: Colors.grey,
                  letterSpacing: 0.12,
                ),
              ),
            ],
          ),
          // Chip
          Container(
            width: 16,
            height: 12,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(2),
            ),
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(2),
              mainAxisSpacing: 1.5,
              crossAxisSpacing: 1.5,
              children: List.generate(
                4,
                (_) => Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotos() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: photoPaths.take(3).map((path) {
          return Container(
            height: 52,
            margin: const EdgeInsets.only(bottom: 2),
            color: Colors.grey.shade300,
            child: path.isNotEmpty && File(path).existsSync()
                ? Image.file(
                    File(path),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  )
                : Container(color: Colors.grey.shade300),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAccountInfo() {
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _MetaItem(
                  label: 'NASABAH',
                  value: customerName,
                  mono: true,
                ),
              ),
              Expanded(
                child: _MetaItem(
                  label: 'TANGGAL',
                  value:
                      '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}',
                  right: true,
                  mono: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            accountNumber,
            style: AppTypography.receiptMono(
              size: 10,
              weight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RINCIAN TRANSAKSI',
            style: AppTypography.receiptMono(
              size: 6,
              weight: FontWeight.w300,
              color: Colors.grey,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 5),
          ...transaction.items.map(
            (item) => _tRow(item.name, 'Rp ${_formatPrice(item.total)}'),
          ),
          const SizedBox(height: 3),
          _tRow(
            'Subtotal',
            'Rp ${_formatPrice(transaction.subtotal)}',
            dim: true,
          ),
          _tRow(
            'PPN 11%',
            'Rp ${_formatPrice(transaction.taxAmount)}',
            dim: true,
          ),
          _tRow(
            'Diskon Promo',
            '- Rp ${_formatPrice(transaction.discountAmount)}',
            dim: true,
          ),
        ],
      ),
    );
  }

  Widget _tRow(String left, String right, {bool dim = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            left,
            style: AppTypography.receiptMono(
              size: dim ? 6.5 : 7.5,
              weight: dim ? FontWeight.w300 : FontWeight.w400,
              color: dim ? Colors.grey : Colors.black,
            ),
          ),
          Text(
            right,
            style: AppTypography.receiptMono(
              size: dim ? 6.5 : 7.5,
              weight: dim ? FontWeight.w300 : FontWeight.w400,
              color: dim ? Colors.grey : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatus() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFD4EDDA),
              border: Border.all(color: const Color(0xFF7AB894)),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'TRANSAKSI BERHASIL',
            style: AppTypography.receiptMono(
              size: 6.5,
              weight: FontWeight.w500,
              color: const Color(0xFF3A6B4A),
              letterSpacing: 0.12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotal() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 7, 14, 5),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL PEMBAYARAN',
            style: AppTypography.receiptMono(
              size: 6,
              weight: FontWeight.w300,
              color: Colors.grey,
              letterSpacing: 0.18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Rp ${_formatPrice(transaction.total)}',
            style: AppTypography.receiptMono(
              size: 14,
              weight: FontWeight.w500,
              letterSpacing: 0.04,
            ),
          ),
          Text(
            'REF: ${transaction.orderNumber}',
            style: AppTypography.receiptMono(
              size: 5.5,
              weight: FontWeight.w300,
              color: Colors.grey,
              letterSpacing: 0.08,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 7, 14, 13),
      child: Column(
        children: [
          Text(
            'TERIMA KASIH',
            style: AppTypography.receiptMono(
              size: 7.5,
              weight: FontWeight.w500,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Simpan sebagai bukti pembayaran · ourmemories.id',
            style: AppTypography.receiptMono(
              size: 6,
              weight: FontWeight.w300,
              color: Colors.grey,
              letterSpacing: 0.06,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}

/// T4: Konser 2x2
class T4ConcertReceipt extends StatelessWidget {
  final List<String> photoPaths;
  final TransactionModel transaction;
  final String eventName;

  const T4ConcertReceipt({
    super.key,
    required this.photoPaths,
    required this.transaction,
    this.eventName = 'Live Event · Photobooth',
  });

  @override
  Widget build(BuildContext context) {
    return ReceiptContainer(
      children: [
        // Header
        _buildHeader(),

        // Notch row
        _buildNotchRow(),

        // Photo grid 2x2
        _buildPhotoGrid(),

        // Notch row
        _buildNotchRow(),

        // Event info
        _buildEventInfo(),

        // Orders
        _buildOrders(),

        // Total
        _buildTotal(),

        // QR Code
        _buildQRCode(),

        // Footer
        _buildFooter(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Column(
        children: [
          Text(
            eventName.toUpperCase(),
            style: AppTypography.receiptMono(
              size: 6.5,
              weight: FontWeight.w300,
              color: Colors.grey,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Our Memories',
            style: GoogleFonts.dmMono(
              fontSize: 19,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.04,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '"Freeze the moment, feel the vibe"',
            style: AppTypography.receiptSerif(
              size: 7,
              weight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotchRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: CustomPaint(
              size: const Size(double.infinity, 1),
              painter: _DashLinePainter(),
            ),
          ),
          Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    final photos = photoPaths.take(4).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: 1,
        children: List.generate(4, (index) {
          return Container(
            color: Colors.grey.shade300,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (index < photos.length && photos[index].isNotEmpty)
                  Image.file(File(photos[index]), fit: BoxFit.cover),
                Positioned(
                  bottom: 3,
                  right: 4,
                  child: Text(
                    '0${index + 1}',
                    style: GoogleFonts.dmMono(
                      fontSize: 6.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEventInfo() {
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _eiItem(
                    'TANGGAL',
                    '${now.day} ${['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'][now.month - 1]} ${now.year}',
                  ),
                  const SizedBox(height: 4),
                  _eiItem(
                    'WAKTU',
                    '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB',
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _eiItem('NO. TIKET', '#${transaction.orderNumber}'),
                  const SizedBox(height: 4),
                  _eiItem('KASIR', 'Sari'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _eiItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.receiptMono(
            size: 6,
            weight: FontWeight.w300,
            color: Colors.grey,
            letterSpacing: 0.15,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.dmMono(fontSize: 9, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildOrders() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      child: Column(
        children: [
          Text(
            'DAFTAR PESANAN',
            style: AppTypography.receiptMono(
              size: 6,
              weight: FontWeight.w300,
              color: Colors.grey,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 5),
          ...transaction.items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 1.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.dmMono(
                      fontSize: 7.5,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    'Rp ${_formatPrice(item.total)}',
                    style: GoogleFonts.dmMono(
                      fontSize: 7.5,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotal() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black, width: 1),
          bottom: BorderSide(color: Colors.black, width: 1),
        ),
      ),
      child: Column(
        children: [
          _totalMini('Subtotal', transaction.subtotal),
          _totalMini('PPN 11%', transaction.taxAmount),
          _totalMini('Diskon', -transaction.discountAmount),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.dmMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Rp ${_formatPrice(transaction.total)}',
                style: GoogleFonts.dmMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _totalMini(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.dmMono(
            fontSize: 6.5,
            fontWeight: FontWeight.w300,
            color: Colors.grey,
          ),
        ),
        Text(
          value < 0
              ? '- Rp ${_formatPrice(-value)}'
              : 'Rp ${_formatPrice(value)}',
          style: GoogleFonts.dmMono(
            fontSize: 6.5,
            fontWeight: FontWeight.w300,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildQRCode() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      child: Column(
        children: [
          // Fake QR grid
          Wrap(
            spacing: 1,
            runSpacing: 1,
            children: List.generate(49, (i) {
              final pattern = [
                1,
                1,
                1,
                0,
                1,
                1,
                1,
                1,
                0,
                1,
                1,
                1,
                0,
                1,
                1,
                1,
                1,
                0,
                1,
                0,
                0,
                1,
                0,
                0,
                1,
                0,
                1,
                0,
                0,
                0,
                0,
                0,
                1,
                1,
                1,
                0,
                1,
                1,
                1,
                0,
                0,
                0,
                1,
                0,
                1,
                0,
                1,
                1,
                1,
              ];
              return Container(
                width: 6,
                height: 6,
                color: pattern[i] == 1 ? Colors.black : Colors.white,
                decoration: pattern[i] == 0
                    ? BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 0.5,
                        ),
                      )
                    : null,
              );
            }),
          ),
          const SizedBox(height: 3),
          Text(
            transaction.orderNumber,
            style: AppTypography.receiptMono(
              size: 5.5,
              weight: FontWeight.w300,
              color: Colors.grey,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 13),
      child: Column(
        children: [
          Text(
            'Terima kasih, selamat berpose!',
            style: AppTypography.receiptSerif(
              size: 8.5,
              weight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'ourmemories.id · @ourmemories.id',
            style: GoogleFonts.dmMono(
              fontSize: 6,
              color: Colors.grey,
              letterSpacing: 0.08,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}

class _DashLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 4;
    const dashSpace = 4;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MetaItem extends StatelessWidget {
  final String label;
  final String value;
  final bool center;
  final bool right;
  final bool mono;

  const _MetaItem({
    required this.label,
    required this.value,
    this.center = false,
    this.right = false,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = mono
        ? AppTypography.receiptMono(
            size: 6,
            weight: FontWeight.w300,
            color: Colors.grey,
            letterSpacing: 0.12,
          )
        : GoogleFonts.barlowCondensed(
            fontSize: 6,
            color: Colors.grey,
            letterSpacing: 0.15,
          );

    final valueStyle = mono
        ? AppTypography.receiptMono(
            size: 8,
            weight: FontWeight.w500,
            letterSpacing: 0.04,
          )
        : AppTypography.receiptCondensed(
            size: 9,
            weight: FontWeight.w600,
            letterSpacing: 0.04,
          );

    Widget content = Column(
      crossAxisAlignment: right
          ? CrossAxisAlignment.end
          : (center ? CrossAxisAlignment.center : CrossAxisAlignment.start),
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 1),
        Text(value, style: valueStyle),
      ],
    );

    if (center) {
      return Center(child: content);
    }
    return content;
  }
}

class _OrderRow extends StatelessWidget {
  final String name;
  final String price;
  final bool muted;

  const _OrderRow({
    required this.name,
    required this.price,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: GoogleFonts.barlowCondensed(
              fontSize: muted ? 7 : 8,
              fontWeight: FontWeight.w400,
              color: muted ? Colors.grey : Colors.black,
            ),
          ),
          Text(
            price,
            style: GoogleFonts.barlowCondensed(
              fontSize: muted ? 7 : 8,
              fontWeight: FontWeight.w400,
              color: muted ? Colors.grey : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
