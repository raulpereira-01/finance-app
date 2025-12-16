// Resumen del balance mensual separando ingresos, gastos fijos y variables.
class MonthlyBalance {
  final double totalIncome;
  final double totalFixedExpenses;
  final double totalVariableExpenses;

  MonthlyBalance({
    required this.totalIncome,
    required this.totalFixedExpenses,
    required this.totalVariableExpenses,
  });

  double get remaining =>
      totalIncome - totalFixedExpenses - totalVariableExpenses;
}
