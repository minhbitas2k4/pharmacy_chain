import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/models/user_model.dart';
import '../models/app_user_model.dart';

class UserPermissionService {
  UserPermissionService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<AppUserModel>> fetchUsers() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('users')
        .get();

    return snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data());
      data['username'] = doc.id;
      final String rawRole = data['role']?.toString() ?? 'pharmacist';
      final String normalizedRole = UserModel.normalizeRole(rawRole);
      return AppUserModel(
        name: data['displayName']?.toString() ?? doc.id,
        username: data['email']?.toString() ?? doc.id,
        role: normalizedRole,
        isLocked: data['isLocked'] == true,
        lastSeenDevice: data['lastSeenDevice']?.toString() ?? 'Android App',
        lastActiveAt: data['lastActiveAt']?.toString() ?? 'Vừa xong',
      );
    }).toList();
  }

  Future<void> updateUserRole({required String username, required String role}) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: username)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    await snapshot.docs.first.reference.set(
      <String, dynamic>{'role': role},
      SetOptions(merge: true),
    );
  }

  Future<void> updateUserLock({required String username, required bool isLocked}) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: username)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    await snapshot.docs.first.reference.set(
      <String, dynamic>{'isLocked': isLocked},
      SetOptions(merge: true),
    );
  }
}
