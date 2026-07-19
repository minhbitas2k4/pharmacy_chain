import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../controllers/drug_controller.dart';
import '../models/drug_model.dart';
import '../widgets/drug_catalog_card.dart';
import '../widgets/drug_filter_tabs.dart';
import '../widgets/drug_search_box.dart';

class DrugCatalogScreen extends StatefulWidget {
  const DrugCatalogScreen({super.key});

  @override
  State<DrugCatalogScreen> createState() => _DrugCatalogScreenState();
}

class _DrugCatalogScreenState extends State<DrugCatalogScreen> {
  late final DrugController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DrugController();
    _controller.loadDrugs();
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
            final drugs = _controller.drugs;
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
                          'Danh mục thuốc',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tra cứu & cập nhật danh mục dùng chung',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 20),
                        DrugSearchBox(onChanged: _controller.updateQuery),
                        const SizedBox(height: 12),
                        DrugFilterTabs(
                          selectedFilter: _controller.selectedFilter,
                          onChanged: _controller.selectFilter,
                        ),
                        const SizedBox(height: 20),
                        if (_controller.isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 80),
                            child: LoadingView(
                              message: 'Đang tải danh mục thuốc...',
                            ),
                          )
                        else if (drugs.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 28),
                            child: EmptyView(
                              title: 'Không có thuốc',
                              message: 'Thử đổi từ khóa tìm kiếm hoặc bộ lọc.',
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: drugs.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (BuildContext context, int index) {
                              return DrugCatalogCard(
                                drug: drugs[index],
                                onUpdate: () =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Đã cập nhật ${drugs[index].name}',
                                        ),
                                      ),
                                    ),
                              );
                            },
                          ),
                        const SizedBox(height: 20),
                        AppButton(
                          text: '+ Thêm thuốc mới',
                          onPressed: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Mở form thêm thuốc mới'),
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
