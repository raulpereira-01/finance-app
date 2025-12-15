import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/category_expense.dart';

class ExpensesByCategoryPieWidget extends StatelessWidget {
  final List<CategoryExpense> data;

  const ExpensesByCategoryPieWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No expenses for this period'),
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
            const Text(
              'Expenses by category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
