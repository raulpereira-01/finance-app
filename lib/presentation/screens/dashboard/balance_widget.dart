import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/hive_boxes.dart';
import '../../../data/models/income_model.dart';
import '../../../data/models/expense_model.dart';

class BalanceWidget extends StatelessWidget {
  const BalanceWidget({super.key});

  double _totalIncome(Box<IncomeModel> incomeBox) {
    return incomeBox.values.fold(0, (sum, i) => sum + i.amount);
  }

  double _totalExpenses(Box<ExpenseModel> expenseBox) {
    return expenseBox.values.fold(0, (sum, e) => sum + e.amount);
  }

  @override
  Widget build(BuildContext context) {
    final incomeBox = Hive.box<IncomeModel>(HiveBoxes.incomes);
    final expenseBox = Hive.box<ExpenseModel>(HiveBoxes.expenses);

    final income = _totalIncome(incomeBox);
    final expenses = _totalExpenses(expenseBox);
    final balance = income - expenses;

    final isPositive = balance >= 0;
    final color = isPositive ? Colors.green : Colors.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly balance',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              balance.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isPositive ? 'You are saving money' : 'You are overspending',
              style: TextStyle(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
