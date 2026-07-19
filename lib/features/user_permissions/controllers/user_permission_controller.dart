import 'package:flutter/foundation.dart';

import '../models/app_user_model.dart';
import '../services/user_permission_service.dart';

class UserPermissionController extends ChangeNotifier {
  UserPermissionController({UserPermissionService? userPermissionService})
    : _userPermissionService = userPermissionService ?? UserPermissionService();

  final UserPermissionService _userPermissionService;

  bool _isLoading = false;
  List<AppUserModel> _users = <AppUserModel>[];
  String _query = '';

  bool get isLoading => _isLoading;
  List<AppUserModel> get users {
    final Iterable<AppUserModel> filtered = _users.where((AppUserModel user) {
      final String searchTarget = '${user.name} ${user.username} ${user.role}'
          .toLowerCase();
      return searchTarget.contains(_query.toLowerCase());
    });
    return List<AppUserModel>.unmodifiable(filtered);
  }

  Future<void> loadUsers() async {
    _setLoading(true);
    try {
      _users = await _userPermissionService.fetchUsers();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void updateQuery(String value) {
    _query = value.trim();
    notifyListeners();
  }

  Future<void> toggleLock(AppUserModel user) async {
    final bool nextState = !user.isLocked;
    await _userPermissionService.updateUserLock(
      username: user.username,
      isLocked: nextState,
    );
    _users = _users
        .map(
          (AppUserModel item) => item.username == user.username
              ? item.copyWith(isLocked: nextState)
              : item,
        )
        .toList();
    notifyListeners();
  }

  Future<void> updateRole(AppUserModel user, String role) async {
    await _userPermissionService.updateUserRole(
      username: user.username,
      role: role,
    );
    _users = _users
        .map(
          (AppUserModel item) =>
              item.username == user.username ? item.copyWith(role: role) : item,
        )
        .toList();
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }
}
