import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/empty_view.dart';
import '../controllers/employee_controller.dart';
import '../widgets/employee_profile_card.dart';
import 'employee_detail_screen.dart';
import 'employee_form_screen.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  late final EmployeeController _controller;

  static const _roleFilters = <String, String>{
    '': 'Tất cả',
    'pharmacist': 'Dược sĩ',
    'cashier': 'Thu ngân',
    'warehouse_staff': 'Kho',
    'branch_manager': 'QL Chi nhánh',
  };

  @override
  void initState() {
    super.initState();
    _controller = EmployeeController();
    _controller.loadEmployees();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return Column(
              children: [
                const AppHeader(),
                Expanded(
                  child: _controller.isLoading
                      ? const LoadingView(message: 'Đang tải nhân viên...')
                      : _buildContent(context),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push<void>(
            context,
            MaterialPageRoute(
              builder: (_) => EmployeeFormScreen(controller: _controller),
            ),
          );
        },
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Thêm NV'),
        backgroundColor: AppColors.pharmaGreen,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Hồ sơ nhân sự',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            '${_controller.activeCount}/${_controller.totalCount} nhân viên đang hoạt động',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          // Search bar
          TextField(
            onChanged: _controller.updateQuery,
            decoration: const InputDecoration(
              hintText: 'Tìm kiếm nhân viên...',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 12),

          // Role filter chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _roleFilters.entries.map((entry) {
                final isSelected =
                    (_controller.selectedRoleFilter ?? '') == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(entry.value),
                    selected: isSelected,
                    onSelected: (_) => _controller.setRoleFilter(
                        entry.key.isEmpty ? null : entry.key),
                    selectedColor: AppColors.pharmaMint,
                    checkmarkColor: AppColors.pharmaDarkGreen,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.pharmaDarkGreen
                          : AppColors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Employee list
          if (_controller.employees.isEmpty)
            const EmptyView(
              title: 'Không tìm thấy nhân viên',
              message: 'Thử thay đổi bộ lọc hoặc thêm nhân viên mới',
              icon: Icons.people_outline,
            )
          else
            ..._controller.employees.map(
              (employee) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: EmployeeProfileCard(
                  employee: employee,
                  onView: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EmployeeDetailScreen(
                        employee: employee,
                        controller: _controller,
                      ),
                    ),
                  ),
                  onUpdate: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EmployeeFormScreen(
                        employee: employee,
                        controller: _controller,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
