import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../core/constants/hive_boxes.dart';
import '../../data/models/category_model.dart';
import '../../data/models/expense_model.dart';
import '../entities/category_expense.dart';
import '../entities/selected_period.dart';

class ExpensesByCategoryService {
  final Box<ExpenseModel> _expenseBox = Hive.box<ExpenseModel>(
    HiveBoxes.expenses,
  );
  final Box<CategoryModel> _categoryBox = Hive.box<CategoryModel>(
    HiveBoxes.categories,
  );

  List<CategoryExpense> calculateForPeriod(SelectedPeriod period) {
    final inclusiveExpenses = _expenseBox.values.where((expense) {
      final afterStart = !expense.date.isBefore(period.startDate);
      final beforeEnd = !expense.date.isAfter(period.endDate);

      return afterStart && beforeEnd && !expense.isRecurring;
    }).toList();

    final recurringExpenses = _expenseBox.values.where((expense) {
      if (!expense.isRecurring) return false;

      final startDate = expense.startDate ?? expense.date;
      return !startDate.isAfter(period.endDate);
    }).map((expense) {
      final targetDay = expense.dayOfMonth ?? expense.date.day;
      final lastDayOfMonth = period.endDate.day;
      final safeDay = targetDay > lastDayOfMonth ? lastDayOfMonth : targetDay;

      return ExpenseModel(
        id: expense.id,
        name: expense.name,
        amount: expense.amount,
        date: DateTime(period.year, period.month, safeDay),
        isFixed: expense.isFixed,
        categoryId: expense.categoryId,
        isRecurring: expense.isRecurring,
        dayOfMonth: expense.dayOfMonth,
        startDate: expense.startDate,
      );
    }).toList();

    final expenses = [...inclusiveExpenses, ...recurringExpenses];

    final Map<String, double> totalsByCategory = {};

    for (final expense in expenses) {
      totalsByCategory.update(
        expense.categoryId,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    final categories = _categoryBox.values.toList();

    return totalsByCategory.entries.map((entry) {
      final category = categories.firstWhere(
        (c) => c.id == entry.key,
        orElse: () => CategoryModel(
          id: entry.key,
          name: 'Sin categoría',
          emoji: '❓',
          colorValue: Colors.grey.value,
        ),
      );

      return CategoryExpense(
        categoryId: category.id,
        total: entry.value,
        colorValue: category.colorValue,
        emoji: category.emoji,
      );
    }).toList();
  }
}
