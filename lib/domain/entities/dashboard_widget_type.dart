// Enumeración que identifica los diferentes widgets visuales disponibles en el dashboard.
enum DashboardWidgetType { balance, expensesByCategory, incomeVsExpenses }

extension DashboardWidgetTypeX on DashboardWidgetType {
  String get title {
    switch (this) {
      case DashboardWidgetType.balance:
        return 'Monthly balance';
      case DashboardWidgetType.expensesByCategory:
        return 'Expenses by category';
      case DashboardWidgetType.incomeVsExpenses:
        return 'Income vs expenses';
    }
  }
}
