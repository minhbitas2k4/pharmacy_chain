import '../../pos/models/cart_item_model.dart';
import '../models/invoice_model.dart';

class InvoiceService {
  Future<InvoiceModel> fetchInvoice() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return InvoiceModel(
      code: 'HD-2025-000128',
      branch: 'CN Quận 1 - HCM',
      cashier: 'Trần Văn Minh',
      time: '10/07/2025 14:32',
      items: const <CartItemModel>[
        CartItemModel(name: 'Amoxicillin 500mg', price: 85000, quantity: 1),
        CartItemModel(name: 'Vitamin C 1000mg', price: 60000, quantity: 2),
      ],
      total: 205000,
      discount: 0,
      paymentMethod: 'Tiền mặt',
    );
  }
}
