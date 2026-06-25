import 'package:flutter/material.dart';

import '../../pos/models/cart_item_model.dart';

class InvoiceItemTile extends StatelessWidget {
  const InvoiceItemTile({super.key, required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item.name),
      subtitle: Text('x${item.quantity}'),
      trailing: Text('${item.lineTotal.toStringAsFixed(0)}đ'),
    );
  }
}
