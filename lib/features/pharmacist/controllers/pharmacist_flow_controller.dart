import 'package:flutter/foundation.dart';

import '../../auth/controllers/auth_controller.dart';
import '../models/pharmacist_models.dart';
import '../services/pharmacist_firestore_service.dart';

class PharmacistFlowController extends ChangeNotifier {
  PharmacistFlowController({PharmacistFirestoreService? service})
    : _service = service ?? PharmacistFirestoreService();

  final PharmacistFirestoreService _service;

  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String? _branchId;
  String? _prescriptionId;
  String? _orderId;
  List<PharmacistDrug> _drugs = <PharmacistDrug>[];
  final List<PharmacistCartItem> _cart = <PharmacistCartItem>[];
  final List<PrescriptionLine> _prescriptionLines = <PrescriptionLine>[];
  PharmacistInvoice? _invoice;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get branchId => _branchId;
  String? get prescriptionId => _prescriptionId;
  String? get orderId => _orderId;
  PharmacistInvoice? get invoice => _invoice;
  List<PharmacistDrug> get drugs => List<PharmacistDrug>.unmodifiable(_drugs);
  List<PharmacistCartItem> get cart =>
      List<PharmacistCartItem>.unmodifiable(_cart);
  List<PrescriptionLine> get prescriptionLines =>
      List<PrescriptionLine>.unmodifiable(_prescriptionLines);

  List<PharmacistDrug> get visibleDrugs {
    final String query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return drugs;
    return _drugs.where((PharmacistDrug drug) {
      return drug.name.toLowerCase().contains(query) ||
          drug.activeIngredient.toLowerCase().contains(query) ||
          drug.batchNumber.toLowerCase().contains(query);
    }).toList();
  }

  double get subtotal => _cart.fold<double>(
    0,
    (double total, PharmacistCartItem item) => total + item.lineTotal,
  );

  double get discountAmount => 0;
  double get totalAmount => subtotal - discountAmount;

  Future<void> initialize() async {
    final user = AuthController().currentUser;
    final String? currentBranchId = user?.branchId;
    if (user == null || currentBranchId == null || currentBranchId.isEmpty) {
      _errorMessage = 'Tài khoản Pharmacist chưa được gán chi nhánh.';
      notifyListeners();
      return;
    }

    _branchId = currentBranchId;
    await reloadDrugs();
  }

  Future<void> reloadDrugs() async {
    final String? currentBranchId = _branchId;
    if (currentBranchId == null) return;

    await _runLoadingAction(() async {
      _drugs = await _service.fetchAvailableDrugs(branchId: currentBranchId);
    });
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void addDrugToCart(PharmacistDrug drug) {
    if (!drug.canSell) {
      _errorMessage = drug.isExpired
          ? '${drug.name} đã hết hạn.'
          : '${drug.name} đã hết hàng.';
      notifyListeners();
      return;
    }

    final int index = _cart.indexWhere(
      (PharmacistCartItem item) => item.inventoryId == drug.inventoryId,
    );
    if (index < 0) {
      _cart.add(
        PharmacistCartItem(
          productId: drug.productId,
          inventoryId: drug.inventoryId,
          productName: drug.name,
          activeIngredient: drug.activeIngredient,
          batchNumber: drug.batchNumber,
          unitPrice: drug.price,
          quantity: 1,
          availableQuantity: drug.quantity,
        ),
      );
    } else {
      increaseQuantity(drug.inventoryId);
      return;
    }
    notifyListeners();
  }

  void increaseQuantity(String inventoryId) {
    final int index = _cart.indexWhere(
      (PharmacistCartItem item) => item.inventoryId == inventoryId,
    );
    if (index < 0) return;

    final PharmacistCartItem item = _cart[index];
    if (item.quantity >= item.availableQuantity) {
      _errorMessage = 'Số lượng không thể vượt quá tồn kho.';
      notifyListeners();
      return;
    }
    _cart[index] = item.copyWith(quantity: item.quantity + 1);
    notifyListeners();
  }

  void decreaseQuantity(String inventoryId) {
    final int index = _cart.indexWhere(
      (PharmacistCartItem item) => item.inventoryId == inventoryId,
    );
    if (index < 0) return;

    final PharmacistCartItem item = _cart[index];
    if (item.quantity <= 1) {
      _cart.removeAt(index);
    } else {
      _cart[index] = item.copyWith(quantity: item.quantity - 1);
    }
    notifyListeners();
  }

  void removeCartItem(String inventoryId) {
    _cart.removeWhere(
      (PharmacistCartItem item) => item.inventoryId == inventoryId,
    );
    notifyListeners();
  }

  void addPrescriptionDrug(PharmacistDrug drug) {
    if (!drug.canSell) {
      _errorMessage = 'Thuốc không còn khả dụng.';
      notifyListeners();
      return;
    }

    final bool exists = _prescriptionLines.any(
      (PrescriptionLine line) => line.inventoryId == drug.inventoryId,
    );
    if (!exists) {
      _prescriptionLines.add(PrescriptionLine.fromDrug(drug));
      notifyListeners();
    }
  }

  void updatePrescriptionLine(int index, PrescriptionLine line) {
    if (index < 0 || index >= _prescriptionLines.length) return;
    _prescriptionLines[index] = line;
    notifyListeners();
  }

  void removePrescriptionLine(int index) {
    if (index < 0 || index >= _prescriptionLines.length) return;
    _prescriptionLines.removeAt(index);
    notifyListeners();
  }

  Future<List<DrugInteractionWarning>> checkCartInteractions() {
    return _service.checkDrugInteractions(
      activeIngredients: _cart
          .map((PharmacistCartItem item) => item.activeIngredient)
          .toList(),
    );
  }

  Future<List<DrugInteractionWarning>> checkPrescriptionInteractions() {
    return _service.checkDrugInteractions(
      activeIngredients: _prescriptionLines
          .map((PrescriptionLine item) => item.activeIngredient)
          .toList(),
    );
  }

  Future<String?> savePrescription({
    required String patientName,
    required String patientPhone,
    required String doctorName,
  }) async {
    if (patientName.trim().isEmpty) {
      _errorMessage = 'Vui lòng nhập tên bệnh nhân.';
      notifyListeners();
      return null;
    }
    if (_prescriptionLines.isEmpty) {
      _errorMessage = 'Vui lòng thêm ít nhất một thuốc vào đơn.';
      notifyListeners();
      return null;
    }

    final user = AuthController().currentUser;
    final String? currentBranchId = _branchId;
    if (user == null || currentBranchId == null) {
      _errorMessage = 'Không tìm thấy thông tin tài khoản hoặc chi nhánh.';
      notifyListeners();
      return null;
    }

    String? result;
    await _runLoadingAction(() async {
      result = await _service.createPrescription(
        branchId: currentBranchId,
        pharmacistId: user.id,
        patientName: patientName,
        patientPhone: patientPhone,
        doctorName: doctorName,
        items: _prescriptionLines,
      );
      _prescriptionId = result;
      _cart
        ..clear()
        ..addAll(
          _prescriptionLines.map(
            (PrescriptionLine line) => line.toCartItem(),
          ),
        );
    });
    return result;
  }

  Future<String?> createOrder() async {
    if (_cart.isEmpty) {
      _errorMessage = 'Giỏ hàng đang trống.';
      notifyListeners();
      return null;
    }

    final user = AuthController().currentUser;
    final String? currentBranchId = _branchId;
    if (user == null || currentBranchId == null) {
      _errorMessage = 'Không tìm thấy thông tin tài khoản hoặc chi nhánh.';
      notifyListeners();
      return null;
    }

    String? result;
    await _runLoadingAction(() async {
      result = await _service.createDraftOrder(
        branchId: currentBranchId,
        pharmacistId: user.id,
        prescriptionId: _prescriptionId,
        items: _cart,
      );
      _orderId = result;
    });
    return result;
  }

  Future<bool> pay({
    required String paymentMethod,
    required String transactionReference,
  }) async {
    final String? currentOrderId = _orderId;
    if (currentOrderId == null) {
      _errorMessage = 'Chưa có đơn hàng để thanh toán.';
      notifyListeners();
      return false;
    }

    bool success = false;
    await _runLoadingAction(() async {
      await _service.completePayment(
        orderId: currentOrderId,
        paymentMethod: paymentMethod,
        transactionReference: transactionReference,
      );
      success = true;
    });
    return success;
  }

  Future<void> loadInvoice() async {
    final String? currentOrderId = _orderId;
    if (currentOrderId == null) {
      _errorMessage = 'Không tìm thấy đơn hàng.';
      notifyListeners();
      return;
    }

    await _runLoadingAction(() async {
      _invoice = await _service.fetchInvoice(orderId: currentOrderId);
    });
  }

  void resetTransaction() {
    _cart.clear();
    _prescriptionLines.clear();
    _prescriptionId = null;
    _orderId = null;
    _invoice = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _runLoadingAction(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
    } catch (error) {
      _errorMessage = _friendlyError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _friendlyError(Object error) {
    return error
        .toString()
        .replaceFirst('Bad state: ', '')
        .replaceFirst('Exception: ', '');
  }
}
