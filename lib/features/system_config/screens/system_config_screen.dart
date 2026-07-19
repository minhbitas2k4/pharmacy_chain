import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../controllers/system_config_controller.dart';
import '../widgets/config_section_card.dart';

class SystemConfigScreen extends StatefulWidget {
  const SystemConfigScreen({super.key});

  @override
  State<SystemConfigScreen> createState() => _SystemConfigScreenState();
}

class _SystemConfigScreenState extends State<SystemConfigScreen> {
  late final SystemConfigController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SystemConfigController();
    _controller.loadConfig();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final String? validationError = _controller.validateTimeRange();
    if (validationError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validationError)));
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Xác nhận lưu cấu hình'),
        content: const Text('Bạn có chắc chắn muốn lưu cấu hình hệ thống?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final bool saved = await _controller.saveConfig();
    if (!mounted || !saved) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Lưu cấu hình thành công')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            return Column(
              children: <Widget>[
                const AppHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          'Cấu hình hệ thống',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tham số vận hành toàn chuỗi',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 20),
                        if (_controller.isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 80),
                            child: LoadingView(message: 'Đang tải cấu hình...'),
                          )
                        else ...<Widget>[
                          ConfigSectionCard(
                            title: 'Giờ hoạt động',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: TextFormField(
                                        controller:
                                            _controller.startTimeController,
                                        decoration: const InputDecoration(
                                          labelText: 'Giờ bắt đầu',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller:
                                            _controller.endTimeController,
                                        decoration: const InputDecoration(
                                          labelText: 'Giờ kết thúc',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: const <Widget>[
                                    StatusBadge(label: 'Đang áp dụng'),
                                    SizedBox(width: 12),
                                    Text('Thứ 2 - CN'),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text('Tất cả chi nhánh'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ConfigSectionCard(
                            title: 'Quy định làm tròn tiền',
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: <Widget>[
                                _OptionButton(
                                  label: 'Làm tròn 500đ',
                                  selected:
                                      _controller.selectedRoundingOption ==
                                      'Làm tròn 500đ',
                                  onTap: () => _controller.selectRoundingOption(
                                    'Làm tròn 500đ',
                                  ),
                                ),
                                _OptionButton(
                                  label: '1.000đ',
                                  selected:
                                      _controller.selectedRoundingOption ==
                                      '1.000đ',
                                  onTap: () => _controller.selectRoundingOption(
                                    '1.000đ',
                                  ),
                                ),
                                _OptionButton(
                                  label: 'Không LT',
                                  selected:
                                      _controller.selectedRoundingOption ==
                                      'Không LT',
                                  onTap: () => _controller.selectRoundingOption(
                                    'Không LT',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ConfigSectionCard(
                            title: 'Định dạng hóa đơn',
                            child: TextFormField(
                              controller: _controller.invoiceFormatController,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: 'Mẫu hóa đơn',
                                hintText: 'VD: INV/{yyyy}/{nnn}',
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          AppButton(
                            text: 'Lưu cấu hình',
                            isLoading: _controller.isSaving,
                            onPressed: _save,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? AppColors.pharmaGreen : Colors.white,
        foregroundColor: selected ? Colors.white : AppColors.textPrimary,
      ),
      child: Text(label),
    );
  }
}
