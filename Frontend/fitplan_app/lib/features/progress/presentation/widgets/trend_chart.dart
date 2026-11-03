import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../shared/format.dart';

typedef TrendPoint = ({DateTime date, double value});

/// One series over time: a 2px gradient line, a soft fill, the last point marked,
/// and the value + date on touch. Used for the estimated 1RM and the body weight.
class TrendChart extends StatelessWidget {
  const TrendChart({super.key, required this.points, required this.unit, this.height = 160});

  /// Oldest first.
  final List<TrendPoint> points;
  final String unit;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return SizedBox(
        // no line to draw yet: a short message, not a big empty box
        height: 56,
        child: Center(
          child: Text(
            points.isEmpty ? 'Nothing logged yet' : 'One more entry and the trend starts here',
            style: AppText.caption,
          ),
        ),
      );
    }

    final first = points.first.date;
    double x(DateTime d) => d.difference(first).inHours / 24; // days since the first point

    final values = points.map((p) => p.value);
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    // some air above and below, and never a flat line glued to an edge
    final pad = ((max - min) * 0.25).clamp(1.0, double.infinity);

    final spots = [for (final p in points) FlSpot(x(p.date), p.value)];
    final dateFormat = DateFormat('d MMM');

    return Semantics(
      label: 'Trend from ${formatKg(points.first.value)} to ${formatKg(points.last.value)} $unit',
      child: SizedBox(
        height: height,
        child: LineChart(
          LineChartData(
            minY: min - pad,
            maxY: max + pad,
            minX: 0,
            maxX: spots.last.x,
            clipData: const FlClipData.none(),
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: ((max + pad) - (min - pad)) / 3,
              getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.border, strokeWidth: 1, dashArray: [3, 4]),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: const AxisTitles(),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24,
                  interval: spots.last.x == 0 ? 1 : spots.last.x,
                  // only the first and the last date
                  getTitlesWidget: (value, meta) {
                    final date = value == 0 ? points.first.date : points.last.date;
                    return SideTitleWidget(
                      meta: meta,
                      // keep the first and last labels inside the card
                      fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                      child: Text(dateFormat.format(date.toLocal()), style: AppText.caption),
                    );
                  },
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => AppColors.surface2,
                tooltipBorderRadius: BorderRadius.circular(10),
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipItems: (spots) => [
                  for (final spot in spots)
                    LineTooltipItem(
                      '${formatKg(spot.y)} $unit\n',
                      AppText.bodyStrong,
                      children: [
                        TextSpan(
                          text: dateFormat.format(points[spot.spotIndex].date.toLocal()),
                          style: AppText.caption,
                        ),
                      ],
                    ),
                ],
              ),
              getTouchedSpotIndicator: (_, indexes) => [
                for (final _ in indexes)
                  const TouchedSpotIndicatorData(
                    FlLine(color: AppColors.textTertiary, strokeWidth: 1),
                    FlDotData(),
                  ),
              ],
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                preventCurveOverShooting: true,
                barWidth: 2.5,
                isStrokeCapRound: true,
                gradient: AppColors.signatureGradient,
                // only the latest point gets a dot (the one the headline number is about)
                dotData: FlDotData(
                  checkToShowDot: (spot, bar) => spot == bar.spots.last,
                  getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                    radius: 5,
                    color: AppColors.accent,
                    strokeWidth: 2,
                    strokeColor: AppColors.surface,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.accent.withValues(alpha: 0.22), AppColors.accent.withValues(alpha: 0)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
