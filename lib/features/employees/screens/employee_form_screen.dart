import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/employee_controller.dart';
import '../models/employee_model.dart';

class EmployeeFormScreen extends StatefulWidget {
  const EmployeeFormScreen({
    super.key,
    this.employee,
    required this.controller,
  });

  /// If null → add mode, if provided → edit mode
  final EmployeeModel? employee;
  final EmployeeController controller;

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _branchIdController;
  String _selectedRole = 'pharmacist';
  bool _isSaving = false;

  bool get isEditMode => widget.employee != null;

  static const _roles = <String, String>{
    'pharmacist': 'Dược sĩ',
    'cashier': 'Thu ngân',
    'warehouse_staff': 'Nhân viên kho',
    'branch_manager': 'Quản lý chi nhánh',
    'chain_manager': 'Quản lý chuỗi',
    'system_admin': 'Quản trị hệ thống',
    'hr_admin': 'Nhân sự / Admin',
  };

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.employee?.displayName ?? '');
    _emailController =
        TextEditingController(text: widget.employee?.email ?? '');
    _phoneController =
        TextEditingController(text: widget.employee?.phone ?? '');
    _branchIdController =
        TextEditingController(text: widget.employee?.branchId ?? '');
    _selectedRole = widget.employee?.role ?? 'pharmacist';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _branchIdController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      if (isEditMode) {
        await widget.controller.updateEmployee(widget.employee!.uid, {
          'displayName': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'role': _selectedRole,
          'branchId': _branchIdController.text.trim().isEmpty
              ? null
              : _branchIdController.text.trim(),
        });
      } else {
        // Generate a simple uid for the new user doc
        final uid =
            'user_${DateTime.now().millisecondsSinceEpoch}';
        await widget.controller.addEmployee(
          uid: uid,
          email: _emailController.text.trim(),
          displayName: _nameController.text.trim(),
          role: _selectedRole,
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          branchId: _branchIdController.text.trim().isEmpty
              ? null
              : _branchIdController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode
                ? 'Đã cập nhật nhân viên thành công'
                : 'Đã thêm nhân viên thành công'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditMode ? 'Cập nhật nhân viên' : 'Thêm nhân viên'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  if (!value.contains('@')) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Vai trò *',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                items: _roles.entries
                    .map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedRole = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _branchIdController,
                decoration: const InputDecoration(
                  labelText: 'Mã chi nhánh (để trống nếu toàn hệ thống)',
                  prefixIcon: Icon(Icons.store_outlined),
                  hintText: 'VD: branch_hcm_q1',
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        isEditMode ? 'Cập nhật' : 'Thêm nhân viên',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
