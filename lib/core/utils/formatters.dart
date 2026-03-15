import 'package:intl/intl.dart';
import '../../domain/entities/order_entity.dart';

class AppFormatters {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_ET', symbol: 'ETB ', decimalDigits: 2,
  );
  static final _compactFormat = NumberFormat.compact(locale: 'en_ET');
  static final _dateFormat = DateFormat('MMM dd, yyyy');
  static final _dateTimeFormat = DateFormat('MMM dd, yyyy • hh:mm a');

  static String formatCurrency(double amount) => _currencyFormat.format(amount);
  static String formatCompactCurrency(double amount) => 'ETB ${_compactFormat.format(amount)}';
  static String formatDate(DateTime date) => _dateFormat.format(date);
  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);
  static String formatRating(double rating) => rating.toStringAsFixed(1);
  static String formatReviewCount(int count) {
    if (count == 0) return 'No reviews';
    if (count == 1) return '(1 review)';
    return '($count reviews)';
  }

  static String formatOrderStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return 'Pending';
      case OrderStatus.confirmed: return 'Confirmed';
      case OrderStatus.processing: return 'Processing';
      case OrderStatus.shipped: return 'Shipped';
      case OrderStatus.outForDelivery: return 'Out for Delivery';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
      case OrderStatus.refunded: return 'Refunded';
      default: return status.name;
    }
  }

  static String formatPaymentStatus(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending: return 'Pending';
      case PaymentStatus.paid: return 'Paid';
      case PaymentStatus.inEscrow: return 'In Escrow';
      case PaymentStatus.released: return 'Released';
      case PaymentStatus.failed: return 'Failed';
      case PaymentStatus.refunded: return 'Refunded';
    }
  }

  static String formatPhoneNumber(String phone) {
    final clean = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (clean.startsWith('251') && clean.length == 12) {
      return '+${clean.substring(0, 3)} ${clean.substring(3, 5)} ${clean.substring(5, 8)} ${clean.substring(8)}';
    }
    return phone;
  }
}