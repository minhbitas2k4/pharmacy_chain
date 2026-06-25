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

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DashboardPeriod get selectedPeriod => _selectedPeriod;
  DashboardSummaryModel? get summary => _summary;

  Future<void> loadSummary(DashboardPeriod period) async {
    _selectedPeriod = period;
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      _summary = await _dashboardService.fetchSummary(period);
    } catch (error) {
      _summary = DashboardSummaryModel.error(period: period);
      _errorMessage = 'Không thể tải dữ liệu dashboard.';
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadSummary(_selectedPeriod);
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
