import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/pricing_policy_model.dart';
import '../models/price_adjustment_model.dart';

class PricingPolicyService {
  PricingPolicyService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<PricingPolicyModel>> fetchPolicies() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('pricing_policies')
          .orderBy('createdAt', descending: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
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
    } catch (_) {}

    // Fallback/Default policies for chain manager
    final fallbacks = <PricingPolicyModel>[
      const PricingPolicyModel(
        title: 'Bảng giá Hè 2026',
        subtitle: 'Giảm giá 5% các mặt hàng chống nắng & bổ sung vitamin toàn chuỗi',
        status: PricingPolicyStatus.active,
        storeCount: 'Tất cả chi nhánh',
      ),
      const PricingPolicyModel(
        title: 'Khuyến mãi Amoxicillin',
        subtitle: 'Giảm 10% cho nhóm chi nhánh miền Nam',
        status: PricingPolicyStatus.pending,
        storeCount: 'Chi nhánh Quận 1',
      ),
      const PricingPolicyModel(
        title: 'Chính sách giá Paracetamol',
        subtitle: 'Điều chỉnh tăng nhẹ giá Paracetamol 500mg do khan hiếm nguyên liệu',
        status: PricingPolicyStatus.scheduled,
        storeCount: 'Tất cả chi nhánh',
      ),
    ];

    for (final p in fallbacks) {
      createPolicy(p).catchError((_) {});
    }

    return fallbacks;
  }

  Future<void> createPolicy(PricingPolicyModel policy) async {
    await _firestore.collection('pricing_policies').add(<String, dynamic>{
      'title': policy.title,
      'subtitle': policy.subtitle,
      'status': policy.status.name,
      'storeCount': policy.storeCount,
      'createdAt': FieldValue.serverTimestamp(),
    });
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

  Future<List<PriceAdjustmentModel>> fetchPriceAdjustments() async {
    try {
      final snapshot = await _firestore
          .collection('price_adjustments')
          .orderBy('created_at', descending: true)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => PriceAdjustmentModel.fromMap(doc.id, doc.data())).toList();
      }
    } catch (_) {}

    // Fallback mock adjustments if empty
    final fallbacks = <PriceAdjustmentModel>[
      PriceAdjustmentModel(
        id: 'adj_001',
        productId: 'product_001',
        productName: 'Paracetamol 500mg',
        branchId: 'branch_hcm_q1',
        branchName: 'Chi nhánh Quận 1',
        oldPrice: '125.000đ',
        newPrice: '135.000đ',
        reason: 'Giá nhập tăng từ nhà phân phối sỉ',
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      PriceAdjustmentModel(
        id: 'adj_002',
        productId: 'product_002',
        productName: 'Amoxicillin 250mg',
        branchId: 'branch_hcm_q1',
        branchName: 'Chi nhánh Quận 1',
        oldPrice: '60.000đ',
        newPrice: '58.000đ',
        reason: 'Chạy chương trình kích cầu giảm tồn kho',
        status: 'approved',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    for (final a in fallbacks) {
      await _firestore.collection('price_adjustments').doc(a.id).set(a.toMap(), SetOptions(merge: true));
    }

    return fallbacks;
  }

  Future<void> approvePriceAdjustment(String adjustmentId, String productId, String newPrice) async {
    await _firestore.collection('price_adjustments').doc(adjustmentId).update({
      'status': 'approved',
    });

    await _firestore.collection('products').doc(productId).update({
      'price': newPrice,
    });

    final adjDoc = await _firestore.collection('price_adjustments').doc(adjustmentId).get();
    final branchId = adjDoc.data()?['branch_id']?.toString();

    await _firestore.collection('product_prices').add({
      'product_id': productId,
      'branch_id': branchId,
      'base_price': newPrice.replaceAll(RegExp(r'[^0-9]'), ''),
      'promo_price': newPrice.replaceAll(RegExp(r'[^0-9]'), ''),
      'approved_by': 'vEC8noEOHefBIEnlgqaJ2B38TA43',
    });
  }

  Future<void> rejectPriceAdjustment(String adjustmentId) async {
    await _firestore.collection('price_adjustments').doc(adjustmentId).update({
      'status': 'rejected',
    });
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
