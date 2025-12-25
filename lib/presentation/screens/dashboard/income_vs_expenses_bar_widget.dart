// Widget de barras que compara ingresos vs gastos del periodo seleccionado.
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/monthly_summary.dart';
import '../../../l10n/app_localizations.dart';

class IncomeVsExpensesBarWidget extends StatelessWidget {
  final MonthlySummary summary;

  const IncomeVsExpensesBarWidget({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (summary.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(l10n.incomeVsExpensesEmpty),
        ),
      );
    }

    final maxValue = summary.income > summary.expenses
        ? summary.income
        : summary.expenses;
    final chartMaxY = maxValue <= 0 ? 1.0 : maxValue * 1.2;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.incomeVsExpensesTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _LegendDot(
                  color: Colors.green,
                  label: '${l10n.chartIncomeLabel}: ' +
                      summary.income.toStringAsFixed(2),
                ),
                _LegendDot(
                  color: Colors.red,
                  label: '${l10n.chartExpensesLabel}: ' +
                      summary.expenses.toStringAsFixed(2),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (
                        group,
                        groupIndex,
                        rod,
                        rodIndex,
                      ) {
                        final isIncome = group.x == 0;
                        final label = isIncome
                            ? l10n.chartIncomeLabel
                            : l10n.chartExpensesLabel;
                        return BarTooltipItem(
                          '$label\n${rod.toY.toStringAsFixed(2)}',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  alignment: BarChartAlignment.spaceAround,
                  maxY: chartMaxY,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: TextStyle(fontSize: 11),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return Text(l10n.chartIncomeLabel);
                            case 1:
                              return Text(l10n.chartExpensesLabel);
                            default:
                              return const SizedBox.shrink();
                          }
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: summary.income,
                          color: Colors.green,
                          width: 24,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: summary.expenses,
                          color: Colors.red,
                          width: 24,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
