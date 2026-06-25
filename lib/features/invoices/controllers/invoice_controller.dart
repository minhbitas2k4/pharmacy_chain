import 'package:flutter/foundation.dart';

import '../models/invoice_model.dart';
import '../services/invoice_service.dart';

class InvoiceController extends ChangeNotifier {
  InvoiceController({InvoiceService? invoiceService})
    : _invoiceService = invoiceService ?? InvoiceService();

  final InvoiceService _invoiceService;
  bool _isLoading = false;
  InvoiceModel? _invoice;

  bool get isLoading => _isLoading;
  InvoiceModel? get invoice => _invoice;

  Future<void> loadInvoice() async {
    _isLoading = true;
    notifyListeners();
    try {
      _invoice = await _invoiceService.fetchInvoice();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
