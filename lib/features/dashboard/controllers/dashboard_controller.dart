import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/dashboard_summary_model.dart';
import '../services/dashboard_service.dart';

class DashboardController extends ChangeNotifier {
  DashboardController({DashboardService? dashboardService})
    : _dashboardService = dashboardService ?? DashboardService();

  final DashboardService _dashboardService;

  bool _isLoading = false;
  String? _errorMessage;
  DashboardPeriod _selectedPeriod = DashboardPeriod.today;
  DashboardSummaryModel? _summary;
  
  List<Map<String, String>> _branches = [];
  String _selectedBranchId = '';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DashboardPeriod get selectedPeriod => _selectedPeriod;
  DashboardSummaryModel? get summary => _summary;
  List<Map<String, String>> get branches => _branches;
  String get selectedBranchId => _selectedBranchId;

  Future<void> loadBranches() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('branches').get();
      _branches = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc.data()['branch_name']?.toString() ?? doc.id,
        };
      }).toList();
    } catch (_) {}
  }

  Future<void> loadSummary(DashboardPeriod period, {String? branchId}) async {
    _selectedPeriod = period;
    if (branchId != null) {
      _selectedBranchId = branchId;
    }
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      if (_branches.isEmpty) {
        await loadBranches();
      }
      _summary = await _dashboardService.fetchSummary(period, branchId: _selectedBranchId);
    } catch (error) {
      _summary = DashboardSummaryModel.error(period: period);
      _errorMessage = 'Không thể tải dữ liệu dashboard.';
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> selectBranch(String branchId) async {
    _selectedBranchId = branchId;
    await loadSummary(_selectedPeriod, branchId: _selectedBranchId);
  }

  Future<void> refresh() async {
    await loadSummary(_selectedPeriod, branchId: _selectedBranchId);
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
  }
}
