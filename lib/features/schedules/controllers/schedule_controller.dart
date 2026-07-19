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

  StreamSubscription<List<WorkScheduleModel>>? _subscription;

  bool get isLoading => _isLoading;
  int get selectedIndex => _selectedIndex;
  List<WorkScheduleModel> get schedules =>
      List<WorkScheduleModel>.unmodifiable(_schedules);
  String? get errorMessage => _errorMessage;

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

  void selectDate(int index) {
    _selectedIndex = index;
    notifyListeners();
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
    } catch (e) {
      _errorMessage = 'Lỗi khi thêm lịch làm việc';
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
