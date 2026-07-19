import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/loading_view.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/inventory_controller.dart';
import '../widgets/inventory_summary_card.dart';
import '../widgets/warehouse_alert_card.dart';

class WarehouseAlertScreen extends StatefulWidget {
  const WarehouseAlertScreen({super.key});

  @override
  State<WarehouseAlertScreen> createState() => _WarehouseAlertScreenState();
}

class _WarehouseAlertScreenState extends State<WarehouseAlertScreen> {
  late final InventoryController _controller;

  @override
  void initState() {
    super.initState();
    final branchId = AuthController().currentUser?.branchId ?? '';
    _controller = InventoryController(branchId: branchId);
    _controller.loadWarehouseAlerts();
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
                          'Cảnh báo kho',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Hết hạn & tồn kho tối thiểu toàn hệ thống',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: const <Widget>[
                            InventorySummaryCard(
                              title: 'Sắp hết hạn',
                              value: '23',
                              subtitle: 'Trong 30 ngày',
                              icon: Icons.event_busy_rounded,
                            ),
                            SizedBox(width: 12),
                            InventorySummaryCard(
                              title: 'Tồn kho thấp',
                              value: '41',
                              subtitle: 'Dưới ngưỡng tối thiểu',
                              icon: Icons.warning_amber_rounded,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (_controller.isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 80),
                            child: LoadingView(
                              message: 'Đang tải cảnh báo kho...',
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _controller.alerts.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (BuildContext context, int index) {
                              final alert = _controller.alerts[index];
                              return WarehouseAlertCard(
                                alert: alert,
                                onCreateOrder: () {
                                  Navigator.of(
                                    context,
                                  ).pushNamed(AppRoutes.purchaseOrders);
                                },
                              );
                            },
                          ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.purchaseOrders),
                          child: const Text('+ Tạo đơn nhập'),
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
