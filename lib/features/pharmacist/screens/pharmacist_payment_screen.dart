import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/pharmacist_flow_controller.dart';
import 'pharmacist_invoice_screen.dart';

class PharmacistPaymentScreen extends StatefulWidget {
  const PharmacistPaymentScreen({
    super.key,
    required this.controller,
  });

  final PharmacistFlowController controller;

  @override
  State<PharmacistPaymentScreen> createState() =>
      _PharmacistPaymentScreenState();
}

class _PharmacistPaymentScreenState extends State<PharmacistPaymentScreen> {
  String _selectedMethod = 'cash';
  final TextEditingController _referenceController = TextEditingController();

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (BuildContext context, Widget? child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      const Icon(
                        Icons.payments_outlined,
                        size: 48,
                        color: AppColors.pharmaGreen,
                      ),
                      const SizedBox(height: 12),
                      const Text('Tổng tiền cần thanh toán'),
                      const SizedBox(height: 6),
                      Text(
                        CurrencyFormatter.format(widget.controller.totalAmount),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.pharmaGreen,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Phương thức thanh toán',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              _PaymentTile(
                value: 'cash',
                groupValue: _selectedMethod,
                icon: Icons.money,
                title: 'Tiền mặt',
                onChanged: _selectMethod,
              ),
              _PaymentTile(
                value: 'card',
                groupValue: _selectedMethod,
                icon: Icons.credit_card,
                title: 'Thẻ ngân hàng',
                onChanged: _selectMethod,
              ),
              _PaymentTile(
                value: 'vietqr',
                groupValue: _selectedMethod,
                icon: Icons.qr_code_2,
                title: 'VietQR',
                onChanged: _selectMethod,
              ),
              if (_selectedMethod == 'vietqr') ...<Widget>[
                const SizedBox(height: 12),
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.qr_code_2, size: 110),
                        Text('QR demo - chưa tích hợp webhook ngân hàng'),
                      ],
                    ),
                  ),
                ),
              ],
              if (_selectedMethod != 'cash') ...<Widget>[
                const SizedBox(height: 12),
                TextField(
                  controller: _referenceController,
                  decoration: const InputDecoration(
                    labelText: 'Mã giao dịch (không bắt buộc khi demo)',
                    prefixIcon: Icon(Icons.receipt_long_outlined),
                  ),
                ),
              ],
              if (widget.controller.errorMessage != null) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  widget.controller.errorMessage!,
                  style: const TextStyle(color: AppColors.error),
                ),
              ],
              const SizedBox(height: 24),
              AppButton(
                text: 'Xác nhận thanh toán',
                isLoading: widget.controller.isLoading,
                onPressed: _confirmPayment,
              ),
            ],
          );
        },
      ),
    );
  }

  void _selectMethod(String? value) {
    if (value == null) return;
    setState(() {
      _selectedMethod = value;
      _referenceController.clear();
    });
  }

  Future<void> _confirmPayment() async {
    final bool success = await widget.controller.pay(
      paymentMethod: _selectedMethod,
      transactionReference: _referenceController.text,
    );
    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.controller.errorMessage ?? 'Thanh toán thất bại.',
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => PharmacistInvoiceScreen(controller: widget.controller),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.value,
    required this.groupValue,
    required this.icon,
    required this.title,
    required this.onChanged,
  });

  final String value;
  final String groupValue;
  final IconData icon;
  final String title;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: RadioListTile<String>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        secondary: Icon(icon, color: AppColors.pharmaGreen),
        title: Text(title),
      ),
    );
  }
}
