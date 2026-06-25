import 'package:flutter/foundation.dart';

import '../models/shift_handover_model.dart';
import '../models/shift_model.dart';
import '../models/shift_request_model.dart';
import '../services/shift_service.dart';

class ShiftController extends ChangeNotifier {
  ShiftController({ShiftService? shiftService})
    : _shiftService = shiftService ?? ShiftService();

  final ShiftService _shiftService;
  bool _isLoading = false;
  int _selectedTab = 0;
  List<ShiftModel> _weeklySchedule = <ShiftModel>[];
  List<ShiftRequestModel> _changeRequests = <ShiftRequestModel>[];
  List<ShiftRequestModel> _leaveRequests = <ShiftRequestModel>[];
  ShiftHandoverModel? _handover;
  final List<ShiftModel> _extraSchedule = <ShiftModel>[];

  bool get isLoading => _isLoading;
  int get selectedTab => _selectedTab;
  List<ShiftModel> get weeklySchedule =>
      List<ShiftModel>.unmodifiable([..._weeklySchedule, ..._extraSchedule]);
  List<ShiftRequestModel> get changeRequests =>
      List<ShiftRequestModel>.unmodifiable(_changeRequests);
  List<ShiftRequestModel> get leaveRequests =>
      List<ShiftRequestModel>.unmodifiable(_leaveRequests);
  ShiftHandoverModel? get handover => _handover;

  Future<void> loadSchedule() async {
    _setLoading(true);
    try {
      _weeklySchedule = await _shiftService.fetchWeeklySchedule();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> loadRequests() async {
    _setLoading(true);
    try {
      _changeRequests = await _shiftService.fetchRequests(
        ShiftRequestType.changeShift,
      );
      _leaveRequests = await _shiftService.fetchRequests(
        ShiftRequestType.leave,
      );
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> loadHandover() async {
    _setLoading(true);
    try {
      _handover = await _shiftService.fetchHandover();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void selectTab(int index) {
    _selectedTab = index;
    notifyListeners();
  }

  void approveRequest(ShiftRequestModel request) {
    _updateRequest(request, ShiftRequestStatus.approved);
  }

  void rejectRequest(ShiftRequestModel request) {
    _updateRequest(request, ShiftRequestStatus.rejected);
  }

  void addShift(String name, String start, String end) {
    _extraSchedule.add(
      ShiftModel(name: name, time: '$start - $end', status: 'Ca mới'),
    );
    notifyListeners();
  }

  void _updateRequest(ShiftRequestModel request, ShiftRequestStatus status) {
    _changeRequests = _changeRequests
        .map(
          (ShiftRequestModel item) =>
              item.name == request.name ? item.copyWith(status: status) : item,
        )
        .toList();
    _leaveRequests = _leaveRequests
        .map(
          (ShiftRequestModel item) =>
              item.name == request.name ? item.copyWith(status: status) : item,
        )
        .toList();
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }
}
