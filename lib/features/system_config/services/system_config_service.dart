import '../models/system_config_model.dart';

class SystemConfigService {
  Future<SystemConfigModel> fetchConfig() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return const SystemConfigModel(
      startTime: '07:00',
      endTime: '22:00',
      appliedLabel: 'Đang áp dụng',
      daysLabel: 'Thứ 2 - CN',
      branchScope: 'Tất cả chi nhánh',
      roundingOption: 'Làm tròn 500đ',
      invoiceFormat: 'Định dạng hóa đơn chuẩn',
    );
  }
}
