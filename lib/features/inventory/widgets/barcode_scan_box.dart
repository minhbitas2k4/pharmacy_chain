import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';

class BarcodeScanBox extends StatelessWidget {
  const BarcodeScanBox({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        child: SizedBox(
          height: 180,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Icon(
                Icons.camera_alt_rounded,
                size: 44,
                color: AppColors.pharmaGreen,
              ),
              SizedBox(height: 12),
              Text(
                'Quét mã vạch / QR Code',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 6),
              Text('Sử dụng camera điện thoại làm máy quét'),
            ],
          ),
        ),
      ),
    );
  }
}
