import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_header.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/shift_controller.dart';

class ShiftHandoverScreen extends StatefulWidget {
  const ShiftHandoverScreen({super.key});

  @override
  State<ShiftHandoverScreen> createState() => _ShiftHandoverScreenState();
}

class _ShiftHandoverScreenState extends State<ShiftHandoverScreen> {
  late final ShiftController _controller;
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  double _difference = 0;

  @override
  void initState() {
    super.initState();
    final user = AuthController().currentUser;
    final branchId = user?.branchId ?? '';
    final userId = user?.id ?? '';
    final workDate = DateTime.now().toIso8601String().substring(0, 10);

    _controller = ShiftController(branchId: branchId);
    _loadHandoverData(userId, workDate);
    _cashController.addListener(_recalc);
  }

  Future<void> _loadHandoverData(String userId, String workDate) async {
    await _controller.loadHandover(userId, workDate);
    if (mounted) setState(() {});
  }

  void _recalc() {
    final double actual = double.tryParse(_cashController.text) ?? 0;
    final systemCash = double.tryParse(
          _controller.handover?.systemCash.replaceAll('đ', '').replaceAll('.', '') ?? '0',
        ) ??
        0;
    _difference = actual - systemCash;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _cashController.dispose();
    _reasonController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sign() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận bàn giao'),
        content: const Text('Bạn có chắc chắn muốn ký xác nhận bàn giao ca?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final user = AuthController().currentUser;
      final actualCash = double.tryParse(_cashController.text) ?? 0;
      final reason = _difference != 0 ? _reasonController.text : null;

      await _controller.signHandover(
        userId: user?.id ?? '',
        workDate: DateTime.now().toIso8601String().substring(0, 10),
        actualCash: actualCash,
        reason: reason,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã ký xác nhận bàn giao')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            final handover = _controller.handover;
            return Column(
              children: [
                const AppHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Bàn giao ca',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Đối soát doanh thu và tiền mặt cuối ca',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 20),
                        if (_controller.isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 80),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text('Đang tải dữ liệu bàn giao...'),
                                ],
                              ),
                            ),
                          )
                        else if (handover == null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 48,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Không có ca nào hôm nay',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Bạn chưa được phân ca hôm nay.\nVui lòng liên hệ quản lý chi nhánh.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          _InfoLine(
                            label: 'Ca hiện tại',
                            value: handover.currentShift,
                          ),
                          _InfoLine(label: 'Thu ngân', value: handover.cashier),
                          _InfoLine(
                            label: 'Số hóa đơn',
                            value: '${handover.invoiceCount}',
                          ),
                          _InfoLine(
                            label: 'Tiền mặt hệ thống',
                            value: handover.systemCash,
                          ),
                          _InfoLine(
                            label: 'Thanh toán QR',
                            value: handover.qrPayment,
                          ),
                          _InfoLine(
                            label: 'Thanh toán thẻ',
                            value: handover.cardPayment,
                          ),
                          _InfoLine(
                            label: 'Tổng doanh thu',
                            value: handover.totalRevenue,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _cashController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Tiền mặt thực tế',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Chênh lệch: ${_difference.toStringAsFixed(0)}đ',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          if (_difference != 0) ...[
                            const SizedBox(height: 12),
                            TextField(
                              controller: _reasonController,
                              decoration: const InputDecoration(
                                labelText: 'Lý do chênh lệch',
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          AppButton(
                            text: 'Ký xác nhận bàn giao',
                            onPressed: _sign,
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

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );
}
