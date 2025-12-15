class SelectedPeriod {
  final int month;
  final int year;
  final DateTime startDate;
  final DateTime endDate;

  SelectedPeriod({
    required this.month,
    required this.year,
    required this.startDate,
    required this.endDate,
  });

  factory SelectedPeriod.fromMonthYear(int month, int year) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0);

    return SelectedPeriod(
      month: month,
      year: year,
      startDate: start,
      endDate: end,
    );
  }

  SelectedPeriod previousMonth() {
    final newMonth = month == 1 ? 12 : month - 1;
    final newYear = month == 1 ? year - 1 : year;
    return SelectedPeriod.fromMonthYear(newMonth, newYear);
  }

  SelectedPeriod nextMonth() {
    final newMonth = month == 12 ? 1 : month + 1;
    final newYear = month == 12 ? year + 1 : year;
    return SelectedPeriod.fromMonthYear(newMonth, newYear);
  }

  String get formattedLabel => '${_monthName(month)} $year';

  String _monthName(int monthNumber) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return monthNames[monthNumber - 1];
  }
}
