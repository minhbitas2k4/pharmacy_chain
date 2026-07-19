import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: username.trim(),
      password: password.trim(),
    );

    final uid = credential.user!.uid;
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      throw Exception('User profile not found');
    }

    final user = UserModel.fromMap(doc.data()!..['uid'] = uid);
    if (user.status != null &&
        user.status!.toLowerCase() != 'active') {
      await _auth.signOut();
      throw Exception('Tài khoản đã bị khóa');
    }

    return user;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<List<UserModel>> fetchUsers() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('users')
        .get();

    return snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
          final data = Map<String, dynamic>.from(doc.data());
          data['uid'] = doc.id;
          return UserModel.fromMap(data);
        })
        .toList();
  }

  Future<void> updateUserRole({required String uid, required String role}) async {
    await _firestore.collection('users').doc(uid).set(
      <String, dynamic>{'role': role},
      SetOptions(merge: true),
    );
  }

  Future<void> toggleUserLock({required String uid, required bool isLocked}) async {
    await _firestore.collection('users').doc(uid).set(
      <String, dynamic>{'isLocked': isLocked},
      SetOptions(merge: true),
    );
  }
}