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

  Future<void> _showAddDrugDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final activeIngredientController = TextEditingController();
    final strengthController = TextEditingController();
    final dosageFormController = TextEditingController();
    final packagingController = TextEditingController(text: 'Hộp 10 vỉ x 10 viên');
    final priceController = TextEditingController(text: '100.000đ');
    DrugFilter filter = DrugFilter.vitamin;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => AlertDialog(
          title: const Text('Thêm thuốc mới'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Tên thuốc (ví dụ: Paracetamol 500mg)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: activeIngredientController,
                  decoration: const InputDecoration(labelText: 'Hoạt chất (ví dụ: Paracetamol)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: strengthController,
                  decoration: const InputDecoration(labelText: 'Hàm lượng (ví dụ: 500mg)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dosageFormController,
                  decoration: const InputDecoration(labelText: 'Dạng bào chế (ví dụ: Viên nén)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: packagingController,
                  decoration: const InputDecoration(labelText: 'Quy cách đóng gói'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Giá bán'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<DrugFilter>(
                  value: filter,
                  decoration: const InputDecoration(labelText: 'Phân loại'),
                  items: DrugFilter.values
                      .where((f) => f != DrugFilter.all)
                      .map((f) => DropdownMenuItem(
                            value: f,
                            child: Text(f.label),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        filter = val;
                      });
                    }
                  },
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
      ),
    );

    if (confirmed == true && nameController.text.isNotEmpty) {
      final newDrug = DrugModel(
        name: nameController.text.trim(),
        activeIngredient: activeIngredientController.text.trim(),
        strength: strengthController.text.trim(),
        dosageForm: dosageFormController.text.trim(),
        packaging: packagingController.text.trim(),
        price: priceController.text.trim(),
        filter: filter,
      );
      await _controller.addDrug(newDrug);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm thuốc mới thành công')),
        );
      }
    }

    nameController.dispose();
    activeIngredientController.dispose();
    strengthController.dispose();
    dosageFormController.dispose();
    packagingController.dispose();
    priceController.dispose();
  }

  Future<void> _showEditDrugDialog(BuildContext context, DrugModel drug) async {
    final nameController = TextEditingController(text: drug.name);
    final activeIngredientController = TextEditingController(text: drug.activeIngredient);
    final strengthController = TextEditingController(text: drug.strength);
    final dosageFormController = TextEditingController(text: drug.dosageForm);
    final packagingController = TextEditingController(text: drug.packaging);
    final priceController = TextEditingController(text: drug.price);
    DrugFilter filter = drug.filter;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => AlertDialog(
          title: const Text('Sửa thông tin thuốc'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Tên thuốc'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: activeIngredientController,
                  decoration: const InputDecoration(labelText: 'Hoạt chất'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: strengthController,
                  decoration: const InputDecoration(labelText: 'Hàm lượng'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dosageFormController,
                  decoration: const InputDecoration(labelText: 'Dạng bào chế'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: packagingController,
                  decoration: const InputDecoration(labelText: 'Quy cách đóng gói'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Giá bán'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<DrugFilter>(
                  value: filter,
                  decoration: const InputDecoration(labelText: 'Phân loại'),
                  items: DrugFilter.values
                      .where((f) => f != DrugFilter.all)
                      .map((f) => DropdownMenuItem(
                            value: f,
                            child: Text(f.label),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        filter = val;
                      });
                    }
                  },
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
              child: const Text('Cập nhật'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && nameController.text.isNotEmpty) {
      final updatedDrug = drug.copyWith(
        name: nameController.text.trim(),
        activeIngredient: activeIngredientController.text.trim(),
        strength: strengthController.text.trim(),
        dosageForm: dosageFormController.text.trim(),
        packaging: packagingController.text.trim(),
        price: priceController.text.trim(),
        filter: filter,
      );
      await _controller.updateDrug(updatedDrug);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật thông tin thuốc')),
        );
      }
    }

    nameController.dispose();
    activeIngredientController.dispose();
    strengthController.dispose();
    dosageFormController.dispose();
    packagingController.dispose();
    priceController.dispose();
  }

  Future<void> _showDeleteConfirmation(BuildContext context, DrugModel drug) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Xác nhận xóa thuốc'),
        content: Text('Bạn có chắc chắn muốn xóa thuốc "${drug.name}" khỏi danh mục dùng chung? Hành động này không thể hoàn tác.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && drug.id != null) {
      await _controller.deleteDrug(drug.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa thuốc khỏi danh mục')),
        );
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
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (BuildContext context, int index) {
                              final drug = drugs[index];
                              return DrugCatalogCard(
                                drug: drug,
                                onEdit: () => _showEditDrugDialog(context, drug),
                                onDelete: () => _showDeleteConfirmation(context, drug),
                              );
                            },
                          ),
                        const SizedBox(height: 20),
                        AppButton(
                          text: '+ Thêm thuốc mới',
                          onPressed: () => _showAddDrugDialog(context),
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
