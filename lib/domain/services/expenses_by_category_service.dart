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
    final expenses = _expenseBox.values.where((expense) {
      return expense.date.isAfter(period.startDate) &&
          expense.date.isBefore(period.endDate);
    });

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
      final category = categories.firstWhere((c) => c.id == entry.key);

      return CategoryExpense(
        categoryId: category.id,
        total: entry.value,
        colorValue: category.colorValue,
        emoji: category.emoji,
      );
    }).toList();
  }
}
