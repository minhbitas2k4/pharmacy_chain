import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/pharmacist_flow_controller.dart';
import '../models/pharmacist_models.dart';
import 'pharmacist_pos_screen.dart';

class PrescriptionManagementScreen extends StatefulWidget {
  const PrescriptionManagementScreen({
    super.key,
    required this.controller,
  });

  final PharmacistFlowController controller;

  @override
  State<PrescriptionManagementScreen> createState() =>
      _PrescriptionManagementScreenState();
}

class _PrescriptionManagementScreenState
    extends State<PrescriptionManagementScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _patientPhoneController = TextEditingController();
  final TextEditingController _doctorNameController = TextEditingController();

  @override
  void dispose() {
    _patientNameController.dispose();
    _patientPhoneController.dispose();
    _doctorNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý đơn thuốc')),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (BuildContext context, Widget? child) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Text(
                  'Thông tin bệnh nhân',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _patientNameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên bệnh nhân *',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (String? value) =>
                      value == null || value.trim().isEmpty
                      ? 'Vui lòng nhập tên bệnh nhân'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _patientPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _doctorNameController,
                  decoration: const InputDecoration(
                    labelText: 'Bác sĩ kê đơn',
                    prefixIcon: Icon(Icons.medical_services_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Thuốc trong đơn (${widget.controller.prescriptionLines.length})',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: _showDrugPicker,
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm thuốc'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (widget.controller.prescriptionLines.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text('Chưa có thuốc trong đơn.'),
                      ),
                    ),
                  )
                else
                  ...List<Widget>.generate(
                    widget.controller.prescriptionLines.length,
                    (int index) {
                      final PrescriptionLine line =
                          widget.controller.prescriptionLines[index];
                      return _PrescriptionLineCard(
                        line: line,
                        onEdit: () => _editLine(index, line),
                        onDelete: () =>
                            widget.controller.removePrescriptionLine(index),
                      );
                    },
                  ),
                if (widget.controller.errorMessage != null) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    widget.controller.errorMessage!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: widget.controller.prescriptionLines.length < 2
                      ? null
                      : _checkInteractions,
                  icon: const Icon(Icons.health_and_safety_outlined),
                  label: const Text('Kiểm tra tương tác thuốc'),
                ),
                const SizedBox(height: 12),
                AppButton(
                  text: 'Lưu và xác minh đơn thuốc',
                  isLoading: widget.controller.isLoading,
                  onPressed: _savePrescription,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showDrugPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.72,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Chọn thuốc',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.controller.drugs.length,
                    itemBuilder: (BuildContext context, int index) {
                      final PharmacistDrug drug =
                          widget.controller.drugs[index];
                      return ListTile(
                        enabled: drug.canSell,
                        leading: const Icon(Icons.medication_outlined),
                        title: Text(drug.name),
                        subtitle: Text(
                          '${drug.activeIngredient} • Tồn ${drug.quantity} • Lô ${drug.batchNumber}',
                        ),
                        trailing: const Icon(Icons.add_circle_outline),
                        onTap: () {
                          widget.controller.addPrescriptionDrug(drug);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _editLine(int index, PrescriptionLine line) async {
    final TextEditingController dosageController = TextEditingController(
      text: line.dosage,
    );
    final TextEditingController frequencyController = TextEditingController(
      text: line.frequency,
    );
    final TextEditingController durationController = TextEditingController(
      text: line.duration,
    );
    final TextEditingController quantityController = TextEditingController(
      text: '${line.quantity}',
    );
    final TextEditingController instructionsController = TextEditingController(
      text: line.instructions,
    );

    final PrescriptionLine? updated = await showDialog<PrescriptionLine>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(line.productName),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: dosageController,
                  decoration: const InputDecoration(labelText: 'Liều dùng'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: frequencyController,
                  decoration: const InputDecoration(labelText: 'Tần suất'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(labelText: 'Thời gian dùng'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Số lượng (tối đa ${line.availableQuantity})',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: instructionsController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Hướng dẫn'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                final int? quantity = int.tryParse(quantityController.text);
                if (quantity == null ||
                    quantity <= 0 ||
                    quantity > line.availableQuantity) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Số lượng không hợp lệ.')),
                  );
                  return;
                }
                Navigator.pop(
                  context,
                  line.copyWith(
                    dosage: dosageController.text.trim(),
                    frequency: frequencyController.text.trim(),
                    duration: durationController.text.trim(),
                    quantity: quantity,
                    instructions: instructionsController.text.trim(),
                  ),
                );
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );

    dosageController.dispose();
    frequencyController.dispose();
    durationController.dispose();
    quantityController.dispose();
    instructionsController.dispose();

    if (updated != null) {
      widget.controller.updatePrescriptionLine(index, updated);
    }
  }

  Future<void> _checkInteractions() async {
    final List<DrugInteractionWarning> warnings =
        await widget.controller.checkPrescriptionInteractions();
    if (!mounted) return;
    _showInteractionDialog(warnings);
  }

  Future<void> _savePrescription() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final String? prescriptionId = await widget.controller.savePrescription(
      patientName: _patientNameController.text,
      patientPhone: _patientPhoneController.text,
      doctorName: _doctorNameController.text,
    );
    if (!mounted) return;

    if (prescriptionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.controller.errorMessage ?? 'Không thể lưu đơn thuốc.',
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => PharmacistPosScreen(controller: widget.controller),
      ),
    );
  }

  void _showInteractionDialog(List<DrugInteractionWarning> warnings) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kết quả kiểm tra tương tác'),
          content: warnings.isEmpty
              ? const Text('Không phát hiện tương tác thuốc trong dữ liệu hiện có.')
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: warnings.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (BuildContext context, int index) {
                      final DrugInteractionWarning warning = warnings[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          warning.isSevere
                              ? Icons.dangerous_outlined
                              : Icons.warning_amber_rounded,
                          color: warning.isSevere
                              ? AppColors.error
                              : AppColors.warning,
                        ),
                        title: Text(
                          '${warning.ingredientA} + ${warning.ingredientB}',
                        ),
                        subtitle: Text(
                          '[${warning.severity}] ${warning.message}',
                        ),
                      );
                    },
                  ),
                ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }
}

class _PrescriptionLineCard extends StatelessWidget {
  const _PrescriptionLineCard({
    required this.line,
    required this.onEdit,
    required this.onDelete,
  });

  final PrescriptionLine line;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    line.productName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(onPressed: onEdit, icon: const Icon(Icons.edit)),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                ),
              ],
            ),
            Text('Liều: ${line.dosage}'),
            Text('Tần suất: ${line.frequency}'),
            Text('Thời gian: ${line.duration.isEmpty ? '-' : line.duration}'),
            Text('Số lượng: ${line.quantity}'),
            Text(
              'Hướng dẫn: ${line.instructions.isEmpty ? '-' : line.instructions}',
            ),
          ],
        ),
      ),
    );
  }
}
