import '../../../core/constants/app_roles.dart';
import '../models/user_model.dart';

class AuthService {
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    return UserModel(
      id: 'chain-manager-001',
      username: username,
      password: '123',
      role: AppRoles.chainManager,
      displayName: 'Chain Manager',
    );
  }
}
