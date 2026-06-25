import 'package:flutter/foundation.dart';

import '../models/purchase_order_summary_model.dart';
import '../services/purchase_order_service.dart';

class PurchaseOrderController extends ChangeNotifier {
  PurchaseOrderController({PurchaseOrderService? purchaseOrderService})
    : _purchaseOrderService = purchaseOrderService ?? PurchaseOrderService();

  final PurchaseOrderService _purchaseOrderService;

  bool _isLoading = false;
  String? _errorMessage;
  PurchaseOrderSummaryModel? _summary;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  PurchaseOrderSummaryModel? get summary => _summary;

  Future<void> loadSummary() async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      _summary = await _purchaseOrderService.fetchSummary();
      if (_summary?.isEmpty ?? false) {
        _errorMessage = null;
      }
    } catch (_) {
      _summary = PurchaseOrderSummaryModel.empty();
      _errorMessage = 'Không thể tải dữ liệu nhập hàng.';
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> loadEmptyMock() async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      _summary = await _purchaseOrderService.fetchEmptySummary();
    } catch (_) {
      _summary = PurchaseOrderSummaryModel.empty();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> loadErrorMock() async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      _summary = await _purchaseOrderService.fetchErrorSummary();
    } catch (_) {
      _summary = PurchaseOrderSummaryModel.empty();
      _errorMessage = 'Không thể tải dữ liệu nhập hàng.';
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
  }
}
