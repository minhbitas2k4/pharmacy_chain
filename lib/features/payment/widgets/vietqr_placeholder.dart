import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';

class VietQrPlaceholder extends StatelessWidget {
  const VietQrPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: SizedBox(
        height: 180,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.qr_code_2_rounded, size: 52),
              SizedBox(height: 10),
              Text(
                'VietQR',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
