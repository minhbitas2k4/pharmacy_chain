import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../controllers/supplier_controller.dart';
import '../widgets/supplier_card.dart';
import '../widgets/supplier_filter_bar.dart';

class SupplierScreen extends StatefulWidget {
  const SupplierScreen({super.key});

  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
  late final SupplierController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SupplierController();
    _controller.loadSuppliers();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            final suppliers = _controller.suppliers;
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
                          'Quản lý Nhà cung cấp',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Quản lý và đánh giá các nhà cung cấp dược phẩm.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 20),
                        SupplierFilterBar(
                          onFilter: () => _showSnack('Mở bộ lọc nhà cung cấp'),
                          onAdd: () => _showSnack('Mở form thêm NCC'),
                          onSearchChanged: _controller.updateQuery,
                        ),
                        const SizedBox(height: 20),
                        if (_controller.isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 80),
                            child: LoadingView(
                              message: 'Đang tải nhà cung cấp...',
                            ),
                          )
                        else if (suppliers.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 28),
                            child: EmptyView(
                              title: 'Không có nhà cung cấp',
                              message:
                                  'Thử đổi từ khóa tìm kiếm hoặc tải lại dữ liệu mock.',
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: suppliers.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (BuildContext context, int index) {
                              final supplier = suppliers[index];
                              return SupplierCard(
                                supplier: supplier,
                                onMessage: () =>
                                    _showSnack('Message ${supplier.name}'),
                                onCall: () =>
                                    _showSnack('Call ${supplier.contact}'),
                              );
                            },
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
