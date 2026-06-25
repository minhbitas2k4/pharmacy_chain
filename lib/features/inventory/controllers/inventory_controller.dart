import 'package:flutter/foundation.dart';

import '../models/inventory_request_model.dart';
import '../models/stock_verification_model.dart';
import '../models/warehouse_alert_model.dart';
import '../services/inventory_service.dart';

class InventoryController extends ChangeNotifier {
  InventoryController({InventoryService? inventoryService})
    : _inventoryService = inventoryService ?? InventoryService();

  final InventoryService _inventoryService;

  bool _isLoading = false;
  List<WarehouseAlertModel> _alerts = <WarehouseAlertModel>[];
  List<InventoryRequestModel> _requests = <InventoryRequestModel>[];
  List<StockVerificationModel> _stockItems = <StockVerificationModel>[];
  int _selectedReviewTab = 0;
  int _completedScanCount = 7;

  bool get isLoading => _isLoading;
  List<WarehouseAlertModel> get alerts =>
      List<WarehouseAlertModel>.unmodifiable(_alerts);
  List<InventoryRequestModel> get requests =>
      List<InventoryRequestModel>.unmodifiable(_requests);
  List<StockVerificationModel> get stockItems =>
      List<StockVerificationModel>.unmodifiable(_stockItems);
  int get selectedReviewTab => _selectedReviewTab;
  int get completedScanCount => _completedScanCount;
  int get totalScanCount => 12;

  Future<void> loadWarehouseAlerts() async {
    _setLoading(true);
    try {
      _alerts = await _inventoryService.fetchWarehouseAlerts();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> loadReviewRequests() async {
    _setLoading(true);
    try {
      _requests = await _inventoryService.fetchReviewRequests();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> loadStockVerification() async {
    _setLoading(true);
    try {
      _stockItems = await _inventoryService.fetchStockVerification();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void selectReviewTab(int index) {
    _selectedReviewTab = index;
    notifyListeners();
  }

  void approveRequest(InventoryRequestModel request) {
    _requests = _requests.map((InventoryRequestModel item) {
      if (item.code == request.code) {
        return item.copyWith(status: InventoryRequestStatus.approved);
      }
      return item;
    }).toList();
    notifyListeners();
  }

  void rejectRequest(InventoryRequestModel request) {
    _requests = _requests.map((InventoryRequestModel item) {
      if (item.code == request.code) {
        return item.copyWith(status: InventoryRequestStatus.rejected);
      }
      return item;
    }).toList();
    notifyListeners();
  }

  void scanNextItem() {
    // if (_completedScanCount < _totalScanCount) {
    //   _completedScanCount++;
    //   notifyListeners();
    // }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }
}
