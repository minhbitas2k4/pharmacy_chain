import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  AuthController({AuthService? authService})
    : _authService = authService ?? AuthService();

  final AuthService _authService;

  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;

  Future<UserModel?> login({
    required String username,
    required String password,
  }) async {
    // if (username.trim().isEmpty || password.trim().isEmpty)
      if (username.trim().isEmpty){
      _errorMessage = 'Vui lòng nhập tên đăng nhập và mật khẩu.';
      notifyListeners();
      return null;
    }

    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      final UserModel user = await _authService.login(
        username: username,
        password: password,
      );
      _currentUser = user;
      _errorMessage = null;
      return user;
    } catch (error) {
      _errorMessage = 'Đăng nhập thất bại, vui lòng thử lại.';
      return null;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
  }
}
