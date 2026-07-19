import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/work_schedule_model.dart';
import '../services/schedule_service.dart';

class ScheduleController extends ChangeNotifier {
  ScheduleController({required this.branchId, ScheduleService? scheduleService})
    : _scheduleService = scheduleService ?? ScheduleService();

  final String branchId;
  final ScheduleService _scheduleService;
  bool _isLoading = false;
  int _selectedIndex = 0;
  List<WorkScheduleModel> _schedules = <WorkScheduleModel>[];
  String? _errorMessage;
  String? _selectedUserId;

  // Dropdown data
  List<Map<String, dynamic>> _shifts = [];
  List<Map<String, dynamic>> _employees = [];

  StreamSubscription<List<WorkScheduleModel>>? _subscription;

  bool get isLoading => _isLoading;
  int get selectedIndex => _selectedIndex;
  List<WorkScheduleModel> get schedules =>
      List<WorkScheduleModel>.unmodifiable(_schedules);
  String? get errorMessage => _errorMessage;
  String? get selectedUserId => _selectedUserId;
  List<Map<String, dynamic>> get shifts =>
      List<Map<String, dynamic>>.unmodifiable(_shifts);
  List<Map<String, dynamic>> get employees =>
      List<Map<String, dynamic>>.unmodifiable(_employees);

  List<WorkScheduleModel> getSchedulesForDay(int day) {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year;
    final dateStr = '$year-$month-${day.toString().padLeft(2, '0')}';
    return _schedules.where((s) => s.workDate == dateStr).toList();
  }

  void loadSchedules() {
    _setLoading(true);
    final now = DateTime.now();
    final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    _subscription?.cancel();

    if (_selectedUserId != null && _selectedUserId!.isNotEmpty) {
      _subscription = _scheduleService
          .getSchedulesByUser(branchId, _selectedUserId!, month)
          .listen(
        (schedules) {
          _schedules = schedules;
          _errorMessage = null;
          _setLoading(false);
        },
        onError: (error) {
          _errorMessage = 'Không thể tải lịch làm việc';
          _setLoading(false);
        },
      );
    } else {
      _subscription = _scheduleService.getSchedules(branchId, month).listen(
        (schedules) {
          _schedules = schedules;
          _errorMessage = null;
          _setLoading(false);
        },
        onError: (error) {
          _errorMessage = 'Không thể tải lịch làm việc';
          _setLoading(false);
        },
      );
    }
  }

  Future<void> loadDropdownData() async {
    try {
      _shifts = await _scheduleService.getShifts(branchId);
      _employees = await _scheduleService.getBranchEmployees(branchId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Không thể tải dữ liệu dropdown';
      notifyListeners();
    }
  }

  void selectDate(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void setUserFilter(String? userId) {
    _selectedUserId = userId;
    loadSchedules();
  }

  Future<void> addSchedule({
    required String userId,
    required String shiftId,
    required String workDate,
    String? notes,
  }) async {
    try {
      await _scheduleService.addSchedule(
        branchId: branchId,
        userId: userId,
        shiftId: shiftId,
        workDate: workDate,
        notes: notes,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Lỗi khi thêm lịch làm việc';
      notifyListeners();
    }
  }

  Future<void> updateSchedule(
      String scheduleId, Map<String, dynamic> data) async {
    try {
      await _scheduleService.updateSchedule(scheduleId, data);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Lỗi khi cập nhật lịch';
      notifyListeners();
    }
  }

  Future<void> deleteSchedule(String scheduleId) async {
    try {
      await _scheduleService.deleteSchedule(scheduleId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Lỗi khi xóa lịch';
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
