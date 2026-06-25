import 'package:flutter/foundation.dart';

import '../models/pricing_policy_model.dart';
import '../services/pricing_policy_service.dart';

class PricingPolicyController extends ChangeNotifier {
  PricingPolicyController({PricingPolicyService? pricingPolicyService})
    : _pricingPolicyService = pricingPolicyService ?? PricingPolicyService();

  final PricingPolicyService _pricingPolicyService;

  bool _isLoading = false;
  List<PricingPolicyModel> _policies = <PricingPolicyModel>[];

  bool get isLoading => _isLoading;
  List<PricingPolicyModel> get policies =>
      List<PricingPolicyModel>.unmodifiable(_policies);

  Future<void> loadPolicies() async {
    _setLoading(true);
    try {
      _policies = await _pricingPolicyService.fetchPolicies();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void approvePolicy(PricingPolicyModel policy) {
    _policies = _policies
        .map(
          (PricingPolicyModel item) => item.title == policy.title
              ? item.copyWith(status: PricingPolicyStatus.active)
              : item,
        )
        .toList();
    notifyListeners();
  }

  void rejectPolicy(PricingPolicyModel policy) {
    _policies = _policies
        .map(
          (PricingPolicyModel item) => item.title == policy.title
              ? item.copyWith(status: PricingPolicyStatus.rejected)
              : item,
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
