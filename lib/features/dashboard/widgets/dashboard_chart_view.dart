import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/dashboard_summary_model.dart';

class DashboardChartView extends StatelessWidget {
  const DashboardChartView({
    super.key,
    required this.topBranches,
  });

  final List<TopBranchModel> topBranches;

  @override
  Widget build(BuildContext context) {
    if (topBranches.isEmpty) {
      return const SizedBox.shrink();
    }

    // Extract double values from revenue strings like "42,1M" -> 42.1
    final List<double> values = topBranches.map((TopBranchModel branch) {
      final String cleaned = branch.revenue
          .replaceAll('M', '')
          .replaceAll('B', '')
          .replaceAll(',', '.')
          .trim();
      double val = double.tryParse(cleaned) ?? 0.0;
      if (branch.revenue.contains('B')) {
        val *= 1000.0; // scale billions to millions for graph comparison
      }
      return val;
    }).toList();

    final double maxValue = values.isEmpty
        ? 1.0
        : values.reduce((double a, double b) => a > b ? a : b);
    final double maxScale = maxValue == 0.0 ? 1.0 : maxValue;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Doanh thu chi nhánh (M)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Icon(
                  Icons.bar_chart_rounded,
                  color: AppColors.pharmaGreen.withOpacity(0.8),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 180,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List<Widget>.generate(topBranches.length, (int index) {
                  final TopBranchModel branch = topBranches[index];
                  final double val = values[index];
                  // Proportional height factor (capped at 90% of graph height to fit value text above it)
                  final double heightFactor = (val / maxScale) * 0.85;

                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          branch.revenue,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.pharmaGreen,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          height: 120 * heightFactor,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: <Color>[
                                Color(0xFF34D399),
                                AppColors.pharmaGreen,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(6),
                              topRight: Radius.circular(6),
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: AppColors.pharmaGreen.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          branch.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
