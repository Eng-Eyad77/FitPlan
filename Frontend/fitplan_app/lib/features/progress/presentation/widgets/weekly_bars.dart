import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';

/// One bar per week (oldest first, the last is this week), with the value on touch.
/// This week is drawn with the gradient, the past weeks in the quieter accent.
class WeeklyBars extends StatelessWidget {
  const WeeklyBars({
    super.key,
    required this.weeks,
    required this.values,
    required this.format,
    this.height = 150,
  });

  final List<DateTime> weeks;
  final List<double> values;

  /// Tooltip text for a value, e.g. "4.2 t".
  final String Function(double value) format;
  final double height;

  @override
  Widget build(BuildContext context) {
    final max = values.fold<double>(0, (a, b) => a > b ? a : b);
    final weekFormat = DateFormat('d MMM');

    return Semantics(
      label: 'This week ${format(values.last)}, last week ${format(values[values.length - 2])}',
      child: SizedBox(
        height: height,
        child: BarChart(
          BarChartData(
            maxY: max == 0 ? 1 : max * 1.15,
            alignment: BarChartAlignment.spaceBetween,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: const AxisTitles(),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    // the first and this week only, the bars between speak for themselves
                    final label = i == weeks.length - 1
                        ? 'This week'
                        : i == 0
                            ? weekFormat.format(weeks[i])
                            : '';
                    return SideTitleWidget(
                      meta: meta,
                      // keep the first and last labels inside the card
                      fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                      child: Text(
                        label,
                        style: AppText.caption.copyWith(
                          color: i == weeks.length - 1 ? AppColors.accent : AppColors.textTertiary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => AppColors.surface2,
                tooltipBorderRadius: BorderRadius.circular(10),
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                  '${format(rod.toY)}\n',
                  AppText.bodyStrong,
                  children: [
                    TextSpan(text: 'Week of ${weekFormat.format(weeks[group.x])}', style: AppText.caption),
                  ],
                ),
              ),
            ),
            barGroups: [
              for (var i = 0; i < values.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: values[i],
                      width: 18,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      gradient: i == values.length - 1 ? AppColors.signatureGradient : null,
                      color: i == values.length - 1 ? null : AppColors.accentDeep.withValues(alpha: 0.7),
                      // a faint full-height track so empty weeks still read as weeks
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: max == 0 ? 1 : max * 1.15,
                        color: AppColors.surface2,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
