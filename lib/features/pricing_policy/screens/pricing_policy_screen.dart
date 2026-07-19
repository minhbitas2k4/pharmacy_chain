import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../controllers/pricing_policy_controller.dart';
import '../models/pricing_policy_model.dart';
import '../widgets/pricing_policy_card.dart';

class PricingPolicyScreen extends StatefulWidget {
  const PricingPolicyScreen({super.key});

  @override
  State<PricingPolicyScreen> createState() => _PricingPolicyScreenState();
}

class _PricingPolicyScreenState extends State<PricingPolicyScreen> {
  late final PricingPolicyController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PricingPolicyController();
    _controller.loadPolicies();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _reject(PricingPolicyModel policy) async {
    final TextEditingController reasonController = TextEditingController();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Từ chối chính sách'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(labelText: 'Lý do từ chối'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    reasonController.dispose();
    if (confirmed == true) {
      _controller.rejectPolicy(policy);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã từ chối chính sách')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            final policies = _controller.policies;
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
                          'Chính sách giá',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Duyệt & điều chỉnh bảng giá thuốc',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {},
                                child: const Text('+ Thêm chính sách'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                child: const Text('Tra cứu'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (_controller.isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 80),
                            child: LoadingView(
                              message: 'Đang tải chính sách...',
                            ),
                          )
                        else if (policies.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 28),
                            child: EmptyView(
                              title: 'Không có chính sách',
                              message: 'Chưa có dữ liệu mock.',
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: policies.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (BuildContext context, int index) {
                              final PricingPolicyModel policy = policies[index];
                              return PricingPolicyCard(
                                policy: policy,
                                onApprove: () {
                                  _controller.approvePolicy(policy);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đã duyệt chính sách'),
                                    ),
                                  );
                                },
                                onReject: () => _reject(policy),
                                onView: () =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Mở chi tiết chính sách'),
                                      ),
                                    ),
                                onEdit: () =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Mở form sửa'),
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
