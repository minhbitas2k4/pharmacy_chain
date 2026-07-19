import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/pharmacist_flow_controller.dart';
import '../models/pharmacist_models.dart';
import 'pharmacist_payment_screen.dart';

class PharmacistPosScreen extends StatelessWidget {
  const PharmacistPosScreen({
    super.key,
    required this.controller,
  });

  final PharmacistFlowController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bán hàng (POS)')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          return Column(
            children: <Widget>[
              if (controller.prescriptionId != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.pharmaMint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Đơn thuốc đã xác minh: ${controller.prescriptionId}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              Expanded(
                child: controller.cart.isEmpty
                    ? const Center(
                        child: Text('Giỏ hàng đang trống. Hãy quay lại chọn thuốc.'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: controller.cart.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (BuildContext context, int index) {
                          final PharmacistCartItem item = controller.cart[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: <Widget>[
                                  const CircleAvatar(
                                    backgroundColor: AppColors.pharmaMint,
                                    child: Icon(
                                      Icons.medication,
                                      color: AppColors.pharmaGreen,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          item.productName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        Text('Lô: ${item.batchNumber}'),
                                        Text(
                                          '${CurrencyFormatter.format(item.unitPrice)} × ${item.quantity}',
                                        ),
                                        Text(
                                          CurrencyFormatter.format(item.lineTotal),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.pharmaGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          IconButton(
                                            onPressed: () => controller
                                                .decreaseQuantity(item.inventoryId),
                                            icon: const Icon(
                                              Icons.remove_circle_outline,
                                            ),
                                          ),
                                          Text(
                                            '${item.quantity}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () => controller
                                                .increaseQuantity(item.inventoryId),
                                            icon: const Icon(
                                              Icons.add_circle_outline,
                                            ),
                                          ),
                                        ],
                                      ),
                                      TextButton.icon(
                                        onPressed: () => controller
                                            .removeCartItem(item.inventoryId),
                                        icon: const Icon(Icons.delete_outline),
                                        label: const Text('Xóa'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Column(
                  children: <Widget>[
                    _SummaryRow(
                      label: 'Tạm tính',
                      value: CurrencyFormatter.format(controller.subtotal),
                    ),
                    _SummaryRow(
                      label: 'Giảm giá',
                      value: CurrencyFormatter.format(controller.discountAmount),
                    ),
                    const Divider(),
                    _SummaryRow(
                      label: 'Tổng thanh toán',
                      value: CurrencyFormatter.format(controller.totalAmount),
                      emphasized: true,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: controller.cart.length < 2
                                ? null
                                : () => _checkInteractions(context),
                            icon: const Icon(Icons.health_and_safety_outlined),
                            label: const Text('Tương tác'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton(
                            text: 'Thanh toán',
                            isLoading: controller.isLoading,
                            onPressed: controller.cart.isEmpty
                                ? null
                                : () => _createOrder(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _checkInteractions(BuildContext context) async {
    final List<DrugInteractionWarning> warnings =
        await controller.checkCartInteractions();
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Kiểm tra tương tác thuốc'),
        content: warnings.isEmpty
            ? const Text('Không phát hiện tương tác thuốc trong dữ liệu hiện có.')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: warnings.length,
                  itemBuilder: (BuildContext context, int index) {
                    final DrugInteractionWarning warning = warnings[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        warning.isSevere
                            ? Icons.dangerous_outlined
                            : Icons.warning_amber_rounded,
                        color: warning.isSevere
                            ? AppColors.error
                            : AppColors.warning,
                      ),
                      title: Text(
                        '${warning.ingredientA} + ${warning.ingredientB}',
                      ),
                      subtitle: Text(
                        '[${warning.severity}] ${warning.message}',
                      ),
                    );
                  },
                ),
              ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Future<void> _createOrder(BuildContext context) async {
    final String? orderId = await controller.createOrder();
    if (!context.mounted) return;

    if (orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Không thể tạo đơn hàng.'),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PharmacistPaymentScreen(controller: controller),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = emphasized
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.pharmaGreen,
          )
        : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
