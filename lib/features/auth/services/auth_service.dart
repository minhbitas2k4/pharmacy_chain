import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<UserModel> login({
    required String username,
    required String password,
  }) async {

    final credential =
    await _auth.signInWithEmailAndPassword(
      email: username.trim(),
      password: password.trim(),
    );

    final uid = credential.user!.uid;

    final doc =
    await _firestore
        .collection('users')
        .doc(uid)
        .get();

    if (!doc.exists) {
      throw Exception('User profile not found');
    }

    return UserModel.fromMap(
      doc.data()!,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}