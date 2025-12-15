class MonthlySummary {
  final double income;
  final double expenses;

  const MonthlySummary({required this.income, required this.expenses});

  bool get isEmpty => income == 0 && expenses == 0;
}
