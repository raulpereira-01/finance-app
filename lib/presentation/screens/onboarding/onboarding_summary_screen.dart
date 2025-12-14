import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/hive_boxes.dart';
import '../../../data/models/income_model.dart';
import '../../../data/models/expense_model.dart';
import '../dashboard/dashboard_screen.dart';

class OnboardingSummaryScreen extends StatelessWidget {
  const OnboardingSummaryScreen({super.key});

  double _totalIncome(Box<IncomeModel> incomeBox) {
    return incomeBox.values.fold(
      0,
          (sum, item) => sum + item.amount,
    );
  }

  double _totalFixedExpenses(Box<ExpenseModel> expenseBox) {
    return expenseBox.values
        .where((e) => e.isFixed)
        .fold(0, (sum, item) => sum + item.amount);
  }

  @override
  Widget build(BuildContext context) {
    final incomeBox = Hive.box<IncomeModel>(HiveBoxes.incomes);
    final expenseBox = Hive.box<ExpenseModel>(HiveBoxes.expenses);

    final totalIncome = _totalIncome(incomeBox);
    final totalExpenses = _totalFixedExpenses(expenseBox);
    final remaining = totalIncome - totalExpenses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your monthly overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _SummaryRow(
              label: 'Total income',
              value: totalIncome,
              color: Colors.green,
            ),
            _SummaryRow(
              label: 'Fixed expenses',
              value: totalExpenses,
              color: Colors.red,
            ),
            const Divider(height: 32),
            _SummaryRow(
              label: 'Available',
              value: remaining,
              color: remaining >= 0 ? Colors.green : Colors.red,
              isBig: true,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DashboardScreen(),
                    ),
                        (_) => false,
                  );
                },
                child: const Text('Go to dashboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool isBig;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
    this.isBig = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: isBig ? 22 : 16,
      fontWeight: isBig ? FontWeight.bold : FontWeight.normal,
      color: color,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value.toStringAsFixed(2),
            style: style,
          ),
        ],
      ),
    );
  }
}
