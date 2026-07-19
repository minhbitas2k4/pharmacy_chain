class SystemConfigModel {
  const SystemConfigModel({
    required this.startTime,
    required this.endTime,
    required this.appliedLabel,
    required this.daysLabel,
    required this.branchScope,
    required this.roundingOption,
    required this.invoiceFormat,
  });

  final String startTime;
  final String endTime;
  final String appliedLabel;
  final String daysLabel;
  final String branchScope;
  final String roundingOption;
  final String invoiceFormat;

  factory SystemConfigModel.fromMap(Map<String, dynamic> map) {
    return SystemConfigModel(
      startTime: (map['startTime'] ?? '07:00').toString(),
      endTime: (map['endTime'] ?? '22:00').toString(),
      appliedLabel: (map['appliedLabel'] ?? 'Đang áp dụng').toString(),
      daysLabel: (map['daysLabel'] ?? 'Thứ 2 - CN').toString(),
      branchScope: (map['branchScope'] ?? 'Tất cả chi nhánh').toString(),
      roundingOption: (map['roundingOption'] ?? 'Làm tròn 500đ').toString(),
      invoiceFormat: (map['invoiceFormat'] ?? 'Định dạng hóa đơn chuẩn').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'startTime': startTime,
      'endTime': endTime,
      'appliedLabel': appliedLabel,
      'daysLabel': daysLabel,
      'branchScope': branchScope,
      'roundingOption': roundingOption,
      'invoiceFormat': invoiceFormat,
    };
  }
}
