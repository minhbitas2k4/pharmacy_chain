import '../../pos/models/cart_item_model.dart';

class InvoiceModel {
  const InvoiceModel({
    required this.code,
    required this.branch,
    required this.cashier,
    required this.time,
    required this.items,
    required this.total,
    required this.discount,
    required this.paymentMethod,
  });

  final String code;
  final String branch;
  final String cashier;
  final String time;
  final List<CartItemModel> items;
  final double total;
  final double discount;
  final String paymentMethod;
}
