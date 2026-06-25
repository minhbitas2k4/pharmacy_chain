import 'package:flutter/foundation.dart';

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
  List<ShiftModel> _today = <ShiftModel>[];
  final List<ShiftModel> _extra = <ShiftModel>[];

  bool get isLoading => _isLoading;
  int get selectedIndex => _selectedIndex;
  List<WorkScheduleModel> get month =>
      List<WorkScheduleModel>.unmodifiable(_month);
  List<ShiftModel> get todayShifts =>
      List<ShiftModel>.unmodifiable([..._today, ..._extra]);

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _month = await _scheduleService.fetchMonth();
      // _today = await _scheduleService.fetchTodayShifts();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectDate(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void addShift(String name, String start, String end) {
    _extra.add(ShiftModel(name: name, time: '$start-$end', status: 'Ca mới'));
    notifyListeners();
  }
}
