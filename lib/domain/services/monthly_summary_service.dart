// Resume ingresos y gastos de un mes leyendo las cajas de Hive correspondientes.
import 'package:hive/hive.dart';

import '../../core/constants/hive_boxes.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/income_model.dart';
import '../entities/monthly_summary.dart';

class MonthlySummaryService {
  final Box<IncomeModel> _incomeBox = Hive.box<IncomeModel>(HiveBoxes.incomes);
  final Box<ExpenseModel> _expenseBox = Hive.box<ExpenseModel>(
    HiveBoxes.expenses,
  );

  MonthlySummary calculateForMonthYear(int month, int year) {
    final periodEnd = DateTime(year, month + 1, 0);
    final lastDayOfMonth = periodEnd.day;

    final incomeTotal = _incomeBox.values.fold<double>(0, (sum, income) {
      final started = !income.startDate.isAfter(periodEnd);

      return started ? sum + income.amount : sum;
    });

    final expensesTotal = _expenseBox.values.fold<double>(0, (sum, expense) {
      if (expense.isRecurring) {
        final startDate = expense.startDate ?? expense.date;
        final started = !startDate.isAfter(periodEnd);

        return started ? sum + expense.amount : sum;
      }

      final periodStart = DateTime(year, month, 1);
      final sameMonth = expense.date.month == month;
      final sameYear = expense.date.year == year;
      final sameOrAfterStart = !expense.date.isBefore(periodStart);
      final sameOrBeforeEnd = !expense.date
          .isAfter(DateTime(year, month, lastDayOfMonth));

      if (sameMonth && sameYear && sameOrAfterStart && sameOrBeforeEnd) {
        return sum + expense.amount;
      }

      return sum;
    });

    return MonthlySummary(income: incomeTotal, expenses: expensesTotal);
  }
}
