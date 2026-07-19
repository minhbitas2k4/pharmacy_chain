import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../controllers/pharmacist_flow_controller.dart';
import '../models/pharmacist_models.dart';

class PharmacistInvoiceScreen extends StatefulWidget {
  const PharmacistInvoiceScreen({super.key, required this.controller});

  final PharmacistFlowController controller;

  @override
  State<PharmacistInvoiceScreen> createState() =>
      _PharmacistInvoiceScreenState();
}

class _PharmacistInvoiceScreenState extends State<PharmacistInvoiceScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.loadInvoice();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hóa đơn'),
        automaticallyImplyLeading: false,
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (BuildContext context, Widget? child) {
          if (widget.controller.isLoading &&
              widget.controller.invoice == null) {
            return const LoadingView(message: 'Đang tạo hóa đơn...');
          }

          final PharmacistInvoice? invoice = widget.controller.invoice;
          if (invoice == null) {
            return ErrorView(
              message:
                  widget.controller.errorMessage ?? 'Không thể tải hóa đơn.',
              onRetry: widget.controller.loadInvoice,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      const Icon(
                        Icons.check_circle,
                        size: 64,
                        color: AppColors.success,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Thanh toán thành công',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text('Mã hóa đơn: ${invoice.invoiceNumber}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _InfoRow(label: 'Chi nhánh', value: invoice.branchName),
                      _InfoRow(label: 'Dược sĩ', value: invoice.pharmacistName),
                      _InfoRow(
                        label: 'Thời gian',
                        value:
                            '${invoice.issuedAt.day.toString().padLeft(2, '0')}/'
                            '${invoice.issuedAt.month.toString().padLeft(2, '0')}/'
                            '${invoice.issuedAt.year} '
                            '${invoice.issuedAt.hour.toString().padLeft(2, '0')}:'
                            '${invoice.issuedAt.minute.toString().padLeft(2, '0')}',
                      ),
                      _InfoRow(
                        label: 'Thanh toán',
                        value: invoice.paymentMethod.toUpperCase(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Chi tiết sản phẩm',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ...invoice.lines.map(
                (PharmacistInvoiceLine line) => Card(
                  child: ListTile(
                    title: Text(line.productName),
                    subtitle: Text(
                      'Lô ${line.batchNumber} • ${line.quantity} × '
                      '${CurrencyFormatter.format(line.unitPrice)}',
                    ),
                    trailing: Text(
                      CurrencyFormatter.format(line.lineTotal),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: <Widget>[
                      _MoneyRow(label: 'Tạm tính', amount: invoice.subtotal),
                      _MoneyRow(
                        label: 'Giảm giá',
                        amount: invoice.discountAmount,
                      ),
                      const Divider(),
                      _MoneyRow(
                        label: 'Tổng cộng',
                        amount: invoice.totalAmount,
                        emphasized: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _showDemoMessage('Chức năng in đang là demo.'),
                icon: const Icon(Icons.print_outlined),
                label: const Text('In hóa đơn'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () =>
                    _showDemoMessage('Chức năng gửi SMS/Zalo đang là demo.'),
                icon: const Icon(Icons.send_outlined),
                label: const Text('Gửi SMS/Zalo'),
              ),
              const SizedBox(height: 10),
              AppButton(text: 'Tạo đơn mới', onPressed: _createNewOrder),
            ],
          );
        },
      ),
    );
  }

  Future<void> _createNewOrder() async {
    await widget.controller.resetTransaction();
    if (!mounted) return;
    Navigator.of(context).popUntil(
      (Route<dynamic> route) =>
          route.settings.name == AppRoutes.drugLookup || route.isFirst,
    );
  }

  void _showDemoMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({
    required this.label,
    required this.amount,
    this.emphasized = false,
  });

  final String label;
  final double amount;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = emphasized
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.pharmaGreen,
            fontWeight: FontWeight.w800,
          )
        : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label, style: style)),
          Text(CurrencyFormatter.format(amount), style: style),
        ],
      ),
    );
  }
}
