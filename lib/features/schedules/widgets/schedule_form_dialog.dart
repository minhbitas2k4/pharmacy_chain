import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class ScheduleFormDialog extends StatefulWidget {
  const ScheduleFormDialog({
    super.key,
    required this.employees,
    required this.shifts,
    required this.onSave,
    this.initialUserId,
    this.initialShiftId,
    this.initialDate,
    this.initialNotes,
    this.isEdit = false,
  });

  final List<Map<String, dynamic>> employees;
  final List<Map<String, dynamic>> shifts;
  final void Function({
    required String userId,
    required String shiftId,
    required String workDate,
    String? notes,
  }) onSave;
  final String? initialUserId;
  final String? initialShiftId;
  final String? initialDate;
  final String? initialNotes;
  final bool isEdit;

  @override
  State<ScheduleFormDialog> createState() => _ScheduleFormDialogState();
}

class _ScheduleFormDialogState extends State<ScheduleFormDialog> {
  late String? _selectedUserId;
  late String? _selectedShiftId;
  late TextEditingController _dateController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _selectedUserId = widget.initialUserId;
    _selectedShiftId = widget.initialShiftId;
    _dateController = TextEditingController(text: widget.initialDate ?? '');
    _notesController = TextEditingController(text: widget.initialNotes ?? '');
  }

  @override
  void dispose() {
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateController.text.isNotEmpty
          ? DateTime.tryParse(_dateController.text) ?? now
          : now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEdit ? 'Sửa lịch làm việc' : 'Thêm lịch làm việc'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Employee dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedUserId,
              decoration: const InputDecoration(
                labelText: 'Nhân viên *',
                prefixIcon: Icon(Icons.person_outline),
              ),
              items: widget.employees.map((e) {
                return DropdownMenuItem(
                  value: e['uid'] as String?,
                  child: Text(e['displayName'] as String? ?? ''),
                );
              }).toList(),
              onChanged: widget.isEdit
                  ? null
                  : (value) => setState(() => _selectedUserId = value),
            ),
            const SizedBox(height: 16),

            // Shift dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedShiftId,
              decoration: const InputDecoration(
                labelText: 'Ca làm *',
                prefixIcon: Icon(Icons.schedule_outlined),
              ),
              items: widget.shifts.map((s) {
                final name = s['name'] as String? ?? '';
                final start = s['start_time'] as String? ?? '';
                final end = s['end_time'] as String? ?? '';
                return DropdownMenuItem(
                  value: s['id'] as String?,
                  child: Text('$name ($start - $end)'),
                );
              }).toList(),
              onChanged: (value) =>
                  setState(() => _selectedShiftId = value),
            ),
            const SizedBox(height: 16),

            // Date picker
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Ngày làm việc *',
                prefixIcon: const Icon(Icons.calendar_today_outlined),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.edit_calendar),
                  onPressed: _pickDate,
                ),
              ),
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),

            // Notes
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Ghi chú',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_selectedUserId == null ||
                _selectedShiftId == null ||
                _dateController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vui lòng điền đầy đủ thông tin'),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }

            widget.onSave(
              userId: _selectedUserId!,
              shiftId: _selectedShiftId!,
              workDate: _dateController.text,
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
            );
            Navigator.pop(context);
          },
          child: Text(widget.isEdit ? 'Cập nhật' : 'Thêm'),
        ),
      ],
    );
  }
}
