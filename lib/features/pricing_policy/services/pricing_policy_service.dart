import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/pricing_policy_model.dart';

class PricingPolicyService {
  PricingPolicyService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<PricingPolicyModel>> fetchPolicies() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('pricing_policies')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data());
      return PricingPolicyModel(
        title: data['title']?.toString() ?? 'Chính sách',
        subtitle: data['subtitle']?.toString() ?? '',
        status: _statusFromString(data['status']?.toString()),
        storeCount: data['storeCount']?.toString() ?? '',
      );
    }).toList();
  }

  Future<void> updatePolicyStatus({required String title, required PricingPolicyStatus status}) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('pricing_policies')
        .where('title', isEqualTo: title)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    await snapshot.docs.first.reference.set(
      <String, dynamic>{'status': status.name},
      SetOptions(merge: true),
    );
  }

  PricingPolicyStatus _statusFromString(String? value) {
    switch (value) {
      case 'active':
        return PricingPolicyStatus.active;
      case 'rejected':
        return PricingPolicyStatus.rejected;
      case 'scheduled':
        return PricingPolicyStatus.scheduled;
      default:
        return PricingPolicyStatus.pending;
    }
  }
}
