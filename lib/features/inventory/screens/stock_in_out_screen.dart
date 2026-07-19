import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_header.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/inventory_controller.dart';
import '../widgets/barcode_scan_box.dart';
import '../widgets/stock_progress_card.dart';
import '../widgets/stock_verification_item_tile.dart';

class StockInOutScreen extends StatefulWidget {
  const StockInOutScreen({super.key});

  @override
  State<StockInOutScreen> createState() => _StockInOutScreenState();
}

class _StockInOutScreenState extends State<StockInOutScreen> {
  late final InventoryController _controller;

  @override
  void initState() {
    super.initState();
    final branchId = AuthController().currentUser?.branchId ?? '';
    _controller = InventoryController(branchId: branchId);
    _controller.loadStockVerification();
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
                          'Nhận / Xuất kho',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Quét barcode xác nhận hàng hóa',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 20),
                        BarcodeScanBox(onTap: _controller.scanNextItem),
                        const SizedBox(height: 16),
                        StockProgressCard(
                          current: _controller.completedScanCount,
                          total: _controller.totalScanCount,
                        ),
                        const SizedBox(height: 16),
                        ..._controller.stockItems.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: StockVerificationItemTile(item: item),
                          ),
                        ),
                        const SizedBox(height: 20),
                        AppButton(
                          text: 'Xác nhận hoàn tất',
                          onPressed: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Đã xác nhận hoàn tất kiểm kho',
                                  ),
                                ),
                              ),
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
