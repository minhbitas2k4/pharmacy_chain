import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/attendance_model.dart';
import '../services/attendance_service.dart';

class AttendanceController extends ChangeNotifier {
  AttendanceController({
    required this.branchId,
    AttendanceService? attendanceService,
  }) : _attendanceService = attendanceService ?? AttendanceService();

  final String branchId;
  final AttendanceService _attendanceService;
  bool _isLoading = false;
  List<AttendanceModel> _records = <AttendanceModel>[];
  String? _errorMessage;
  late String _selectedDate;

  StreamSubscription<List<AttendanceModel>>? _subscription;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedDate => _selectedDate;

  List<AttendanceModel> get records =>
      List<AttendanceModel>.unmodifiable(_records);

  int get presentCount =>
      _records.where((r) => r.isCheckedIn && !r.isAbsent).length;
  int get absentCount => _records.where((r) => r.isAbsent).length;
  int get lateCount =>
      _records.where((r) => r.attendanceStatus == 'Đi trễ').length;
  int get pendingCount =>
      _records.where((r) => !r.isCheckedIn && !r.isAbsent).length;

  void loadAttendance({String? date}) {
    final now = DateTime.now();
    _selectedDate = date ??
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    _setLoading(true);
    _subscription?.cancel();
    _subscription =
        _attendanceService.getAttendance(branchId, _selectedDate).listen(
      (records) {
        _records = records;
        _errorMessage = null;
        _setLoading(false);
      },
      onError: (error) {
        _errorMessage = 'Không thể tải dữ liệu chấm công';
        _setLoading(false);
      },
    );
  }

  void changeDate(String date) {
    loadAttendance(date: date);
  }

  Future<void> checkIn(String scheduleId) async {
    try {
      await _attendanceService.checkIn(scheduleId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Lỗi khi check-in';
      notifyListeners();
    }
  }

  Future<void> checkOut(String scheduleId) async {
    try {
      await _attendanceService.checkOut(scheduleId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Lỗi khi check-out';
      notifyListeners();
    }
  }

  Future<void> markAbsent(String scheduleId) async {
    try {
      await _attendanceService.markAbsent(scheduleId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Lỗi khi đánh dấu vắng mặt';
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
