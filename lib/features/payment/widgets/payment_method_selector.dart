import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/payment_model.dart';

class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: PaymentMethod.values.map((PaymentMethod method) {
        final bool isSelected = selected == method;
        return ChoiceChip(
          label: Text(method.label),
          selected: isSelected,
          onSelected: (_) => onChanged(method),
          selectedColor: AppColors.pharmaGreen,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        );
      }).toList(),
    );
  }
}
