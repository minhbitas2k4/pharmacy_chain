import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../controllers/drug_controller.dart';
import '../models/drug_model.dart';
import '../widgets/drug_lookup_card.dart';

class DrugLookupScreen extends StatefulWidget {
  const DrugLookupScreen({super.key});

  @override
  State<DrugLookupScreen> createState() => _DrugLookupScreenState();
}

class _DrugLookupScreenState extends State<DrugLookupScreen> {
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
    final List<DrugModel> results = _controller.drugs;
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
                          'Tra cứu thuốc',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tìm kiếm nhanh để tư vấn khách hàng',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          onChanged: _controller.updateQuery,
                          decoration: const InputDecoration(
                            hintText: 'Tìm kiếm thuốc / hoạt chất / ...',
                            prefixIcon: Icon(Icons.search_rounded),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_controller.isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 80),
                            child: LoadingView(message: 'Đang tải thuốc...'),
                          )
                        else if (results.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 28),
                            child: EmptyView(
                              title: 'Không có thuốc',
                              message: 'Thử tìm từ khóa khác.',
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: results.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (BuildContext context, int index) {
                              return DrugLookupCard(
                                drug: results[index],
                                onAddToCart: () =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Đã thêm vào đơn'),
                                      ),
                                    ),
                                onInteraction: () => showDialog<void>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text(
                                      'Cảnh báo tương tác thuốc',
                                    ),
                                    content: const Text(
                                      'Đây là cảnh báo tương tác thuốc mẫu.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Đóng'),
                                      ),
                                    ],
                                  ),
                                ),
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
