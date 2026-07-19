import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../controllers/user_permission_controller.dart';
import '../models/app_user_model.dart';
import '../widgets/user_permission_card.dart';

class UserPermissionScreen extends StatefulWidget {
  const UserPermissionScreen({super.key});

  @override
  State<UserPermissionScreen> createState() => _UserPermissionScreenState();
}

class _UserPermissionScreenState extends State<UserPermissionScreen> {
  late final UserPermissionController _controller;
  static const List<String> _roles = <String>[
    'Dược sĩ',
    'Thu ngân',
    'Quản lý nhập hàng',
    'Nhân sự',
    'Quản lý chuỗi',
  ];

  @override
  void initState() {
    super.initState();
    _controller = UserPermissionController();
    _controller.loadUsers();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showRoleDialog(AppUserModel user) async {
    final String? selectedRole = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String tempRole = user.role;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Chọn vai trò'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: _roles
                    .map(
                      (String role) => RadioListTile<String>(
                        value: role,
                        groupValue: tempRole,
                        title: Text(role),
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() => tempRole = value);
                          }
                        },
                      ),
                    )
                    .toList(),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, tempRole),
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selectedRole != null) {
      _controller.updateRole(user, selectedRole);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật quyền thành công')),
        );
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            final users = _controller.users;
            return Column(
              children: <Widget>[
                const AppHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          'Phân quyền người dùng',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Quản lý tài khoản, vai trò và quyền truy cập',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                onChanged: _controller.updateQuery,
                                decoration: InputDecoration(
                                  hintText: 'Tìm kiếm người dùng',
                                  prefixIcon: const Icon(Icons.search_rounded),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () =>
                                  _showSnack('Mở form thêm tài khoản'),
                              child: const Text('+ Thêm tài khoản'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (_controller.isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 80),
                            child: LoadingView(
                              message: 'Đang tải người dùng...',
                            ),
                          )
                        else if (users.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 28),
                            child: EmptyView(
                              title: 'Không tìm thấy người dùng',
                              message: 'Thử đổi từ khóa tìm kiếm.',
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: users.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (BuildContext context, int index) {
                              final AppUserModel user = users[index];
                              return UserPermissionCard(
                                user: user,
                                onEditRole: () => _showRoleDialog(user),
                                onToggleLock: () {
                                  _controller.toggleLock(user);
                                  _showSnack(
                                    user.isLocked ? 'Đã mở khóa' : 'Đã khóa',
                                  );
                                },
                              );
                            },
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
