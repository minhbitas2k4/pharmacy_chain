import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class SupplierFilterBar extends StatelessWidget {
  const SupplierFilterBar({
    super.key,
    required this.onFilter,
    required this.onAdd,
    required this.onSearchChanged,
  });

  final VoidCallback onFilter;
  final VoidCallback onAdd;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton(
                onPressed: onFilter,
                child: const Text('Filter'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: onAdd,
                child: const Text('Thêm NCC'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm nhà cung cấp',
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }
}
