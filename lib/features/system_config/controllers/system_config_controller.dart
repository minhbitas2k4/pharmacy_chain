import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/system_config_model.dart';
import '../services/system_config_service.dart';

class SystemConfigController extends ChangeNotifier {
  SystemConfigController({SystemConfigService? systemConfigService})
    : _systemConfigService = systemConfigService ?? SystemConfigService() {
    startTimeController = TextEditingController(text: '07:00');
    endTimeController = TextEditingController(text: '22:00');
  }

  final SystemConfigService _systemConfigService;
  late final TextEditingController startTimeController;
  late final TextEditingController endTimeController;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _selectedRoundingOption = 'Làm tròn 500đ';
  SystemConfigModel? _config;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get selectedRoundingOption => _selectedRoundingOption;
  SystemConfigModel? get config => _config;

  Future<void> loadConfig() async {
    _setLoading(true);
    try {
      _config = await _systemConfigService.fetchConfig();
      startTimeController.text = _config!.startTime;
      endTimeController.text = _config!.endTime;
      _selectedRoundingOption = _config!.roundingOption;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void selectRoundingOption(String option) {
    _selectedRoundingOption = option;
    notifyListeners();
  }

  String? validateTimeRange() {
    final int? startMinutes = _toMinutes(startTimeController.text);
    final int? endMinutes = _toMinutes(endTimeController.text);
    if (startMinutes == null || endMinutes == null) {
      return 'Giờ hoạt động không hợp lệ';
    }
    if (startMinutes >= endMinutes) {
      return 'Giờ bắt đầu phải nhỏ hơn giờ kết thúc';
    }
    return null;
  }

  Future<bool> saveConfig() async {
    final String? validationError = validateTimeRange();
    if (validationError != null) {
      return false;
    }
    _isSaving = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 550));
    _isSaving = false;
    notifyListeners();
    return true;
  }

  int? _toMinutes(String value) {
    final RegExpMatch? match = RegExp(
      r'^(\d{2}):(\d{2})$',
    ).firstMatch(value.trim());
    if (match == null) {
      return null;
    }
    final int? hour = int.tryParse(match.group(1) ?? '');
    final int? minute = int.tryParse(match.group(2) ?? '');
    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }
    return hour * 60 + minute;
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    startTimeController.dispose();
    endTimeController.dispose();
    super.dispose();
  }
}
