// lib/domain/models/transaction_model.dart
import '../../core/constants/app_constants.dart';

class TransactionItem {
  final String name;
  final int quantity;
  final int price;

  TransactionItem({required this.name, this.quantity = 1, required this.price});

  int get total => quantity * price;
}

class TransactionModel {
  final String orderNumber;
  final DateTime timestamp;
  final List<TransactionItem> items;
  final double taxPercent;
  final double discountPercent;
  final String cashierName;
  final String? tableNumber;

  TransactionModel({
    required this.orderNumber,
    required this.timestamp,
    required this.items,
    this.taxPercent = 11,
    this.discountPercent = 0,
    this.cashierName = 'Budi',
    this.tableNumber,
  });

  int get subtotal => items.fold(0, (sum, item) => sum + item.total);

  int get taxAmount => (subtotal * taxPercent / 100).round();

  int get discountAmount => (subtotal * discountPercent / 100).round();

  int get total => subtotal + taxAmount - discountAmount;

  String get formattedTotal =>
      '${AppConstants.currency} ${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

  static String generateOrderNumber() {
    final now = DateTime.now();
    return 'OM-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';
  }
}
