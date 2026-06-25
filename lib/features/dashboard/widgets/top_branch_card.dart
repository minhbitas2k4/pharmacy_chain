import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../models/dashboard_summary_model.dart';

class TopBranchCard extends StatelessWidget {
  const TopBranchCard({super.key, required this.branch, required this.rank});

  final TopBranchModel branch;
  final int rank;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: AppColors.pharmaMint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                  color: AppColors.pharmaGreen,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${branch.name} - ${branch.city}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Top doanh thu',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            branch.revenue,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.pharmaDarkGreen,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
