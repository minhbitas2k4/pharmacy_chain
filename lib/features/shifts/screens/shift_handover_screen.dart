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
    final branchId = AuthController().currentUser?.branchId ?? '';
    _controller = ShiftController(branchId: branchId);
    _controller.loadHandover();
    _cashController.text = '25000000';
    _cashController.addListener(_recalc);
  }

  void _recalc() {
    final double actual = double.tryParse(_cashController.text) ?? 0;
    _difference = actual - 8500000;
    setState(() {});
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã ký xác nhận bàn giao')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final handover = _controller.handover;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, _) {
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
                        if (handover == null)
                          const SizedBox(
                            height: 120,
                            child: Center(child: CircularProgressIndicator()),
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
