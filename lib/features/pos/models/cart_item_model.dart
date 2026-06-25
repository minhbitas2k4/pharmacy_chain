class CartItemModel {
  const CartItemModel({
    required this.name,
    required this.price,
    required this.quantity,
  });

  final String name;
  final double price;
  final int quantity;

  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(
      name: name,
      price: price,
      quantity: quantity ?? this.quantity,
    );
  }

  double get lineTotal => price * quantity;
}
