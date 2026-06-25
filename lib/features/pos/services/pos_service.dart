import '../models/cart_item_model.dart';

class PosService {
  List<String> fetchSuggestions() {
    return <String>[
      'Amoxicillin 500mg - 85.000đ',
      'Paracetamol 500mg - 25.000đ',
      'Vitamin C 1000mg - 60.000đ',
    ];
  }

  List<CartItemModel> initialCart() {
    return <CartItemModel>[];
  }
}
