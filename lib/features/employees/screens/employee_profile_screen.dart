import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_header.dart';
import '../controllers/employee_controller.dart';
import '../widgets/employee_profile_card.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  late final EmployeeController _controller;

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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Hồ sơ nhân sự',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Thông tin & bằng cấp chuyên môn',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          onChanged: _controller.updateQuery,
                          decoration: const InputDecoration(
                            hintText: 'Tìm kiếm nhân viên',
                            prefixIcon: Icon(Icons.search_rounded),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._controller.employees.map(
                          (employee) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: EmployeeProfileCard(
                              employee: employee,
                              onView: () => showModalBottomSheet<void>(
                                context: context,
                                builder: (context) => Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        employee.name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(employee.title),
                                      Text(employee.cccd),
                                      Text(employee.phone),
                                      Text(employee.license),
                                    ],
                                  ),
                                ),
                              ),
                              onUpdate: () =>
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Mở form cập nhật nhân sự'),
                                    ),
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
