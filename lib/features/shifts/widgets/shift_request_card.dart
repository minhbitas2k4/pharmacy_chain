import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../models/shift_request_model.dart';

class ShiftRequestCard extends StatelessWidget {
  const ShiftRequestCard({
    super.key,
    required this.request,
    required this.onReject,
    required this.onApprove,
  });

  final ShiftRequestModel request;
  final VoidCallback onReject;
  final VoidCallback onApprove;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            request.name,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          Text(request.description),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  child: const Text('Từ chối'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onApprove,
                  child: const Text('Duyệt'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
