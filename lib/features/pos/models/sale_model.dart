import 'cart_item_model.dart';

class SaleModel {
  const SaleModel({required this.items, required this.total});

  final List<CartItemModel> items;
  final double total;
}
