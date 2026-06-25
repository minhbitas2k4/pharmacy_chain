import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';

class ProductSearchPanel extends StatelessWidget {
  const ProductSearchPanel({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
    required this.onScanCode,
  });

  final List<String> suggestions;
  final ValueChanged<String> onSuggestionTap;
  final VoidCallback onScanCode;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TextField(
            decoration: InputDecoration(
              hintText: 'Tìm thuốc hoặc quét mã vạch',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onScanCode, child: const Text('Quét mã')),
          const SizedBox(height: 12),
          ...suggestions
              .map(
                (String item) => ListTile(
                  title: Text(item),
                  onTap: () => onSuggestionTap(item),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
