import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../controllers/purchase_order_controller.dart';
import '../models/purchase_order_summary_model.dart';
import '../widgets/purchase_status_card.dart';

class PurchaseOrderScreen extends StatefulWidget {
  const PurchaseOrderScreen({super.key});

  @override
  State<PurchaseOrderScreen> createState() => _PurchaseOrderScreenState();
}

class _PurchaseOrderScreenState extends State<PurchaseOrderScreen> {
  late final PurchaseOrderController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PurchaseOrderController();
    _controller.loadSummary();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onCardTap(String title) {
    _showSnackBar('Mở danh sách $title');
  }

  void _createRequest() {
    _showSnackBar('Đã mở form tạo yêu cầu');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            final PurchaseOrderSummaryModel? summary = _controller.summary;

            return Column(
              children: <Widget>[
                const AppHeader(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _controller.loadSummary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            'Quản lý Nhập hàng',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Theo dõi và xét duyệt đơn yêu cầu mua hàng',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 18),
                          AppButton(
                            text: 'Tạo yêu cầu',
                            onPressed: _createRequest,
                            isLoading: _controller.isLoading && summary == null,
                          ),
                          const SizedBox(height: 20),
                          if (_controller.isLoading && summary == null)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 80),
                              child: LoadingView(
                                message: 'Đang tải nhập hàng...',
                              ),
                            )
                          else if (_controller.errorMessage != null &&
                              (summary == null || summary.isEmpty))
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 28),
                              child: ErrorView(
                                message: _controller.errorMessage!,
                                onRetry: _controller.loadSummary,
                              ),
                            )
                          else if (summary == null || summary.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 28),
                              child: EmptyView(
                                title: 'Chưa có dữ liệu nhập hàng',
                                message:
                                    'Hiện tại chưa có đơn yêu cầu nào để hiển thị.',
                                actionLabel: 'Tải lại',
                                onActionPressed: _controller.loadSummary,
                              ),
                            )
                          else ...<Widget>[
                            ...summary.statusCards.map((
                              PurchaseOrderStatusModel item,
                            ) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: PurchaseStatusCard(
                                  item: item,
                                  onTap: () => _onCardTap(item.title),
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
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
