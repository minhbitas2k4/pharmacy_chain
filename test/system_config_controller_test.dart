import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_chain/features/system_config/controllers/system_config_controller.dart';
import 'package:pharmacy_chain/features/system_config/models/system_config_model.dart';
import 'package:pharmacy_chain/features/system_config/services/system_config_service.dart';

class FakeSystemConfigService extends SystemConfigService {
  SystemConfigModel? savedConfig;

  @override
  Future<SystemConfigModel> fetchConfig() async {
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

  @override
  Future<void> saveConfig(SystemConfigModel config, {String? updatedBy}) async {
    savedConfig = config;
  }
}

void main() {
  group('SystemConfigController', () {
    test('saves the updated system config through the service', () async {
      final FakeSystemConfigService service = FakeSystemConfigService();
      final SystemConfigController controller = SystemConfigController(
        systemConfigService: service,
      );

      await controller.loadConfig();
      controller.startTimeController.text = '08:00';
      controller.endTimeController.text = '20:00';
      controller.selectRoundingOption('1.000đ');
      controller.invoiceFormatController.text = 'INV/2026/001';

      final bool saved = await controller.saveConfig();

      expect(saved, isTrue);
      expect(service.savedConfig, isNotNull);
      expect(service.savedConfig!.startTime, '08:00');
      expect(service.savedConfig!.endTime, '20:00');
      expect(service.savedConfig!.roundingOption, '1.000đ');
      expect(service.savedConfig!.invoiceFormat, 'INV/2026/001');

      controller.dispose();
    });
  });
}
