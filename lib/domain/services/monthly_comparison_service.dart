// Compara el ingreso del periodo actual con el mes anterior para mostrar tendencias.
import '../entities/monthly_comparison.dart';
import '../entities/selected_period.dart';
import 'monthly_summary_service.dart';

class MonthlyComparisonService {
  final MonthlySummaryService _summaryService = MonthlySummaryService();

  MonthlyComparison compareIncome(SelectedPeriod period) {
    final current = _summaryService.calculateForMonthYear(
      period.month,
      period.year,
    );

    final previousPeriod = period.previousMonth();

    final previous = _summaryService.calculateForMonthYear(
      previousPeriod.month,
      previousPeriod.year,
    );

    return MonthlyComparison(
      current: current.income,
      previous: previous.income,
    );
  }

  MonthlyComparison compareExpenses(SelectedPeriod period) {
    final current = _summaryService.calculateForMonthYear(
      period.month,
      period.year,
    );

    final previousPeriod = period.previousMonth();

    final previous = _summaryService.calculateForMonthYear(
      previousPeriod.month,
      previousPeriod.year,
    );

    return MonthlyComparison(
      current: current.expenses,
      previous: previous.expenses,
    );
  }
}
