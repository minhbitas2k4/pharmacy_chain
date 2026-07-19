import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/shift_handover_model.dart';
import '../models/shift_model.dart';
import '../models/shift_request_model.dart';
import '../services/shift_service.dart';

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

  void loadSchedule() {
    _setLoading(true);
    _scheduleSubscription?.cancel();
    _scheduleSubscription = _shiftService.getWeeklySchedule(branchId).listen(
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

    _changeRequestsSubscription = _shiftService.getChangeRequests(branchId).listen(
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

    _leaveRequestsSubscription = _shiftService.getLeaveRequests(branchId).listen(
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
