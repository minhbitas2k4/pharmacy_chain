import 'package:flutter/foundation.dart';

import '../models/audit_log_model.dart';
import '../services/audit_log_service.dart';

class AuditLogController extends ChangeNotifier {
  AuditLogController({AuditLogService? auditLogService})
    : _auditLogService = auditLogService ?? AuditLogService();

  final AuditLogService _auditLogService;

  bool _isLoading = false;
  AuditFilter _selectedFilter = AuditFilter.all;
  List<AuditLogModel> _logs = <AuditLogModel>[];

  bool get isLoading => _isLoading;
  AuditFilter get selectedFilter => _selectedFilter;
  List<AuditLogModel> get logs {
    if (_selectedFilter == AuditFilter.all) {
      return List<AuditLogModel>.unmodifiable(_logs);
    }
    return List<AuditLogModel>.unmodifiable(
      _logs.where((AuditLogModel log) => log.filter == _selectedFilter),
    );
  }

  Future<void> loadLogs() async {
    _setLoading(true);
    try {
      _logs = await _auditLogService.fetchLogs();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void selectFilter(AuditFilter filter) {
    _selectedFilter = filter;
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
