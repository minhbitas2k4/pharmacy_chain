import '../models/pricing_policy_model.dart';

class PricingPolicyService {
  Future<List<PricingPolicyModel>> fetchPolicies() async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    return const <PricingPolicyModel>[
      PricingPolicyModel(
        title: 'KM Tháng 7 - Kháng sinh',
        subtitle: 'Giảm 15% nhóm Kháng sinh • 5 CN',
        status: PricingPolicyStatus.pending,
        storeCount: '5 CN',
      ),
      PricingPolicyModel(
        title: 'Combo Vitamin tháng 8',
        subtitle: 'Mua 2 tặng 1 - 01/08/2025',
        status: PricingPolicyStatus.scheduled,
        storeCount: 'Toàn hệ thống',
      ),
    ];
  }
}
