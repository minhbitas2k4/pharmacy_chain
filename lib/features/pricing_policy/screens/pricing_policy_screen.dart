import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../controllers/pricing_policy_controller.dart';
import '../models/pricing_policy_model.dart';
import '../models/price_adjustment_model.dart';
import '../widgets/pricing_policy_card.dart';

class PricingPolicyScreen extends StatefulWidget {
  const PricingPolicyScreen({super.key});

  @override
  State<PricingPolicyScreen> createState() => _PricingPolicyScreenState();
}

class _PricingPolicyScreenState extends State<PricingPolicyScreen> {
  late final PricingPolicyController _controller;
  int _selectedTab = 0; // 0 = General policies, 1 = Adjustment requests

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
      await _controller.rejectPolicy(policy);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã từ chối chính sách')));
      }
    }
  }

  Future<void> _showAddPolicyDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final storeCountController = TextEditingController(text: 'Tất cả chi nhánh');
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Thêm chính sách giá mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Tên chính sách (ví dụ: Bảng giá Hè)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subtitleController,
                decoration: const InputDecoration(labelText: 'Mô tả chính sách / khuyến mãi'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: storeCountController,
                decoration: const InputDecoration(labelText: 'Áp dụng cho (ví dụ: Chi nhánh Quận 1)'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tạo mới'),
          ),
        ],
      ),
    );

    if (confirmed == true && titleController.text.isNotEmpty) {
      final newPolicy = PricingPolicyModel(
        title: titleController.text.trim(),
        subtitle: subtitleController.text.trim(),
        status: PricingPolicyStatus.pending,
        storeCount: storeCountController.text.trim(),
      );
      await _controller.addPolicy(newPolicy);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm chính sách mới thành công')),
        );
      }
    }
    titleController.dispose();
    subtitleController.dispose();
    storeCountController.dispose();
  }

  Future<void> _handleApproveAdjustment(PriceAdjustmentModel adj) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Phê duyệt điều chỉnh giá'),
        content: Text('Bạn có chắc chắn muốn duyệt điều chỉnh giá cho thuốc ${adj.productName} thành ${adj.newPrice}?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.pharmaGreen),
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _controller.approvePriceAdjustment(adj);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã phê duyệt điều chỉnh giá')),
        );
      }
    }
  }

  Future<void> _handleRejectAdjustment(PriceAdjustmentModel adj) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Từ chối điều chỉnh giá'),
        content: Text('Bạn có chắc chắn muốn từ chối yêu cầu điều chỉnh giá của chi nhánh?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Xác nhận từ chối'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _controller.rejectPriceAdjustment(adj);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã từ chối điều chỉnh giá')),
        );
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    final String hour = dateTime.hour.toString().padLeft(2, '0');
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  Widget _buildAdjustmentCard(PriceAdjustmentModel adj) {
    final isPending = adj.status == 'pending';
    final isApproved = adj.status == 'approved';
    final isRejected = adj.status == 'rejected';

    Color statusColor;
    Color statusBg;
    String statusLabel;

    if (isApproved) {
      statusColor = AppColors.success;
      statusBg = AppColors.success.withOpacity(0.1);
      statusLabel = 'Đã duyệt';
    } else if (isRejected) {
      statusColor = AppColors.error;
      statusBg = AppColors.error.withOpacity(0.1);
      statusLabel = 'Từ chối';
    } else {
      statusColor = AppColors.warning;
      statusBg = AppColors.warning.withOpacity(0.1);
      statusLabel = 'Chờ duyệt';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  adj.branchName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (adj.createdAt != null) ...[
            const SizedBox(height: 4),
            Text(
              _formatTime(adj.createdAt!),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
          const Divider(height: 20, thickness: 1, color: AppColors.border),
          Text(
            adj.productName,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: AppColors.pharmaDarkGreen,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Giá cũ', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  Text(
                    adj.oldPrice,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.arrow_forward_rounded, color: AppColors.textSecondary, size: 18),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Giá đề xuất', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  Text(
                    adj.newPrice,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Lý do: ${adj.reason}',
              style: const TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (isPending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleRejectAdjustment(adj),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Từ chối'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleApproveAdjustment(adj),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pharmaGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Duyệt'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
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
            final adjustments = _controller.adjustments;

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
                          'Bảng giá & Điều chỉnh',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Duyệt chính sách giá chung & điều chỉnh giá từ chi nhánh',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        // Tab selector
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _selectedTab = 0),
                                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _selectedTab == 0 ? AppColors.pharmaMint : Colors.transparent,
                                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(13)),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Chính sách chung',
                                      style: TextStyle(
                                        color: _selectedTab == 0 ? AppColors.pharmaGreen : AppColors.textSecondary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _selectedTab = 1),
                                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(14)),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _selectedTab == 1 ? AppColors.pharmaMint : Colors.transparent,
                                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(13)),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Yêu cầu điều chỉnh',
                                      style: TextStyle(
                                        color: _selectedTab == 1 ? AppColors.pharmaGreen : AppColors.textSecondary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        if (_selectedTab == 0) ...[
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: const <Widget>[
                              Chip(label: Text('Áp dụng toàn hệ thống')),
                              Chip(label: Text('Nhóm chi nhánh ưu tiên')),
                              Chip(label: Text('Khuyến mãi quầy')),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _showAddPolicyDialog(context),
                                  child: const Text('+ Thêm chính sách'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Tra cứu chính sách theo chi nhánh')),
                                  ),
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
                                message: 'Chưa có chính sách chung nào.',
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: policies.length,
                              separatorBuilder: (_, _) =>
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
                        ] else ...[
                          if (_controller.isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 80),
                              child: LoadingView(
                                message: 'Đang tải yêu cầu điều chỉnh...',
                              ),
                            )
                          else if (adjustments.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 28),
                              child: EmptyView(
                                title: 'Không có yêu cầu',
                                message: 'Chưa có yêu cầu điều chỉnh giá nào.',
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: adjustments.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (BuildContext context, int index) {
                                return _buildAdjustmentCard(adjustments[index]);
                              },
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
