import 'package:flutter/foundation.dart';

import '../../auth/controllers/auth_controller.dart';
import '../../shifts/models/shift_model.dart';
import '../models/work_schedule_model.dart';
import '../services/schedule_service.dart';

class ScheduleController extends ChangeNotifier {
  ScheduleController({ScheduleService? scheduleService})
    : _scheduleService = scheduleService ?? ScheduleService();

  final ScheduleService _scheduleService;
  bool _isLoading = false;
  int _selectedIndex = 0;
  List<WorkScheduleModel> _month = <WorkScheduleModel>[];
  final List<ShiftModel> _today = <ShiftModel>[];
  final List<ShiftModel> _extra = <ShiftModel>[];

  bool get isLoading => _isLoading;
  int get selectedIndex => _selectedIndex;
  List<WorkScheduleModel> get month =>
      List<WorkScheduleModel>.unmodifiable(_month);
  List<ShiftModel> get todayShifts =>
      List<ShiftModel>.unmodifiable([..._today, ..._extra]);

  void load({String? branchId, String? month}) {
    final finalBranchId = branchId ?? AuthController().currentUser?.branchId ?? 'branch_hcm_q1';
    final now = DateTime.now();
    final finalMonth = month ?? '${now.year}-${now.month.toString().padLeft(2, '0')}';
    
    _isLoading = true;
    notifyListeners();
    try {
      _scheduleService.getSchedules(finalBranchId, finalMonth).listen((schedules) {
        _month = schedules;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectDate(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void addShift(String name, String start, String end) {
    _extra.add(ShiftModel(
      id: DateTime.now().toString(),
      name: name,
      startTime: start,
      endTime: end,
      status: 'Ca mới',
    ));
    notifyListeners();
  }
}
