import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/pharmacist_flow_controller.dart';
import '../models/pharmacist_models.dart';
import 'pharmacist_invoice_screen.dart';

class PharmacistPaymentScreen extends StatefulWidget {
  const PharmacistPaymentScreen({super.key, required this.controller});

  final PharmacistFlowController controller;

  @override
  State<PharmacistPaymentScreen> createState() =>
      _PharmacistPaymentScreenState();
}

class _PharmacistPaymentScreenState extends State<PharmacistPaymentScreen> {
  String _selectedMethod = 'cash';
  bool _vietQrConfirmed = false;
  final TextEditingController _referenceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.loadVietQrConfig();
    });
  }

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
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
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
                _buildVietQrSection(context),
              ],
              if (_selectedMethod != 'cash') ...<Widget>[
                const SizedBox(height: 12),
                TextField(
                  controller: _referenceController,
                  decoration: InputDecoration(
                    labelText: _selectedMethod == 'vietqr'
                        ? 'Mã giao dịch ngân hàng (không bắt buộc khi demo)'
                        : 'Mã giao dịch thẻ',
                    prefixIcon: const Icon(Icons.receipt_long_outlined),
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

  Widget _buildVietQrSection(BuildContext context) {
    final VietQrConfig? config = widget.controller.vietQrConfig;
    final String? imageUrl = widget.controller.vietQrImageUrl;

    if (widget.controller.isLoading && config == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (config == null || !config.isConfigured || imageUrl == null) {
      return Card(
        color: AppColors.warning.withOpacity(0.08),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Row(
                children: <Widget>[
                  Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Chưa cấu hình tài khoản nhận VietQR',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Thêm bank_id, account_no và account_name vào document '
                'branches hiện tại hoặc system_configs/vietqr_payment.',
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () =>
                    widget.controller.loadVietQrConfig(force: true),
                icon: const Icon(Icons.refresh),
                label: const Text('Tải lại cấu hình'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 420),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder:
                    (
                      BuildContext context,
                      Widget child,
                      ImageChunkEvent? progress,
                    ) {
                      if (progress == null) return child;
                      return const SizedBox(
                        height: 260,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                errorBuilder:
                    (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) {
                      return const SizedBox(
                        height: 220,
                        child: Center(
                          child: Text(
                            'Không tải được ảnh VietQR. Kiểm tra Internet và cấu hình ngân hàng.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
              ),
            ),
            const Divider(height: 24),
            _QrInfoRow(label: 'Ngân hàng/BIN', value: config.bankId),
            _QrInfoRow(label: 'Số tài khoản', value: config.accountNo),
            _QrInfoRow(label: 'Chủ tài khoản', value: config.accountName),
            _QrInfoRow(
              label: 'Nội dung',
              value: widget.controller.vietQrTransferContent,
            ),
            _QrInfoRow(
              label: 'Số tiền',
              value: CurrencyFormatter.format(widget.controller.totalAmount),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _vietQrConfirmed,
              onChanged: (bool? value) {
                setState(() {
                  _vietQrConfirmed = value ?? false;
                });
              },
              title: const Text('Đã kiểm tra và nhận được thanh toán'),
              subtitle: const Text(
                'Bản demo xác nhận thủ công; chưa có webhook ngân hàng.',
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
    );
  }

  void _selectMethod(String? value) {
    if (value == null) return;
    setState(() {
      _selectedMethod = value;
      _vietQrConfirmed = false;
      _referenceController.clear();
    });
    if (value == 'vietqr') {
      widget.controller.loadVietQrConfig();
    }
  }

  Future<void> _confirmPayment() async {
    if (_selectedMethod == 'vietqr' && !_vietQrConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng xác nhận đã nhận được thanh toán VietQR.'),
        ),
      );
      return;
    }

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

class _QrInfoRow extends StatelessWidget {
  const _QrInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 105,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}
