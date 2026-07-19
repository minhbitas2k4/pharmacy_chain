import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_header.dart';
import '../../auth/controllers/auth_controller.dart';
import '../models/inventory_request_model.dart';
import '../controllers/inventory_controller.dart';
import '../widgets/inventory_request_card.dart';
import '../widgets/inventory_review_tabs.dart';

class InventoryReviewScreen extends StatefulWidget {
  const InventoryReviewScreen({super.key});

  @override
  State<InventoryReviewScreen> createState() => _InventoryReviewScreenState();
}

class _InventoryReviewScreenState extends State<InventoryReviewScreen> {
  late final InventoryController _controller;

  @override
  void initState() {
    super.initState();
    final branchId = AuthController().currentUser?.branchId ?? '';
    _controller = InventoryController(branchId: branchId);
    _controller.loadReviewRequests();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _reject(InventoryRequestModel request) async {
    final TextEditingController reasonController = TextEditingController();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Từ chối yêu cầu'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(labelText: 'Lý do'),
        ),
        actions: [
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
      _controller.rejectRequest(request);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã từ chối yêu cầu')));
    }
  }

  Future<void> _approve(InventoryRequestModel request) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duyệt yêu cầu'),
        content: const Text('Xác nhận duyệt yêu cầu này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Duyệt'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _controller.approveRequest(request);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã duyệt yêu cầu')));
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
            final pending = _controller.requests
                .where((r) => r.status == InventoryRequestStatus.pending)
                .toList();
            final approved = _controller.requests
                .where((r) => r.status == InventoryRequestStatus.approved)
                .toList();
            final rejected = _controller.requests
                .where((r) => r.status == InventoryRequestStatus.rejected)
                .toList();
            final list = _controller.selectedReviewTab == 0
                ? pending
                : _controller.selectedReviewTab == 1
                    ? approved
                    : rejected;
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
                          'Duyệt kho',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Phê duyệt yêu cầu nhập/xuất kho',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 20),
                        InventoryReviewTabs(
                          selectedIndex: _controller.selectedReviewTab,
                          onChanged: _controller.selectReviewTab,
                        ),
                        const SizedBox(height: 20),
                        ...list.map(
                          (request) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InventoryRequestCard(
                              request: request,
                              onReject: () => _reject(request),
                              onApprove: () => _approve(request),
                              onView: () =>
                                  ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Mở chi tiết yêu cầu'),
                                ),
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
