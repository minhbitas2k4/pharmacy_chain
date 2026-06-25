import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_header.dart';
import '../../../features/payment/screens/payment_screen.dart';
import '../controllers/pos_controller.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/cart_summary_card.dart';
import '../widgets/product_search_panel.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  late final PosController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PosController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkout() async {
    final bool success = await _controller.checkout();
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Giỏ hàng đang rỗng')));
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          cartTotal: _controller.subtotal,
          // items: _controller.cart,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return Column(
              children: [
                const AppHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Bán tại quầy',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Quét mã hoặc tìm thuốc để tạo đơn',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 20),
                        ProductSearchPanel(
                          suggestions: _controller.suggestions,
                          onSuggestionTap: (String item) {
                            if (item.contains('Amoxicillin'))
                              _controller.addSuggestion(
                                'Amoxicillin 500mg',
                                85000,
                              );
                            if (item.contains('Paracetamol'))
                              _controller.addSuggestion(
                                'Paracetamol 500mg',
                                25000,
                              );
                            if (item.contains('Vitamin C'))
                              _controller.addSuggestion(
                                'Vitamin C 1000mg',
                                60000,
                              );
                          },
                          onScanCode: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Mở máy quét mã vạch'),
                                ),
                              ),
                        ),
                        const SizedBox(height: 16),
                        ..._controller.cart.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: CartItemTile(
                              item: item,
                              onIncrease: () => _controller.increase(item.name),
                              onDecrease: () => _controller.decrease(item.name),
                              onRemove: () => _controller.remove(item.name),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        CartSummaryCard(
                          subtotal: _controller.subtotal,
                          onCheckout: _checkout,
                          isLoading: _controller.isLoading,
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
