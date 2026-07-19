import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/payment_model.dart';
import '../services/payment_service.dart';

class PaymentController extends ChangeNotifier {
  PaymentController({PaymentService? paymentService})
    : _paymentService = paymentService ?? PaymentService();

  final PaymentService _paymentService;
  PaymentMethod _method = PaymentMethod.cash;
  bool _isLoading = false;
  final TextEditingController cashReceivedController = TextEditingController();

  PaymentMethod get method => _method;
  bool get isLoading => _isLoading;

  void selectMethod(PaymentMethod method) {
    _method = method;
    notifyListeners();
  }

  double changeFor(double total) {
    final double received = double.tryParse(cashReceivedController.text) ?? 0;
    return received - total;
  }

  Future<void> confirm() async {
    _isLoading = true;
    notifyListeners();
    await _paymentService.pay();
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    cashReceivedController.dispose();
    super.dispose();
  }
}
