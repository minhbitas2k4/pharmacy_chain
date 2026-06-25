import 'package:flutter/foundation.dart';

import '../models/cart_item_model.dart';
import '../services/pos_service.dart';

class PosController extends ChangeNotifier {
  PosController({PosService? posService})
    : _posService = posService ?? PosService();

  final PosService _posService;
  final List<CartItemModel> _cart = <CartItemModel>[];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<String> get suggestions => _posService.fetchSuggestions();
  List<CartItemModel> get cart => List<CartItemModel>.unmodifiable(_cart);
  double get subtotal => _cart.fold<double>(
    0,
    (double sum, CartItemModel item) => sum + item.lineTotal,
  );

  void addSuggestion(String name, double price) {
    final int index = _cart.indexWhere(
      (CartItemModel item) => item.name == name,
    );
    if (index >= 0) {
      _cart[index] = _cart[index].copyWith(quantity: _cart[index].quantity + 1);
    } else {
      _cart.add(CartItemModel(name: name, price: price, quantity: 1));
    }
    notifyListeners();
  }

  void increase(String name) {
    final int index = _cart.indexWhere(
      (CartItemModel item) => item.name == name,
    );
    if (index >= 0) {
      _cart[index] = _cart[index].copyWith(quantity: _cart[index].quantity + 1);
      notifyListeners();
    }
  }

  void decrease(String name) {
    final int index = _cart.indexWhere(
      (CartItemModel item) => item.name == name,
    );
    if (index >= 0) {
      final int quantity = _cart[index].quantity - 1;
      if (quantity <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index] = _cart[index].copyWith(quantity: quantity);
      }
      notifyListeners();
    }
  }

  void remove(String name) {
    _cart.removeWhere((CartItemModel item) => item.name == name);
    notifyListeners();
  }

  Future<bool> checkout() async {
    if (_cart.isEmpty) {
      return false;
    }
    _isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(seconds: 1));
    _isLoading = false;
    notifyListeners();
    return true;
  }
}
