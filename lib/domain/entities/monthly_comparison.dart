class MonthlyComparison {
  final double current;
  final double previous;

  const MonthlyComparison({
    required this.current,
    required this.previous,
  });

  double get difference => current - previous;

  double get percentageChange {
    if (previous == 0) return 0;
    return (difference / previous) * 100;
  }

  bool get isIncrease => difference > 0;
}
