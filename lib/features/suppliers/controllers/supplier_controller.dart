import 'package:flutter/foundation.dart';

import '../models/supplier_model.dart';
import '../services/supplier_service.dart';

class SupplierController extends ChangeNotifier {
  SupplierController({SupplierService? supplierService})
    : _supplierService = supplierService ?? SupplierService();

  final SupplierService _supplierService;

  bool _isLoading = false;
  List<SupplierModel> _suppliers = <SupplierModel>[];
  String _query = '';

  bool get isLoading => _isLoading;
  List<SupplierModel> get suppliers {
    if (_query.isEmpty) {
      return List<SupplierModel>.unmodifiable(_suppliers);
    }
    return List<SupplierModel>.unmodifiable(
      _suppliers.where(
        (SupplierModel supplier) =>
            supplier.name.toLowerCase().contains(_query.toLowerCase()),
      ),
    );
  }

  Future<void> loadSuppliers() async {
    _setLoading(true);
    try {
      _suppliers = await _supplierService.fetchSuppliers();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void updateQuery(String value) {
    _query = value.trim();
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }
}
