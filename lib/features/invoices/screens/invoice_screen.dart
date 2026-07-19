import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_header.dart';
import '../controllers/invoice_controller.dart';
import '../widgets/invoice_item_tile.dart';
import '../widgets/invoice_summary_card.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  late final InvoiceController _controller;

  @override
  void initState() {
    super.initState();
    _controller = InvoiceController();
    _controller.loadInvoice();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            final invoice = _controller.invoice;
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
                          'Hóa đơn',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Chi tiết giao dịch hoàn tất',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 20),
                        if (invoice == null)
                          const SizedBox(
                            height: 120,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else ...[
                          Text('Mã hóa đơn: ${invoice.code}'),
                          Text('Chi nhánh: ${invoice.branch}'),
                          Text('Thu ngân: ${invoice.cashier}'),
                          Text('Thời gian: ${invoice.time}'),
                          const SizedBox(height: 16),
                          ...invoice.items.map(
                            (item) => InvoiceItemTile(item: item),
                          ),
                          const SizedBox(height: 16),
                          InvoiceSummaryCard(
                            total: invoice.total,
                            discount: invoice.discount,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Phương thức thanh toán: ${invoice.paymentMethod}',
                          ),
                          const SizedBox(height: 20),
                          AppButton(text: 'In hóa đơn', onPressed: () {}),
                          const SizedBox(height: 12),
                          AppButton(text: 'Gửi SMS/Zalo', onPressed: () {}),
                          const SizedBox(height: 12),
                          AppButton(
                            text: 'Tạo đơn mới',
                            onPressed: () => Navigator.of(
                              context,
                            ).pushReplacementNamed(AppRoutes.pos),
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
