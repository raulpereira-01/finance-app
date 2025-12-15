import 'package:hive/hive.dart';

import '../../core/constants/hive_boxes.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/income_model.dart';
import '../entities/monthly_summary.dart';

class MonthlySummaryService {
  final Box<IncomeModel> _incomeBox = Hive.box<IncomeModel>(HiveBoxes.incomes);
  final Box<ExpenseModel> _expenseBox = Hive.box<ExpenseModel>(HiveBoxes.expenses);

  MonthlySummary calculateForMonthYear(int month, int year) {
    final incomeTotal = _incomeBox.values.fold<double>(
      0,
          (sum, income) {
        final sameMonth = income.date.month == month;
        final sameYear = income.date.year == year;

        if (sameMonth && sameYear) {
          return sum + income.amount;
        }

        return sum;
      },
    );

    final expensesTotal = _expenseBox.values.fold<double>(
      0,
          (sum, expense) {
        final sameMonth = expense.date.month == month;
        final sameYear = expense.date.year == year;

        if (sameMonth && sameYear) {
          return sum + expense.amount;
        }

        return sum;
      },
    );

    return MonthlySummary(
      income: incomeTotal,
      expenses: expensesTotal,
    );
  }
}
