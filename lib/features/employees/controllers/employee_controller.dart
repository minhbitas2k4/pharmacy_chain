import 'package:flutter/foundation.dart';

import '../models/employee_model.dart';
import '../services/employee_service.dart';

class EmployeeController extends ChangeNotifier {
  EmployeeController({EmployeeService? employeeService})
    : _employeeService = employeeService ?? EmployeeService();

  final EmployeeService _employeeService;
  bool _isLoading = false;
  List<EmployeeModel> _employees = <EmployeeModel>[];
  String _query = '';

  bool get isLoading => _isLoading;
  List<EmployeeModel> get employees {
    return List<EmployeeModel>.unmodifiable(
      _employees.where((EmployeeModel employee) {
        final String target =
            '${employee.name} ${employee.phone} ${employee.license}'
                .toLowerCase();
        return target.contains(_query.toLowerCase());
      }),
    );
  }

  Future<void> loadEmployees() async {
    _isLoading = true;
    notifyListeners();
    try {
      _employees = await _employeeService.fetchEmployees();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateQuery(String value) {
    _query = value.trim();
    notifyListeners();
  }
}
