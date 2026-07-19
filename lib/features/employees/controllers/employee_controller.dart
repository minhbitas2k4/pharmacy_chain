import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/employee_model.dart';
import '../services/employee_service.dart';

class EmployeeController extends ChangeNotifier {
  EmployeeController({String? branchId, EmployeeService? employeeService})
    : _branchId = branchId,
      _employeeService = employeeService ?? EmployeeService();

  final String? _branchId;
  final EmployeeService _employeeService;
  bool _isLoading = false;
  List<EmployeeModel> _employees = <EmployeeModel>[];
  String _query = '';
  String? _selectedRoleFilter;
  String? _errorMessage;

  StreamSubscription<List<EmployeeModel>>? _subscription;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedRoleFilter => _selectedRoleFilter;

  List<EmployeeModel> get employees {
    return List<EmployeeModel>.unmodifiable(
      _employees.where((EmployeeModel employee) {
        // Text search filter
        final String target =
            '${employee.displayName} ${employee.email} ${employee.phone ?? ''}'
                .toLowerCase();
        final bool matchesQuery = target.contains(_query.toLowerCase());

        // Role filter
        final bool matchesRole = _selectedRoleFilter == null ||
            _selectedRoleFilter!.isEmpty ||
            employee.role == _selectedRoleFilter;

        return matchesQuery && matchesRole;
      }),
    );
  }

  List<EmployeeModel> get allEmployees =>
      List<EmployeeModel>.unmodifiable(_employees);

  int get totalCount => _employees.length;
  int get activeCount =>
      _employees.where((e) => e.isActive).length;

  void loadEmployees() {
    _setLoading(true);
    _subscription?.cancel();
    _subscription = _employeeService.getEmployees(branchId: _branchId).listen(
      (employees) {
        _employees = employees;
        _errorMessage = null;
        _setLoading(false);
      },
      onError: (error) {
        _errorMessage = 'Không thể tải danh sách nhân viên';
        _setLoading(false);
      },
    );
  }

  void updateQuery(String value) {
    _query = value.trim();
    notifyListeners();
  }

  void setRoleFilter(String? role) {
    _selectedRoleFilter = role;
    notifyListeners();
  }

  Future<void> addEmployee({
    required String uid,
    required String email,
    required String displayName,
    required String role,
    String? phone,
    String? branchId,
  }) async {
    try {
      await _employeeService.addEmployee(
        uid: uid,
        email: email,
        displayName: displayName,
        role: role,
        phone: phone,
        branchId: branchId,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Lỗi khi thêm nhân viên';
      notifyListeners();
    }
  }

  Future<void> updateEmployee(String uid, Map<String, dynamic> data) async {
    try {
      await _employeeService.updateEmployee(uid, data);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Lỗi khi cập nhật nhân viên';
      notifyListeners();
    }
  }

  Future<void> toggleStatus(String uid, String currentStatus) async {
    try {
      await _employeeService.toggleEmployeeStatus(uid, currentStatus);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Lỗi khi thay đổi trạng thái';
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
