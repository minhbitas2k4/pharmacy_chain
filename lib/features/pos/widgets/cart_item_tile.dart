import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../models/cart_item_model.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  final CartItemModel item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(onPressed: onRemove, icon: const Icon(Icons.close)),
            ],
          ),
          Text('Giá: ${item.price.toStringAsFixed(0)}đ'),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              IconButton(
                onPressed: onDecrease,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text('${item.quantity}'),
              IconButton(
                onPressed: onIncrease,
                icon: const Icon(Icons.add_circle_outline),
              ),
              const Spacer(),
              Text(item.lineTotal.toStringAsFixed(0)),
            ],
          ),
        ],
      ),
    );
  }
}
