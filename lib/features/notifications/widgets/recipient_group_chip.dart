import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class RecipientGroupChip extends StatelessWidget {
  const RecipientGroupChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.pharmaGreen,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textSecondary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
