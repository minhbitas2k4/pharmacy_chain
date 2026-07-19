import '../models/app_user_model.dart';

class UserPermissionService {
  Future<List<AppUserModel>> fetchUsers() async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    return const <AppUserModel>[
      AppUserModel(
        name: 'Nguyễn Thị Lan',
        username: 'lan.nguyen@pharmachain.vn',
        role: 'Dược sĩ',
        isLocked: false,
      ),
      AppUserModel(
        name: 'Trần Văn Minh',
        username: 'minh.tran@pharmachain.vn',
        role: 'Thu ngân',
        isLocked: false,
      ),
      AppUserModel(
        name: 'Phạm Hùng',
        username: 'hung.pham@pharmachain.vn',
        role: 'Quản lý nhập hàng',
        isLocked: true,
      ),
      AppUserModel(
        name: 'Lê Thị Hoa',
        username: 'hoa.le@pharmachain.vn',
        role: 'Nhân sự',
        isLocked: false,
      ),
    ];
  }
}
