import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/shift_handover_model.dart';
import '../models/shift_model.dart';
import '../models/shift_request_model.dart';
import '../services/shift_service.dart';

enum ShiftPeriod { day, week, month }

class ShiftController extends ChangeNotifier {
  ShiftController({required this.branchId, ShiftService? shiftService})
    : _shiftService = shiftService ?? ShiftService();

  final String branchId;
  final ShiftService _shiftService;
  bool _isLoading = false;
  int _selectedTab = 0;
  List<ShiftModel> _weeklySchedule = <ShiftModel>[];
  List<ShiftRequestModel> _changeRequests = <ShiftRequestModel>[];
  List<ShiftRequestModel> _leaveRequests = <ShiftRequestModel>[];
  ShiftHandoverModel? _handover;
  String? _errorMessage;

  StreamSubscription<List<ShiftModel>>? _scheduleSubscription;
  StreamSubscription<List<ShiftRequestModel>>? _changeRequestsSubscription;
  StreamSubscription<List<ShiftRequestModel>>? _leaveRequestsSubscription;

  ShiftPeriod _selectedPeriod = ShiftPeriod.week;
  DateTime _selectedDate = DateTime.now();

  bool get isLoading => _isLoading;
  int get selectedTab => _selectedTab;
  List<ShiftModel> get weeklySchedule =>
      List<ShiftModel>.unmodifiable(_weeklySchedule);
  List<ShiftRequestModel> get changeRequests =>
      List<ShiftRequestModel>.unmodifiable(_changeRequests);
  List<ShiftRequestModel> get leaveRequests =>
      List<ShiftRequestModel>.unmodifiable(_leaveRequests);
  ShiftHandoverModel? get handover => _handover;
  String? get errorMessage => _errorMessage;
  ShiftPeriod get selectedPeriod => _selectedPeriod;
  DateTime get selectedDate => _selectedDate;

  void loadSchedule() {
    _setLoading(true);
    _scheduleSubscription?.cancel();

    final range = _getDateRange(_selectedPeriod, _selectedDate);

    _scheduleSubscription = _shiftService
        .getScheduleByRange(
          branchId: branchId,
          startDate: range.start,
          endDate: range.end,
        )
        .listen(
      (schedule) {
        _weeklySchedule = schedule;
        _errorMessage = null;
        _setLoading(false);
      },
      onError: (error) {
        _errorMessage = 'Không thể tải lịch ca làm việc';
        _setLoading(false);
      },
    );
  }

  void loadRequests() {
    _setLoading(true);
    _changeRequestsSubscription?.cancel();
    _leaveRequestsSubscription?.cancel();

    _changeRequestsSubscription =
        _shiftService.getChangeRequests(branchId).listen(
      (requests) {
        _changeRequests = requests;
        _errorMessage = null;
        _setLoading(false);
      },
      onError: (error) {
        _errorMessage = 'Không thể tải yêu cầu đổi ca';
        _setLoading(false);
      },
    );

    _leaveRequestsSubscription =
        _shiftService.getLeaveRequests(branchId).listen(
      (requests) {
        _leaveRequests = requests;
        _errorMessage = null;
        _setLoading(false);
      },
      onError: (error) {
        _errorMessage = 'Không thể tải yêu cầu nghỉ phép';
        _setLoading(false);
      },
    );
  }

  Future<void> loadHandover(String userId, String workDate) async {
    _setLoading(true);
    try {
      _handover = await _shiftService.getHandoverData(
        branchId: branchId,
        userId: userId,
        workDate: workDate,
      );
    } catch (e) {
      _errorMessage = 'Không thể tải dữ liệu bàn giao';
    } finally {
      _setLoading(false);
    }
  }

  void selectTab(int index) {
    _selectedTab = index;
    notifyListeners();
  }

  void setPeriod(ShiftPeriod period) {
    if (_selectedPeriod == period) return;
    _selectedPeriod = period;
    notifyListeners();
    loadSchedule();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
    loadSchedule();
  }

  void previousPeriod() {
    switch (_selectedPeriod) {
      case ShiftPeriod.day:
        _selectedDate = _selectedDate.subtract(const Duration(days: 1));
        break;
      case ShiftPeriod.week:
        _selectedDate = _selectedDate.subtract(const Duration(days: 7));
        break;
      case ShiftPeriod.month:
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month - 1,
          _selectedDate.day,
        );
        break;
    }
    notifyListeners();
    loadSchedule();
  }

  void nextPeriod() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case ShiftPeriod.day:
        final next = _selectedDate.add(const Duration(days: 1));
        if (!next.isAfter(now)) _selectedDate = next;
        break;
      case ShiftPeriod.week:
        final next = _selectedDate.add(const Duration(days: 7));
        if (!next.isAfter(now)) _selectedDate = next;
        break;
      case ShiftPeriod.month:
        final next = DateTime(
          _selectedDate.year,
          _selectedDate.month + 1,
          _selectedDate.day,
        );
        if (!next.isAfter(now)) _selectedDate = next;
        break;
    }
    notifyListeners();
    loadSchedule();
  }

  String get periodLabel {
    switch (_selectedPeriod) {
      case ShiftPeriod.day:
        return '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
      case ShiftPeriod.week:
        return 'Tuần ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
      case ShiftPeriod.month:
        return 'Tháng ${_selectedDate.month}/${_selectedDate.year}';
    }
  }

  ({DateTime start, DateTime end}) _getDateRange(
    ShiftPeriod period,
    DateTime date,
  ) {
    switch (period) {
      case ShiftPeriod.day:
        final start = DateTime(date.year, date.month, date.day);
        final end = DateTime(date.year, date.month, date.day, 23, 59, 59);
        return (start: start, end: end);

      case ShiftPeriod.week:
        final weekday = date.weekday;
        final start = date.subtract(Duration(days: weekday - 1));
        final startOfDay = DateTime(start.year, start.month, start.day);
        final endOfDay = startOfDay.add(const Duration(days: 7, seconds: -1));
        return (start: startOfDay, end: endOfDay);

      case ShiftPeriod.month:
        final start = DateTime(date.year, date.month, 1);
        final end = DateTime(date.year, date.month + 1, 0, 23, 59, 59);
        return (start: start, end: end);
    }
  }

  Future<void> approveRequest(ShiftRequestModel request) async {
    try {
      await _shiftService.approveRequest(request.id);
    } catch (e) {
      _errorMessage = 'Lỗi khi duyệt yêu cầu';
      notifyListeners();
    }
  }

  Future<void> rejectRequest(ShiftRequestModel request) async {
    try {
      await _shiftService.rejectRequest(request.id);
    } catch (e) {
      _errorMessage = 'Lỗi khi từ chối yêu cầu';
      notifyListeners();
    }
  }

  Future<void> signHandover({
    required String userId,
    required String workDate,
    required double actualCash,
    String? reason,
  }) async {
    _setLoading(true);
    try {
      await _shiftService.signHandover(
        branchId: branchId,
        userId: userId,
        workDate: workDate,
        actualCash: actualCash,
        reason: reason,
      );
    } catch (e) {
      _errorMessage = 'Lỗi khi ký xác nhận bàn giao';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _scheduleSubscription?.cancel();
    _changeRequestsSubscription?.cancel();
    _leaveRequestsSubscription?.cancel();
    super.dispose();
  }
}
