import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/hive_boxes.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/expense_model.dart';

class ExpensesByCategoryPieWidget extends StatelessWidget {
  const ExpensesByCategoryPieWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseBox = Hive.box<ExpenseModel>(HiveBoxes.expenses);
    final categoryBox = Hive.box<CategoryModel>(HiveBoxes.categories);

    final expenses = expenseBox.values.toList();
    final categories = categoryBox.values.toList();

    if (expenses.isEmpty || categories.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No expenses to display'),
        ),
      );
    }

    final Map<String, double> totalsByCategory = {};

    for (final expense in expenses) {
      totalsByCategory.update(
        expense.categoryId,
            (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    final sections = totalsByCategory.entries.map((entry) {
      final category = categories
          .where((c) => c.id == entry.key)
          .cast<CategoryModel?>()
          .firstWhere((c) => c != null, orElse: () => null);

      if (category == null) {
        return null;
      }

      return PieChartSectionData(
        value: entry.value,
        color: Color(category.colorValue),
        title: category.emoji,
        radius: 50,
        titleStyle: const TextStyle(fontSize: 18),
      );
    }).whereType<PieChartSectionData>().toList();

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
