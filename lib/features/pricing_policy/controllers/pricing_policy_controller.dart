import 'package:flutter/foundation.dart';

import '../models/pricing_policy_model.dart';
import '../models/price_adjustment_model.dart';
import '../services/pricing_policy_service.dart';

class PricingPolicyController extends ChangeNotifier {
  PricingPolicyController({PricingPolicyService? pricingPolicyService})
    : _pricingPolicyService = pricingPolicyService ?? PricingPolicyService();

  final PricingPolicyService _pricingPolicyService;

  bool _isLoading = false;
  List<PricingPolicyModel> _policies = <PricingPolicyModel>[];
  List<PriceAdjustmentModel> _adjustments = <PriceAdjustmentModel>[];

  bool get isLoading => _isLoading;
  List<PricingPolicyModel> get policies =>
      List<PricingPolicyModel>.unmodifiable(_policies);
  List<PriceAdjustmentModel> get adjustments =>
      List<PriceAdjustmentModel>.unmodifiable(_adjustments);

  Future<void> loadPolicies() async {
    _setLoading(true);
    try {
      _policies = await _pricingPolicyService.fetchPolicies();
      _adjustments = await _pricingPolicyService.fetchPriceAdjustments();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> approvePolicy(PricingPolicyModel policy) async {
    try {
      await _pricingPolicyService.updatePolicyStatus(
        title: policy.title,
        status: PricingPolicyStatus.active,
      );
      _policies = _policies
          .map(
            (PricingPolicyModel item) => item.title == policy.title
                ? item.copyWith(status: PricingPolicyStatus.active)
                : item,
          )
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> rejectPolicy(PricingPolicyModel policy) async {
    try {
      await _pricingPolicyService.updatePolicyStatus(
        title: policy.title,
        status: PricingPolicyStatus.rejected,
      );
      _policies = _policies
          .map(
            (PricingPolicyModel item) => item.title == policy.title
                ? item.copyWith(status: PricingPolicyStatus.rejected)
                : item,
          )
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> approvePriceAdjustment(PriceAdjustmentModel adj) async {
    try {
      await _pricingPolicyService.approvePriceAdjustment(adj.id, adj.productId, adj.newPrice);
      _adjustments = _adjustments
          .map(
            (PriceAdjustmentModel item) => item.id == adj.id
                ? item.copyWith(status: 'approved')
                : item,
          )
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> rejectPriceAdjustment(PriceAdjustmentModel adj) async {
    try {
      await _pricingPolicyService.rejectPriceAdjustment(adj.id);
      _adjustments = _adjustments
          .map(
            (PriceAdjustmentModel item) => item.id == adj.id
                ? item.copyWith(status: 'rejected')
                : item,
          )
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> addPolicy(PricingPolicyModel policy) async {
    try {
      await _pricingPolicyService.createPolicy(policy);
      _policies = <PricingPolicyModel>[policy, ..._policies];
      notifyListeners();
    } catch (_) {}
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }
}
