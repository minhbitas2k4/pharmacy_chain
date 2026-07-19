import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../controllers/pharmacist_flow_controller.dart';
import '../models/pharmacist_models.dart';
import 'pharmacist_pos_screen.dart';
import 'prescription_management_screen.dart';

class PharmacistDrugLookupScreen extends StatefulWidget {
  const PharmacistDrugLookupScreen({super.key});

  @override
  State<PharmacistDrugLookupScreen> createState() =>
      _PharmacistDrugLookupScreenState();
}

class _PharmacistDrugLookupScreenState
    extends State<PharmacistDrugLookupScreen> {
  late final PharmacistFlowController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = PharmacistFlowController();
    _controller.initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tra cứu thuốc - Dược sĩ'),
        actions: <Widget>[
          AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              return IconButton(
                tooltip: 'Giỏ hàng (${_controller.cart.length})',
                onPressed: () => _openPos(),
                icon: Badge(
                  isLabelVisible: _controller.cart.isNotEmpty,
                  label: Text('${_controller.cart.length}'),
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
              );
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          if (_controller.isLoading && _controller.drugs.isEmpty) {
            return const LoadingView(message: 'Đang tải dữ liệu thuốc...');
          }

          if (_controller.errorMessage != null && _controller.drugs.isEmpty) {
            return ErrorView(
              message: _controller.errorMessage!,
              onRetry: _controller.reloadDrugs,
            );
          }

          final List<PharmacistDrug> drugs = _controller.visibleDrugs;
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: _controller.search,
                  decoration: InputDecoration(
                    labelText: 'Tìm theo tên thuốc, hoạt chất hoặc số lô',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _controller.search('');
                              setState(() {});
                            },
                            icon: const Icon(Icons.clear),
                          ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openPrescription,
                        icon: const Icon(Icons.description_outlined),
                        label: const Text('Tạo đơn thuốc'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _openPos,
                        icon: const Icon(Icons.point_of_sale_outlined),
                        label: Text('Giỏ hàng (${_controller.cart.length})'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (_controller.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: MaterialBanner(
                    content: Text(_controller.errorMessage!),
                    leading: const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.error,
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: _controller.clearError,
                        child: const Text('Đóng'),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _controller.reloadDrugs,
                  child: drugs.isEmpty
                      ? ListView(
                          children: const <Widget>[
                            SizedBox(height: 120),
                            Icon(Icons.medication_outlined, size: 64),
                            SizedBox(height: 12),
                            Center(
                              child: Text('Không tìm thấy thuốc phù hợp.'),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: drugs.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (BuildContext context, int index) {
                            return _DrugCard(
                              drug: drugs[index],
                              onAdd: () => _addToCart(drugs[index]),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _addToCart(PharmacistDrug drug) {
    _controller.addDrugToCart(drug);
    final String? error = _controller.errorMessage;
    if (error != null) {
      _showMessage(error, isError: true);
      return;
    }
    _showMessage('Đã thêm ${drug.name} vào giỏ hàng.');
  }

  void _openPrescription() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PrescriptionManagementScreen(controller: _controller),
      ),
    );
  }

  void _openPos() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PharmacistPosScreen(controller: _controller),
      ),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }
}

class _DrugCard extends StatelessWidget {
  const _DrugCard({required this.drug, required this.onAdd});

  final PharmacistDrug drug;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final String expiryText = drug.expiryDate == null
        ? 'Chưa cập nhật'
        : '${drug.expiryDate!.day.toString().padLeft(2, '0')}/'
              '${drug.expiryDate!.month.toString().padLeft(2, '0')}/'
              '${drug.expiryDate!.year}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CircleAvatar(
                  backgroundColor: AppColors.pharmaMint,
                  child: Icon(Icons.medication, color: AppColors.pharmaGreen),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        drug.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text('Hoạt chất: ${drug.activeIngredient}'),
                    ],
                  ),
                ),
                Text(
                  CurrencyFormatter.format(drug.price),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.pharmaGreen,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _InfoLine(label: 'Liều lượng', value: drug.dosage),
            _InfoLine(label: 'Chỉ định', value: drug.indications),
            _InfoLine(label: 'Vị trí', value: drug.shelfLocation),
            _InfoLine(label: 'Số lô', value: drug.batchNumber),
            _InfoLine(label: 'Hạn dùng', value: expiryText),
            _InfoLine(label: 'Tồn kho', value: '${drug.quantity}'),
            if (drug.prescriptionRequired)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'Thuốc kê đơn',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (!drug.canSell)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  drug.isExpired ? 'Lô thuốc đã hết hạn' : 'Thuốc đã hết hàng',
                  style: const TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: drug.canSell ? onAdd : null,
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Thêm vào giỏ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 88,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? 'Chưa cập nhật' : value)),
        ],
      ),
    );
  }
}
