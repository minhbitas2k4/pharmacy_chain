import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_header.dart';
import '../controllers/payment_controller.dart';
// import '../models/cart_item_model.dart';
import '../models/payment_model.dart';
import '../widgets/payment_method_selector.dart';
import '../widgets/payment_summary_card.dart';
import '../widgets/vietqr_placeholder.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.cartTotal,
    // required this.items,
  });

  final double cartTotal;
  // final List<CartItemModel> items;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final PaymentController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PaymentController();
    _controller.cashReceivedController.text = widget.cartTotal.toStringAsFixed(
      0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    await _controller.confirm();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Thanh toán thành công')));
    Navigator.of(context).pushReplacementNamed(AppRoutes.invoices);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
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
                          'Thanh toán',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Xác nhận phương thức thanh toán',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 20),
                        PaymentSummaryCard(total: widget.cartTotal),
                        const SizedBox(height: 16),
                        PaymentMethodSelector(
                          selected: _controller.method,
                          onChanged: _controller.selectMethod,
                        ),
                        const SizedBox(height: 16),
                        if (_controller.method == PaymentMethod.vietqr)
                          const VietQrPlaceholder(),
                        if (_controller.method == PaymentMethod.cash) ...[
                          TextField(
                            controller: _controller.cashReceivedController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Số tiền khách đưa',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tiền thừa: ${_controller.changeFor(widget.cartTotal).toStringAsFixed(0)}đ',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                        const SizedBox(height: 20),
                        AppButton(
                          text: 'Xác nhận thanh toán',
                          isLoading: _controller.isLoading,
                          onPressed: _confirm,
                        ),
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
