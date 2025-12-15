import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/category_expense.dart';
import '../../../l10n/app_localizations.dart';

class ExpensesByCategoryPieWidget extends StatelessWidget {
  final List<CategoryExpense> data;

  const ExpensesByCategoryPieWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (data.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(l10n.noExpenses),
        ),
      );
    }

    final sections = data.map((item) {
      return PieChartSectionData(
        value: item.total,
        color: Color(item.colorValue),
        title: item.emoji,
        radius: 50,
        titleStyle: const TextStyle(fontSize: 18),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.pieChartTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
