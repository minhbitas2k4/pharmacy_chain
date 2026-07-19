import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/employee_model.dart';

class EmployeeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Stream all employees. If [branchId] is provided, filter by branch.
  Stream<List<EmployeeModel>> getEmployees({String? branchId}) {
    Query<Map<String, dynamic>> query = _db.collection('users');

    if (branchId != null && branchId.isNotEmpty) {
      query = query.where('branchId', isEqualTo: branchId);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return EmployeeModel.fromMap(doc.data(), id: doc.id);
      }).toList();
    });
  }

  /// Get a single employee by uid.
  Future<EmployeeModel?> getEmployee(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return EmployeeModel.fromMap(doc.data()!, id: doc.id);
  }

  /// Add a new employee document in Firestore (users collection).
  /// Note: This only creates the Firestore user doc, NOT a Firebase Auth account.
  Future<void> addEmployee({
    required String uid,
    required String email,
    required String displayName,
    required String role,
    String? phone,
    String? branchId,
  }) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
      'phone': phone,
      'branchId': branchId,
      'status': 'ACTIVE',
    });
  }

  /// Update employee fields.
  Future<void> updateEmployee(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  /// Toggle employee status between ACTIVE and INACTIVE.
  Future<void> toggleEmployeeStatus(String uid, String currentStatus) async {
    final isActive = currentStatus.toLowerCase() == 'active';
    await _db.collection('users').doc(uid).update({
      'status': isActive ? 'INACTIVE' : 'ACTIVE',
    });
  }
}
