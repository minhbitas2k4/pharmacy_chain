import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../auth/controllers/auth_controller.dart';
import '../models/inventory_request_model.dart';
import '../models/stock_verification_model.dart';
import '../models/warehouse_alert_model.dart';
import '../services/inventory_service.dart';

class InventoryController extends ChangeNotifier {
  InventoryController({String? branchId, InventoryService? inventoryService})
    : branchId = branchId ?? AuthController().currentUser?.branchId ?? '',
      _inventoryService = inventoryService ?? InventoryService();

  final String branchId;
  final InventoryService _inventoryService;

  bool _isLoading = false;
  List<WarehouseAlertModel> _alerts = <WarehouseAlertModel>[];
  List<InventoryRequestModel> _requests = <InventoryRequestModel>[];
  List<StockVerificationModel> _stockItems = <StockVerificationModel>[];
  int _selectedReviewTab = 0;
  final int _completedScanCount = 7;
  String? _errorMessage;

  StreamSubscription<List<WarehouseAlertModel>>? _alertsSubscription;
  StreamSubscription<List<InventoryRequestModel>>? _requestsSubscription;
  StreamSubscription<List<StockVerificationModel>>? _stockSubscription;

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
  String? get errorMessage => _errorMessage;

  void loadWarehouseAlerts() {
    _setLoading(true);
    _alertsSubscription?.cancel();
    _alertsSubscription = _inventoryService.getWarehouseAlerts(branchId).listen(
      (alerts) {
        _alerts = alerts;
        _errorMessage = null;
        _setLoading(false);
      },
      onError: (error) {
        _errorMessage = 'Không thể tải cảnh báo kho';
        _setLoading(false);
      },
    );
  }

  void loadReviewRequests() {
    _setLoading(true);
    _requestsSubscription?.cancel();
    _requestsSubscription = _inventoryService.getReviewRequests(branchId).listen(
      (requests) {
        _requests = requests;
        _errorMessage = null;
        _setLoading(false);
      },
      onError: (error) {
        _errorMessage = 'Không thể tải yêu cầu duyệt';
        _setLoading(false);
      },
    );
  }

  void loadStockVerification() {
    _setLoading(true);
    _stockSubscription?.cancel();
    _stockSubscription = _inventoryService.getStockVerification(branchId).listen(
      (items) {
        _stockItems = items;
        _errorMessage = null;
        _setLoading(false);
      },
      onError: (error) {
        _errorMessage = 'Không thể tải dữ liệu kiểm kho';
        _setLoading(false);
      },
    );
  }

  void selectReviewTab(int index) {
    _selectedReviewTab = index;
    notifyListeners();
  }

  Future<void> approveRequest(InventoryRequestModel request) async {
    try {
      await _inventoryService.approveRequest(request.id);
      _requests = _requests.map((InventoryRequestModel item) {
        if (item.code == request.code) {
          return item.copyWith(status: InventoryRequestStatus.approved);
        }
        return item;
      }).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi khi duyệt yêu cầu';
      notifyListeners();
    }
  }

  Future<void> rejectRequest(InventoryRequestModel request) async {
    try {
      await _inventoryService.rejectRequest(request.id);
      _requests = _requests.map((InventoryRequestModel item) {
        if (item.code == request.code) {
          return item.copyWith(status: InventoryRequestStatus.rejected);
        }
        return item;
      }).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi khi từ chối yêu cầu';
      notifyListeners();
    }
  }

  void scanNextItem() {
    // Stub for future barcode integration
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _alertsSubscription?.cancel();
    _requestsSubscription?.cancel();
    _stockSubscription?.cancel();
    super.dispose();
  }
}
