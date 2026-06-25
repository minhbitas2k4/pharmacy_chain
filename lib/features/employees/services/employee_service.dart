import '../models/employee_model.dart';

class EmployeeService {
  Future<List<EmployeeModel>> fetchEmployees() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return const <EmployeeModel>[
      EmployeeModel(
        name: 'Nguyễn Thị Lan',
        title: 'Dược sĩ đại học',
        cccd: '079 201 123456',
        phone: '0901-234-567',
        license: 'DS-HCM-2198',
        status: 'Đang làm việc',
      ),
    ];
  }
}
