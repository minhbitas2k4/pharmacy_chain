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
}
